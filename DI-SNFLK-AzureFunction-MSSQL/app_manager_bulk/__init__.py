import os
import asyncio
import logging
import time
import re
import json
from base64 import b64encode
from datetime import datetime, timezone

import aioodbc
import azure.functions as func
from azure.storage.blob.aio import ContainerClient
from azure.data.tables.aio import TableClient
from azure.data.tables import TableEntity

from helpers import curate_dict, mssql_query_batch, upload_blob

"""DEFINE COLUMN REFERENCE"""

TableEntity.curate = curate_dict
colref = {'PartitionKey': '0 Reference', 'RowKey': 'Leave empty', 'Server': 'azwp12ssdbx14.fmi.com', 'OnPrem': '1 if server is on-prem, else 0 (Optional, default value is 0)', 'SiteCode': "Site Code, 'ALL' or the Region depending on the case", 'SourceID': '436', 'AppName': 'Labware', 'Database': 'LABWARE_PROD', 'Queries': 'select * from dbo.PRODUCT; select * from dbo.PRODUCT_SPEC; select * from dbo.RESULT; select * from dbo.PROJECT; select * from dbo.SAMPLE; select * from dbo.TEST; select * from dbo.ANALYSIS; select * from dbo.PROD_GRADE_STAGE; select * from dbo.ANALYSIS_TYPES', 'BatchSize': 'Batch Size (Optional, 100000 by default)', 'Status': "Function-managed, don't modify except to skip execution. Job will only be processed when different than 'Completed'", 'ElapsedMins': "Function-managed, don't modify", 'Result': "Function-managed, don't modify. Click on Edit to see the pretty-printed result"}

async def main(myTimer: func.TimerRequest, context: func.Context) -> None:
    
    """BULK LOAD FUNCTION"""

    logging.info(f"{context.function_name} started")
    
    """GET SETTINGS AND VARIABLES"""
    
    global counter, st_conn_str, container, num_queries, invocation_id
    counter = time.perf_counter()
    slot = os.environ.get('WEBSITE_SLOT_NAME')
    st_conn_str = os.environ['AzureWebJobsStorage']
    container = os.environ.get('FILES_CONTAINER')
    num_jobs = int(os.environ.get('BULK_LOAD_JOB_CONCURRENCY', '5') if os.environ.get('BULK_LOAD_JOB_CONCURRENCY', '5').isdigit() else '5')
    num_queries = int(os.environ.get('BULK_LOAD_QUERY_CONCURRENCY', '3') if os.environ.get('BULK_LOAD_QUERY_CONCURRENCY', '3').isdigit() else '3')
    invocation_id = context.invocation_id

    if slot != 'Production':
        return

    async with TableClient.from_connection_string(conn_str=st_conn_str, table_name='FUSEBulkLoadControlTable') as table_client:
        
        """CREATE TABLE IF MISSING"""

        try:
           await table_client.create_table()
        except:
           pass

        """SET COLUMN REFERENCE"""
        
        await table_client.upsert_entity(colref, 'replace')

        """SCAN JOBS"""

        items = table_client.query_entities("PartitionKey ne '0 Reference'")
        completed, remaining = [], []
        async for item in items:
            item.curate(colref)
            if 'Completed' in item.get('Status', ''):
                completed += [item]
            else:
                remaining += [item]

        """CLEANUP JOBS"""
        
        # for item in completed:
        #     if (datetime.now(timezone.utc)-item.metadata.get('timestamp')).days >= 7:
        #         await table_client.delete_entity(item)
        #         logging.info(f'Deleted already completed job: {item}')

    if not remaining:
        logging.info('Bulk Load Jobs not found')
        return
    
    remaining = sorted(remaining, key=lambda item: item.metadata.get('timestamp'))

    """PROCESS JOBS"""
    
    tasks = [asyncio.create_task(process_job(item)) for item in remaining[:num_jobs]]
    
    try:
        await asyncio.gather(*tasks)
    except Exception as ex:
        for task in tasks:
            task.cancel()
        raise ex
        
    logging.info(f"{context.function_name} finished")

async def process_job(item):
    async with TableClient.from_connection_string(conn_str=st_conn_str, table_name='FUSEBulkLoadControlTable') as table_client:
        async with ContainerClient.from_connection_string(st_conn_str, container) as container_client:
            try:

                """GET SETTINGS AND VARIABLES"""
                
                results = {}
                item['PartitionKey'], item['RowKey'] = item.get('PartitionKey', ''), item.get('RowKey', '')
                queries = item['Queries']
                lock = asyncio.Lock()
                
                """VALIDATIONS"""

                queries = [query.strip() for query in queries.split(';') if query.strip()]
                invalid_queries = [query for query in queries if not re.findall(r'from\s+([\w\[\]]+)\.([\w\[\]]+)', query, re.IGNORECASE)]
                if invalid_queries:
                    raise ValueError(f"The following queries are invalid: {invalid_queries}")

                """PROCESS QUERIES"""

                for i in range(0, len(queries), num_queries):
        
                    tasks = [asyncio.create_task(process_query(query, table_client, container_client, lock, results, item)) for query in queries[i:i+num_queries]]
                    
                    try:
                        await asyncio.gather(*tasks)
                    except Exception as ex:
                        for task in tasks:
                            task.cancel()
                        raise ex

            except KeyError as ex:
                item['Status'], item['Result'] = 'Failed', json.dumps({'error': f'Missing required fields: {ex}', **results}, indent=4)
                logging.error(', '.join([item['Status'], item['Result']]))
                raise ex
            except Exception as ex:
                item['Status'], item['Result'] = 'Failed', json.dumps({'error': str(ex), **results}, indent=4)
                logging.error(', '.join([item['Status'], item['Result']]))
                raise ex
            else:
                item['Status'], item['Result'] = 'Completed', json.dumps(results, indent=4)
                logging.info(', '.join([item['Status'], item['Result']]))
            finally:
                item['ElapsedMins'] = round((time.perf_counter() - counter)/60, 4)
                await table_client.upsert_entity(item, 'replace')

async def process_query(query, table_client, container_client, lock, results, item):
        
    """GET SETTINGS AND VARIABLES"""
    
    server, on_prem, site, src_id, app, database, batch_size = item['Server'], int(item.get('OnPrem', '0') if item.get('OnPrem', '0').isdigit() else '0'), item['SiteCode'].upper(), item['SourceID'], item['AppName'].upper(), item['Database'].upper(), int(item.get('BatchSize', '10000') if item.get('BatchSize', '100000').isdigit() else '10000')
    domain = '.fmi.com' if on_prem else ''
    server, *port = server.split(',')
    port = port[0].strip() if port else '1433'
    server = server.lower().strip().rstrip(domain) + domain + ',' + port
    odbc_conn_str = f"Driver={{ODBC Driver 18 for SQL Server}};Server={server};Database={database};Authentication={'ActiveDirectoryIntegrated;Encrypt=no;' if on_prem else 'ActiveDirectoryMsi;'}MARS_Connection=yes;"

    """RETRIEVE DATA"""

    query = re.sub(r'from\s+([\w\[\]]+)\.([\w\[\]]+)', lambda x: 'from ' + '.'.join(map(lambda x: '[' + x.strip('[]') + ']', [x.group(1), x.group(2)])), query, flags=re.IGNORECASE) # account for reserved keywords using brackets
    schema, table = map(lambda x: x.strip('[]').upper(), *re.findall(r'from\s+([\w\[\]]+)\.([\w\[\]]+)', query, re.IGNORECASE))
    
    async with aioodbc.connect(dsn=odbc_conn_str) as sql_conn:
        batches = mssql_query_batch(sql_conn, query, batch_size)
        batch_no, proc_rows, has_data = 1, 0, False

        async for batch in batches:
            has_data = True
            batch = [{k.upper(): b64encode(v).decode('utf-8') if isinstance(v, bytes) else v for k, v in row.items()} for row in batch] # uppercase columns & align with sql triggers behavior
            changes = [dict({'ORIG_SRC_ID': src_id, 'SITE_CODE': site, **row, 'DW_DML_TYPE': 'I'}) for row in batch]
    
            """UPLOAD BLOB FILES"""

            blob_name = '/'.join([site, app, database, schema, table, f'{invocation_id}_{batch_no}.csv.gz'])
            await upload_blob(container_client, blob_name, changes)
            batch_no += 1
            proc_rows += len(changes)
            async with lock:
                results[f'{schema}.{table}'] = f'{proc_rows} rows processed in total'
                item['Status'], item['Result'] = 'In Progress', json.dumps(results, indent=4)
                item['ElapsedMins'] = round((time.perf_counter() - counter)/60, 4)
                await table_client.upsert_entity(item, 'replace')
            logging.info(f"Uploaded {len(changes)} Inserts to {blob_name}")
    
    if not has_data:
        async with lock:
            results[f'{schema}.{table}'] = 'Rows not found'
            item['Status'], item['Result'] = 'In Progress', json.dumps(results, indent=4)
            item['ElapsedMins'] = round((time.perf_counter() - counter)/60, 4)
            await table_client.upsert_entity(item, 'replace')
