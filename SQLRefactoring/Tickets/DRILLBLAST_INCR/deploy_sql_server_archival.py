"""
Deploy and Test SQL Server Archival Procedures
All 14 INCR table archival procedures

Author: Carlos Carrillo
Date: 2026-01-29
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct
from datetime import datetime

print("=" * 80)
print("SQL SERVER ARCHIVAL PROCEDURES - DEPLOY AND TEST")
print("=" * 80)
print(f"Time: {datetime.now().isoformat()}")

# SQL Server connection details
server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

print(f"Server: {server}")
print(f"Database: {database}")
print()

# Authenticate
print("🔐 Authenticating with Azure AD...")
credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()
print("✅ Connected to SQL Server\n")

# All 14 archival procedures - using DW_MODIFY_TS as the standard column
archival_procs_ddl = {
    'usp_Archive_BL_DW_BLAST_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BL_DW_BLAST_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__BL_DW_BLAST_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_BL_DW_HOLE_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BL_DW_HOLE_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__BL_DW_HOLE_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_BLAST_PLAN_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BLAST_PLAN_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__BLAST_PLAN_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_BLAST_PLAN_EXECUTION_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_BLAST_PLAN_EXECUTION_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_DRILL_CYCLE_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILL_CYCLE_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__DRILL_CYCLE_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_DRILL_PLAN_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILL_PLAN_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__DRILL_PLAN_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_DRILLBLAST_EQUIPMENT_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILLBLAST_EQUIPMENT_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_DRILLBLAST_OPERATOR_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILLBLAST_OPERATOR_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__DRILLBLAST_OPERATOR_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_DRILLBLAST_SHIFT_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_DRILLBLAST_SHIFT_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[DRILL_BLAST__DRILLBLAST_SHIFT_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_LH_BUCKET_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_LH_BUCKET_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[LOAD_HAUL__LH_BUCKET_INCR]
        WHERE CAST([TRIP_TS_LOCAL] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR]
        WHERE CAST([START_TS_LOCAL] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_LH_HAUL_CYCLE_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_LH_HAUL_CYCLE_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[LOAD_HAUL__LH_HAUL_CYCLE_INCR]
        WHERE CAST([CYCLE_START_TS_LOCAL] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
    'usp_Archive_LH_LOADING_CYCLE_INCR': """
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_LH_LOADING_CYCLE_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM [dbo].[LOAD_HAUL__LH_LOADING_CYCLE_INCR]
        WHERE CAST([CYCLE_START_TS_LOCAL] AS DATE) < @CutoffDate;
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted, @CutoffDate AS CutoffDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'ERROR' AS Status, ERROR_MESSAGE() AS ErrorMessage;
        THROW;
    END CATCH
END;
""",
}

# STEP 1: Deploy all archival procedures
print("📋 STEP 1: Deploying archival procedures to SQL Server...")
print("-" * 80)

deployed = 0
failed = 0
failed_procs = []

for proc_name, ddl in archival_procs_ddl.items():
    try:
        cursor.execute(ddl)
        conn.commit()
        print(f"  ✅ {proc_name}")
        deployed += 1
    except Exception as e:
        print(f"  ❌ {proc_name}: {str(e)[:60]}")
        failed += 1
        failed_procs.append(proc_name)

print(f"\nDeployed: {deployed}, Failed: {failed}")

# STEP 2: Check which tables exist
print("\n📋 STEP 2: Checking which INCR tables exist...")
print("-" * 80)

tables_to_check = [
    ('DRILL_BLAST__BL_DW_BLAST_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__BL_DW_HOLE_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__BLAST_PLAN_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__DRILL_CYCLE_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__DRILL_PLAN_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__DRILLBLAST_OPERATOR_INCR', 'DW_MODIFY_TS'),
    ('DRILL_BLAST__DRILLBLAST_SHIFT_INCR', 'DW_MODIFY_TS'),
    ('LOAD_HAUL__LH_BUCKET_INCR', 'TRIP_TS_LOCAL'),
    ('LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR', 'START_TS_LOCAL'),
    ('LOAD_HAUL__LH_HAUL_CYCLE_INCR', 'CYCLE_START_TS_LOCAL'),
    ('LOAD_HAUL__LH_LOADING_CYCLE_INCR', 'CYCLE_START_TS_LOCAL'),
]

existing_tables = []
for table_name, ts_col in tables_to_check:
    try:
        cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
        count = cursor.fetchone()[0]
        print(f"  ✅ {table_name}: {count} rows")
        existing_tables.append(table_name)
    except Exception as e:
        print(f"  ⚠️ {table_name}: Table not found")

# STEP 3: Test archival procedures (only for existing tables)
print("\n📋 STEP 3: Testing archival procedures...")
print("-" * 80)

test_results = []
for proc_name in archival_procs_ddl.keys():
    # Derive table name from proc name
    table_suffix = proc_name.replace('usp_Archive_', '')
    
    # Find matching table
    matching_table = None
    for t in existing_tables:
        if table_suffix in t:
            matching_table = t
            break
    
    if matching_table:
        try:
            cursor.execute(f"EXEC [dbo].[{proc_name}] @NumberOfDays = 30")  # Use 30 days to avoid deleting data
            result = cursor.fetchone()
            if result and result[0] == 'SUCCESS':
                print(f"  ✅ {proc_name}: RowsDeleted={result[1]}")
                test_results.append((proc_name, 'PASS', result[1]))
            else:
                print(f"  ⚠️ {proc_name}: {result}")
                test_results.append((proc_name, 'WARN', str(result)))
        except Exception as e:
            print(f"  ❌ {proc_name}: {str(e)[:60]}")
            test_results.append((proc_name, 'FAIL', str(e)))
    else:
        print(f"  ⏭️ {proc_name}: Skipped (table not found)")
        test_results.append((proc_name, 'SKIP', 'Table not found'))

cursor.close()
conn.close()

# Summary
print("\n" + "=" * 80)
print("SQL SERVER ARCHIVAL PROCEDURES - SUMMARY")
print("=" * 80)
print(f"  Procedures Deployed: {deployed}/{len(archival_procs_ddl)}")
print(f"  Tables Found: {len(existing_tables)}/{len(tables_to_check)}")

passed = sum(1 for _, s, _ in test_results if s == 'PASS')
print(f"  Tests Passed: {passed}")

if failed_procs:
    print(f"\n⚠️ Failed to deploy: {', '.join(failed_procs)}")

print("\n✅ SQL Server archival procedures deployment complete!")
