# DI-SNFLK-AzureFunction-MSSQL

## Overview
Azure Functions that sync data from **Snowflake**  **SQL Azure** for the Connected Operations platform.

**Repository**: FCX-Developers/DI-SNFLK-AzureFunction-MSSQL  
**Function App**: usesflksqlnatestfctapp01  
**Contact**: Bruno Garcia Tejada (@bgarciat_FMI)

## Architecture

`
          
   Snowflake     >  Azure Function  >  SQL Azure Database     
   PROD_API_REF         (Timer Trigger)        ConnectedOperations    
   Views/Tables         Every 5 min            Tables                 
          
                                                         
                                                         
   Snowflake SQL API    Azure Key Vault          In-Memory Table Types
   OAuth Token          (Credentials)            MERGE/UPSERT operations
`

## Environments

| Env  | Snowflake DB   | SQL Server                                          | Warehouse           |
|------|----------------|-----------------------------------------------------|---------------------|
| DEV  | DEV_API_REF    | azwd22midbx02.eb8a77f2eea6.database.windows.net     | WH_BATCH_FUSE_NONPROD |
| TEST | TEST_API_REF   | azwt22midbx02.9959d3e6fe6e.database.windows.net     | WH_BATCH_FUSE_NONPROD |
| PROD | PROD_API_REF   | azwp22midbx02.8232c56adfdf.database.windows.net     | WH_BATCH_FUSE       |

## PR #86 - Enabled API_REF Functions
**Author**: Vikas Uttam (@vuttam_FMI)  
**Date**: Jan 16, 2026

Changed CONOPS_API_REF_CONNECTED_OPERATIONS_DISABLED from 	rue to alse in production.

## Functions (CONNECTED_OPERATIONS)

38 timer-triggered functions that sync every 5 minutes:

| Category | Functions |
|----------|-----------|
| Mill | CR2_MILL, CRUSHER_STATUS, CRUSHER_THROUGHPUT |
| Drill | DRILL_UTILIZATION_* (9 sites), FR_DRILLING_SCORES |
| Load/Haul | LH_DUMP, LH_LOAD, LH_EQUIP_LIST, LH_OPER_TOTAL_SUM, LH_REASON |
| Equipment | EQUIPMENT_HOURLY_STATUS_* (9 sites), SHOVEL_ELEVATION |
| Operator | OPERATOR_CONSECUTIVE_WORKDAYS, OPERATOR_LOGOUT, OPERATOR_PERSONNEL_MAP, OPERATOR_TITLE |
| Other | DELTA_C, IOS_STOCKPILE_LEVELS, MMT_TRUCKLOAD_C, OEE, PIT_REASON, STATUS_EVENT |

## Data Flow (per function)

1. **Timer Trigger** fires every 5 minutes
2. **Get OAuth Token** from Azure Key Vault via App Registration
3. **Query Snowflake** via SQL API (async REST calls)
4. **Get Column Info** from target SQL table
5. **Truncate Staging Table** (sql_pre_cmd)
6. **Bulk Insert** using In-Memory Table Types (OPENJSON + Table Variable)
7. **Execute UPSERT Procedure** (sql_post_cmd)

## Example: CR2_MILL

`json
{
    "schedule": "0 */5 * * * *",
    "sf_query": "SELECT * FROM CR2_MILL",
    "sql_pre_cmd": "TRUNCATE TABLE [dbo].[CR2_MILL_STG_2]",
    "sql_table_type": "[dbo].[CR2_MILL_STG_2_IMO]",
    "sql_table": "[dbo].[CR2_MILL_STG_2]",
    "sql_post_cmd": "EXEC [dbo].[UPSERT_CONOPS_CR2_MILL_2]"
}
`

## Key Components

### helpers/__init__.py
- get_secret() - Retrieve secrets from Azure Key Vault
- get_oauth_token() - Get OAuth token for Snowflake
- submit_query_snowflake() - Async Snowflake SQL API queries
- get_column_info() - Get table column metadata
- mssql_insert() - Bulk insert with In-Memory Table Types
- mssql_upsert() - MERGE statement with OPENJSON
- mssql_execute() - Execute SQL commands

### batch_template/__init__.py
- Main Azure Function logic
- Handles watermarking for incremental loads
- Error handling with retries
- Uses FUSEWatermarks Azure Table for state management

### Bulk Load Strategy
Uses **In-Memory Table Types** for optimal performance:
`sql
DECLARE @table_var [dbo].[TableType];
WITH CTE AS (SELECT * FROM OPENJSON(@json) WITH (...))
INSERT INTO @table_var SELECT ... FROM CTE;
INSERT INTO [target_table] SELECT * FROM @table_var;
`

## Related Files in SQLAzure

| File | Description |
|------|-------------|
| schemas/PROD/ConnectedOperations/ | Target SQL tables extracted from Azure |
| schemas/PROD/SNOWFLAKE_WG/ | SNOWFLAKE_WG database schemas |

## Relationship to SQLRefactoring

The Azure Functions sync data TO the SQL Azure databases. Our SQLRefactoring work involves:
1. The **Snowflake views** that are the SOURCE of these syncs (PROD_API_REF.CONNECTED_OPERATIONS)
2. The INCR tables (LH_BUCKET_INCR, LH_LOADING_CYCLE_INCR) that feed into these views

## Links
- **Function App**: usesflksqlnatestfctapp01
- **Task Ticket**: SCTASK0488699
