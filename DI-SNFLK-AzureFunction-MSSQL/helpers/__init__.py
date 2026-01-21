import os
import json
import logging
import asyncio

import pyodbc
import aiohttp
from aiohttp import ClientResponseError
from azure.identity.aio import DefaultAzureCredential, ClientSecretCredential
from azure.keyvault.secrets.aio import SecretClient

"""REDUCE LOGGING"""

def reduce_logging():
    logging.getLogger('azure.core.pipeline.policies.http_logging_policy').setLevel(logging.WARNING)
    logging.getLogger("azure.identity").setLevel(logging.WARNING)
    logging.getLogger("azure.eventhub").setLevel(logging.WARNING)

"""REST FUNCTIONS"""

def backoff(delay=1, retries=5):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            current_retry = 0
            current_delay = delay
            while current_retry < retries:
                try:
                    return await func(*args, **kwargs)
                except Exception as ex:
                    current_retry += 1
                    if current_retry >= retries or (hasattr(ex, 'status') and ex.status in (408, 422)):
                        raise ex
                    logging.info(f"Retrying request {kwargs}")
                    await asyncio.sleep(current_delay)
                    current_delay *= 2
        return wrapper
    return decorator

@backoff(delay=1, retries=5)
async def send_request(url, token, data=None, login_timeout=30, conn_timeout=300):
    post = True if data is not None else False
    data = json.dumps(data) if isinstance(data, dict) else data

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    timeout = aiohttp.ClientTimeout(sock_connect=login_timeout, sock_read=conn_timeout)

    async with aiohttp.ClientSession(headers=headers, raise_for_status=snowflake_error_handling, timeout=timeout) as session:
        async with session.post(url, data=data) if post else session.get(url) as response:
            result = await response.json()
            return result

"""AZURE KEYVAULT"""

async def get_secret(vault, secret):
    KVUri = f"https://{vault}.vault.azure.net"
    async with DefaultAzureCredential(exclude_workload_identity_credential=True, exclude_developer_cli_credential=True, exclude_environment_credential=True, exclude_shared_token_cache_credential=True, managed_identity_client_id=None, additionally_allowed_tenants="*") as credential:
        async with SecretClient(vault_url=KVUri, credential=credential) as client:
            retrieved_secret = await client.get_secret(secret)
            return retrieved_secret.value

"""SNOWFLAKE SQL API"""

async def get_oauth_token(scope, tenant_id, client_id, client_secret):
    """
    Function to digest variables related to Azure Authentication
    """
    # async with DefaultAzureCredential(exclude_workload_identity_credential=True, exclude_developer_cli_credential=True, exclude_managed_identity_credential=True, exclude_shared_token_cache_credential=True, additionally_allowed_tenants="*") as credential:
    async with ClientSecretCredential(tenant_id=tenant_id, client_id=client_id, client_secret=client_secret, additionally_allowed_tenants="*") as credential:
        token = await credential.get_token(scope)
        return token.token

async def snowflake_error_handling(response):
    if response.status < 400:
        result = await response.json()
        return result
    else:
        raise ClientResponseError(request_info=response.request_info, history=None, status=response.status, message=await response.text())

async def submit_query_snowflake(token, conn_params=None, query=None, timeout=60*10):
    """
    Function to retrieve data from Snowflake using the SQL API
        Supports only individual queries
        Snowflake asynchronously process requests that take longer than 45 seconds. In such cases, the client will poll the query status until it completes
        Once the first response is received, the client will retrieve additional partitions until all results are received
    """
    
    # Initial request
    url = "https://fcx.west-us-2.azure.snowflakecomputing.com/api/v2/statements?async=true"
    data = {
        "statement": query,
        "timeout": timeout,
        "database": conn_params.get('database'),
        "schema": conn_params.get('schema'),
        "warehouse": conn_params.get('warehouse'),
        "role": conn_params.get('role'),
        "parameters": {
            "DATE_OUTPUT_FORMAT": "YYYY-MM-DD",
            "TIME_OUTPUT_FORMAT": "HH24:MI:SS",
            "TIMESTAMP_NTZ_OUTPUT_FORMAT": "YYYY-MM-DD HH24:MI:SS.FF3",
            "TIMESTAMP_OUTPUT_FORMAT": "YYYY-MM-DD HH24:MI:SS.FF3 TZHTZM",
            "TIMESTAMP_LTZ_OUTPUT_FORMAT": "YYYY-MM-DD HH24:MI:SS.FF3 TZHTZM",
            "TIMESTAMP_TZ_OUTPUT_FORMAT": "YYYY-MM-DD HH24:MI:SS.FF3 TZHTZM",
            "BINARY_OUTPUT_FORMAT": "HEX"
        }
    }
    response = await send_request(url, token, data=data, conn_timeout=timeout)
    
    handle = response['statementHandle']
    results = await get_results_snowflake(token, handle=handle, timeout=timeout)

    return results

async def get_results_snowflake(token, timeout=60*10, handle=None, partition=None):
    url = f"https://fcx.west-us-2.azure.snowflakecomputing.com/api/v2/statements/{handle}{f'?partition={partition}' if partition else ''}"
    response = await send_request(url, token, conn_timeout=timeout)
    
    # Get initial results
    rows = []
    if 'resultSetMetaData' in response and 'data' in response:
        cols = [item['name'] for item in response['resultSetMetaData']['rowType']]
        # types = [item['type'] for item in response['resultSetMetaData']['rowType']]
        rows += response['data']
        logging.info(f"Received data from first Partition")
        
        # Gather remaining partition results
        partitions = range(1, len(response['resultSetMetaData']['partitionInfo']))
        if partitions:
            tasks = []
            handle = response['statementHandle']
            tasks += [asyncio.create_task(get_results_snowflake(token, handle=handle, partition=partition, timeout=timeout)) for partition in partitions]
            try:
                results = await asyncio.gather(*tasks)
                for res in results:
                    rows += res
            except Exception as ex:
                for task in tasks:
                    task.cancel()
                raise ex
        
        results = [dict(zip(cols, row)) for row in rows]
        return results
    # Return remaining partition results
    elif 'data' in response:
        logging.info(f"Received data from Partition {partition}")
        return response['data']
    # Wait for data
    else:
        logging.info("Waiting for query to complete")
        await asyncio.sleep(5)
        handle = response['statementHandle']
        return await get_results_snowflake(token, handle=handle, timeout=timeout)

async def cancel_query_snowflake(token, timeout=60*10, handle=None):
    url = f"https://fcx.west-us-2.azure.snowflakecomputing.com/api/v2/statements/{handle}/cancel"
    await send_request(url, token, data={}, conn_timeout=timeout)

"""MSSQL Functions"""

async def get_column_info(conn, schema, table):
    query = f"""
        SELECT
            UPPER(C.COLUMN_NAME) AS COLUMN_NAME,
            UPPER(CASE WHEN C.DATA_TYPE in ('decimal', 'numeric') THEN CONCAT(C.DATA_TYPE, '(', C.NUMERIC_PRECISION, ', ', C.NUMERIC_SCALE, ')') WHEN C.DATA_TYPE in ('nvarchar', 'varchar', 'char') THEN CONCAT(C.DATA_TYPE, '(', IIF(C.CHARACTER_MAXIMUM_LENGTH=-1, 'max', STR(C.CHARACTER_MAXIMUM_LENGTH)), ')') ELSE C.DATA_TYPE END) AS DATA_TYPE,
            IIF(CU.CONSTRAINT_NAME IS NULL, 0, 1) AS PRIMARY_KEY,
			IIF(IS_NULLABLE = 'YES', 1, 0) AS NULLABLE
        FROM INFORMATION_SCHEMA.COLUMNS AS C
        LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
        ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND C.TABLE_SCHEMA=TC.TABLE_SCHEMA AND C.TABLE_NAME=TC.TABLE_NAME
        LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS CU
        ON TC.CONSTRAINT_NAME = CU.CONSTRAINT_NAME AND C.TABLE_SCHEMA=CU.TABLE_SCHEMA AND C.TABLE_NAME=CU.TABLE_NAME AND C.COLUMN_NAME=CU.COLUMN_NAME
        WHERE UPPER(C.TABLE_SCHEMA) = UPPER(?) AND UPPER(C.TABLE_NAME) = UPPER(?)
        ORDER BY C.ORDINAL_POSITION;
    """
    column_info = await mssql_query_all(conn, query, schema, table)
    column_types = [tuple(col.values()) for col in column_info]
    return column_types

async def mssql_create_table_type(conn, column_info, tt_schema, tt_table):
    query = f"""
        IF NOT EXISTS (
            SELECT 1
            FROM sys.types t
            JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE t.name = ? AND s.name = ? AND t.is_table_type = 1
        )
        BEGIN
            CREATE TYPE [{tt_schema}].[{tt_table}] AS TABLE
            (
                {', '.join([f"[{col}] {tp}" for col, tp, _, _ in column_info] + [''])}
                PRIMARY KEY NONCLUSTERED
                (
                    {', '.join([f"[{col}]" for col, _, pk, _ in column_info if pk])}
                )
            )
            WITH (MEMORY_OPTIMIZED = ON)
        END
    """

    async with conn.cursor() as cur:
        await cur.execute(query, tt_schema, tt_table)

async def mssql_query_all(conn, query, *args):
    async with conn.cursor() as cur:
        await cur.execute(query, *args)
        cols = [col[0] for col in cur.description]
        rows = await cur.fetchall()
        return [dict(zip(cols, row)) for row in rows]

async def mssql_query_batch(conn, query, batch_size, *args):
    cur = await conn.cursor()
    try:
        await cur.execute(query, *args)
        cols = [col[0] for col in cur.description]
        while True:
            rows = await cur.fetchmany(batch_size)
            if not rows:
                break
            yield [dict(zip(cols, row)) for row in rows]
    finally:
        await cur.close()

async def mssql_insert(conn, data, table_type, table, column_info):
    """Upserts a dict to a SQL Server table."""

    source_columns = set(data[0].keys())
    target_columns = {col for col, _, _, _ in column_info}.intersection(source_columns)
    not_nullable = {col for col, _, _, nul in column_info if not nul}
    
    if not target_columns:
        raise ValueError(f"No columns to insert in table {table}")
    if not not_nullable.issubset(target_columns):
        raise ValueError(f"Not nullable columns missing from data: {not_nullable.difference(target_columns)}")

    rows, chunk_size = 0, 10000
    
    async with conn.cursor() as cur:
        # cur.fast_executemany = True
        # cur.setinputsizes([(pyodbc.SQL_WVARCHAR, 0, 0)])

        # # Direct Bulk Load

        # query = f"""
        #     WITH CTE AS (SELECT * FROM OPENJSON(?) WITH ({", ".join([f"[{col}] {tp}" for col, tp, _, _ in column_info if col in target_columns])}))
        #     INSERT INTO {table} ({", ".join([f"[{col}]" for col in target_columns])})
        #     SELECT {", ".join([f"[{col}]" for col in target_columns])} FROM CTE;
        # """

        # for start, end in [(i, min(i + chunk_size, len(data))) for i in range(0, len(data), chunk_size)]:
        #     chunk = data[start:end]
        #     await cur.execute(query, json.dumps(chunk))
        #     await cur.commit()
        #     rows += cur.rowcount
        #     await asyncio.sleep(1)

        # # TempDB Bulk Load
        
        # # Create Temp Table
        # query = f"""
        #     SELECT *
        #     INTO #temp_table
        #     FROM {table}
        #     WHERE 0 = 1
        # """

        # await cur.execute(query)

        # # Bulk Load Temp Table
        # query = f"""
        #     WITH CTE AS (SELECT * FROM OPENJSON(?) WITH ({", ".join([f"[{col}] {tp}" for col, tp, _, _ in column_info if col in target_columns])}))
        #     INSERT INTO #temp_table ({", ".join([f"[{col}]" for col in target_columns])})
        #     SELECT {", ".join([f"[{col}]" for col in target_columns])} FROM CTE;
        # """

        # for start, end in [(i, min(i + chunk_size, len(data))) for i in range(0, len(data), chunk_size)]:
        #     chunk = data[start:end]
        #     await cur.execute(query, json.dumps(chunk))
        #     await cur.commit()
        #     rows += cur.rowcount
        #     await asyncio.sleep(1)
    
        # # Bulk Load Target Table
        # query = f"""
        #     INSERT INTO {table}
        #     SELECT * FROM #temp_table;
        # """
        # await cur.execute(query)
        # await cur.commit()
        
        # In-Memory Bulk Load
        
        query = f"""
            -- Create Table Variable
            DECLARE @table_var {table_type};
            -- Bulk Load Table Variable
            WITH CTE AS (SELECT * FROM OPENJSON(?) WITH ({", ".join([f"[{col}] {tp}" for col, tp, _, _ in column_info if col in target_columns])}))
            INSERT INTO @table_var ({", ".join([f"[{col}]" for col in target_columns])})
            SELECT {", ".join([f"[{col}]" for col in target_columns])} FROM CTE;
            -- Bulk Load Target Table
            INSERT INTO {table}
            SELECT * FROM @table_var;
        """

        for start, end in [(i, min(i + chunk_size, len(data))) for i in range(0, len(data), chunk_size)]:
            chunk = data[start:end]
            await cur.execute(query, json.dumps(chunk))
            await cur.commit()
            rows += cur.rowcount
            await asyncio.sleep(1)

    return rows

async def mssql_upsert(conn, data, table, column_info):
    """Upserts a dict to a SQL Server table."""

    source_columns = set(data[0].keys())
    target_columns = {col for col, _, _, _ in column_info}.intersection(source_columns)
    primary_keys = {col for col, _, pk, _ in column_info if pk}
    not_nullable = {col for col, _, _, nul in column_info if not nul}
    
    if not primary_keys:
        raise ValueError(f"No primary keys defined in table {table}")
    if not primary_keys.issubset(target_columns):
        raise ValueError(f"Primary key columns missing from data: {primary_keys.difference(target_columns)}")
    if not target_columns:
        raise ValueError(f"No columns to insert in table {table}")
    if not target_columns.difference(primary_keys):
        raise ValueError(f"No columns to update in table {table}")
    if not not_nullable.issubset(target_columns):
        raise ValueError(f"Not nullable columns missing from data: {not_nullable.difference(target_columns)}")

    # Construct the MERGE statement
    query = f"""
        WITH CTE AS (SELECT * FROM OPENJSON(?) WITH ({", ".join([f"[{col}] {tp}" for col, tp, _, _ in column_info if col in target_columns])}))
        MERGE INTO {table} AS target
        USING CTE AS source
            ON ({" AND ".join([f"target.[{col}] = source.[{col}]" for col in primary_keys])})
        WHEN MATCHED THEN
            UPDATE SET {", ".join([f"target.[{col}] = source.[{col}]" for col in target_columns.difference(primary_keys)])}
        WHEN NOT MATCHED THEN
            INSERT ({", ".join([f"[{col}]" for col in target_columns])})
            VALUES ({", ".join([f"source.[{col}]" for col in target_columns])});
    """

    rows, chunk_size = 0, 10000
    
    async with conn.cursor() as cur:
        cur.fast_executemany = True
        # cur.setinputsizes([(pyodbc.SQL_WVARCHAR, 0, 0)])
        for start, end in [(i, min(i + chunk_size, len(data))) for i in range(0, len(data), chunk_size)]:
            chunk = data[start:end]
            await cur.execute(query, json.dumps(chunk))
            await cur.commit()
            rows += cur.rowcount
            await asyncio.sleep(1)

    return rows

async def mssql_execute(conn, query, *args):
    async with conn.cursor() as cur:
        await cur.execute(query, *args)
        await cur.commit()
        return cur.rowcount