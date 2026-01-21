import os
import asyncio
import logging
import time
import re
import json
from base64 import b64encode
from datetime import datetime, timedelta, timezone

import pyodbc
import aioodbc
import azure.functions as func
from azure.core.exceptions import ResourceExistsError
from azure.core.exceptions import ResourceNotFoundError
from azure.storage.blob.aio import ContainerClient
from azure.data.tables.aio import TableClient
from azure.data.tables import TableEntity

from helpers import reduce_logging, get_secret, get_oauth_token, submit_query_snowflake, cancel_query_snowflake, get_column_info, mssql_insert, mssql_upsert, mssql_execute

reduce_logging()
SQL_ATTR_CONNECTION_TIMEOUT = 113

class CTSyncError(Exception):
    pass

async def main(myTimer: func.TimerRequest, context: func.Context) -> None:
    
    """BULK LOAD FUNCTION"""

    logging.info(f"{context.function_name} started")
    
    """GET SETTINGS AND VARIABLES"""
    
    with open(os.path.join(context.function_directory, 'function.json')) as f:
        settings = json.load(f)
    
    disabled = True if os.environ.get(settings.get('sf_conn_params', '').replace('SF_CONN_PARAMS', 'DISABLED'), "false") == "true" else False
    if disabled:
        logging.info(f"{context.function_name} is disabled")
        return
    
    counter = time.perf_counter()
    scope = os.environ.get('APP_RES_SCOPE')
    conn_params = json.loads(os.environ.get(settings.get('sf_conn_params', '')))
    st_conn_str = os.environ['AzureWebJobsStorage']
    odbc_conn_str = os.environ.get(settings.get('sql_conn_str', ''))
    startup_time = os.environ['STARTUP_TIME_UTC']
    sf_pre_cmd = settings.get('sf_pre_cmd', '')
    sf_object = settings.get('sf_object', '')
    sf_query = settings.get('sf_query', '')
    sf_login_timeout = int(settings.get('sfLoginTimeout', '30'))
    sf_conn_timeout = int(settings.get('sfConnTimeout', '1200'))
    sql_pre_cmd = settings.get('sql_pre_cmd', '')
    sql_table_type = settings.get('sql_table_type', '')
    sql_table = settings.get('sql_table', '')
    sql_post_cmd = settings.get('sql_post_cmd', '')
    sql_login_timeout = int(settings.get('sqlLoginTimeout', '45'))
    sql_conn_timeout = int(settings.get('sqlConnTimeout', '900'))
    sql_recycle_int = 600
    sync_error_int = int(settings.get('syncErrorInterval', '30'))
    prog_error_int = int(settings.get('progErrorInterval', '60'))
    config_error_int = int(settings.get('configErrorInterval', '60'))
    error_int = int(settings.get('errorInterval', '15'))
    max_retries = int(settings.get('maxRetries', '50'))
    invocation_id = context.invocation_id

    async with TableClient.from_connection_string(conn_str=st_conn_str, table_name='FUSEWatermarks') as table_client:
        """CREATE TABLE IF MISSING"""

        try:
            await table_client.create_table()
        except ResourceExistsError:
            pass

        """GET LAST SYNC TIMESTAMP"""

        try:
            item = await table_client.get_entity(partition_key=context.function_name, row_key='')
            logging.info('Last Sync Timestamp retrieved')
        except ResourceNotFoundError as ex:
            item = {'PartitionKey': context.function_name, 'RowKey': ''}
            logging.info(f'New Function Watermark initialized: {item}')

        """PROCESS JOB"""

        try:
            """SNOWFLAKE PROCESSING"""

            result = ''

            secret = await get_secret(os.environ['FUNC_APP_KEYVAULT'], os.environ['APP_REG_SECRET'])
            token = await get_oauth_token(scope, os.environ['AZURE_TENANT_ID'], os.environ['APP_REG_ID'], secret)

            if sf_pre_cmd:
                try:
                    data = await submit_query_snowflake(token, conn_params=conn_params, query=sf_pre_cmd, timeout=sf_conn_timeout)
                except Exception as ex:
                    handle = json.loads(ex.message).get('statementHandle')
                    if handle:
                        await cancel_query_snowflake(token, handle=handle)
                        logging.info(f"Query '{handle}' was cancelled due to an error")
                    raise ex

            if sf_object:
                # Raise synchronization error when max retries exceeded
                if item.get('Retries', 0) >= max_retries:
                    result = ''
                    item['LastSyncTS'] = '-1'
                    raise CTSyncError(f"Max retries exceeded, will re-synchronize with object '{sf_object}'")

                # Get last_sync_ts
                last_sync_ts = item.get('LastSyncTS', '-1')

                if last_sync_ts == '-1':
                    result = 'Re-synchronized'
                    last_sync_ts = datetime.now(timezone(timedelta(hours=-7))).replace(tzinfo=None).isoformat()
                    item['LastSyncTS'] = last_sync_ts
                    logging.info(f"Re-synchronized with object '{sf_object}'")

                # if len(last_sync_id) != 36:
                #     sync_condition = "TIMESTAMP => CURRENT_TIMESTAMP()"
                # else:
                #     sync_condition = f"STATEMENT => '{last_sync_id}'"
                # ct_query = f"SELECT * FROM {sf_object} CHANGES(INFORMATION => DEFAULT) AT({sync_condition})"

                ct_query = f"""
                    SELECT * FROM {sf_object}
                    WHERE DW_MODIFY_TS > '{last_sync_ts}'
                """

                try:
                    data = await submit_query_snowflake(token, conn_params=conn_params, query=ct_query, timeout=sf_conn_timeout)
                except Exception as ex:
                    handle = json.loads(ex.message).get('statementHandle')
                    if handle:
                        await cancel_query_snowflake(token, handle=handle)
                        logging.info(f"Query '{handle}' was cancelled due to an error")
                    raise ex
                
                # sync_query = "SELECT LAST_QUERY_ID() AS QUERY_ID"
                # sync_data = await submit_query_snowflake(token, conn_params=conn_params, query=sync_query, timeout=sf_conn_timeout)
                # sync_id = sync_data[0].get("QUERY_ID", "-1")

                sync_ts = max([datetime.fromisoformat(row.get('DW_MODIFY_TS', '')[:23]) for row in data]).isoformat()

                logging.info(f"Snowflake Changes Retrieved: {len(data)} rows retrieved")
            elif sf_query:
                data = await submit_query_snowflake(token, conn_params=conn_params, query=sf_query, timeout=sf_conn_timeout)
                logging.info(f"Snowflake Query executed: {len(data)} rows retrieved")
            
            if not data:
                logging.info(f"No data to process")
                return
            
            """MSSQL PROCESSING"""

            schema, table = map(lambda x: x.strip('[]'), sql_table.upper().split('.')) # account for reserved keywords using brackets

            async with aioodbc.create_pool(dsn=odbc_conn_str, minsize=0, maxsize=1, echo=False, pool_recycle=sql_recycle_int, timeout=sql_login_timeout, attrs_before={SQL_ATTR_CONNECTION_TIMEOUT: sql_conn_timeout}) as pool:
                # Get Column Info
                column_info = json.loads(item.get('ColumnInfo', '[]'))
                uptime = (datetime.now(timezone.utc) - datetime.fromisoformat(startup_time)).total_seconds()
                
                async with pool.acquire() as sql_conn:
                    if not column_info or uptime < item.get('LastUpTime', -1.0):
                        column_info = await get_column_info(sql_conn, schema, table)
                        item['ColumnInfo'] = json.dumps(column_info)
                        logging.info('Column Info retrieved')

                        # Needs to be created by DBA Team as returns error "DDL statements ALTER, DROP and CREATE inside user transactions are not supported with memory optimized tables."
                        # tt_schema, tt_table = map(lambda x: x.strip('[]'), sql_table_type.upper().split('.'))
                        # await mssql_create_table_type(sql_conn, column_info, tt_schema, tt_table)
                        # logging.info('In-Memory Table Type Created')
                    
                    item['LastUpTime'] = uptime

                    if sql_pre_cmd:
                        rows = await mssql_execute(sql_conn, sql_pre_cmd)
                        logging.info(f"MSSQL Pre-Command completed: {rows} affected")
                        await asyncio.sleep(1)
                    
                    if sql_table:
                        rows = await mssql_insert(sql_conn, data, sql_table_type, sql_table, column_info)
                        logging.info(f"MSSQL Insert completed: {rows} affected")
                        await asyncio.sleep(1)
                    
                    if sql_post_cmd:
                        rows = await mssql_execute(sql_conn, sql_post_cmd)
                        logging.info(f"MSSQL Post-Command completed: {rows} affected")
                        await asyncio.sleep(1)

            if sf_object:
                # Update last_sync_ts
                item['LastSyncTS'] = sync_ts
                logging.info(f"Snowflake Stream consumption completed")

        except KeyError as ex:
            item['Status'], item['Result'], item['Retries'] = 'Failed', json.dumps({'error': f'Missing required fields: {ex}', 'result': result}, indent=4), item.get('Retries', 0) + 1
            logging.error(', '.join([item['Status'], item['Result']]))
            await asyncio.sleep(config_error_int)
            raise ex
        except pyodbc.ProgrammingError as ex:
            item['Status'], item['Result'], item['Retries'] = 'Failed', json.dumps({'error': str(ex), 'result': result}, indent=4), item.get('Retries', 0) + 1
            logging.error(', '.join([item['Status'], item['Result']]))
            await asyncio.sleep(prog_error_int)
            raise ex
        except CTSyncError as ex:
            item['Status'], item['Result'], item['Retries'] = 'Failed', json.dumps({'error': str(ex), 'result': result}, indent=4), 0
            logging.error(', '.join([item['Status'], item['Result']]))
            await asyncio.sleep(sync_error_int)
            raise ex
        except (pyodbc.Error, Exception) as ex:
            item['Status'], item['Result'], item['Retries'] = 'Failed', json.dumps({'error': str(ex), 'result': result}, indent=4), item.get('Retries', 0) + 1
            logging.error(', '.join([item['Status'], item['Result']]))
            await asyncio.sleep(error_int)
            raise ex
        else:
            item['Status'], item['Result'], item['Retries'] = 'Job Completed', json.dumps({'result': result}, indent=4), 0
            logging.info(', '.join([item['Status'], item['Result']]))
        finally:
            item['ElapsedMins'] = round((time.perf_counter() - counter)/60, 4)
            await table_client.upsert_entity(item, 'replace')
            
        logging.info(f"{context.function_name} finished")