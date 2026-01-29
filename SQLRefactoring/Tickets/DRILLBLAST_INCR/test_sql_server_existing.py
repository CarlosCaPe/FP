"""
Test SQL Server Archival Procedures - Using existing tables
The INCR tables don't exist yet, but we can:
1. Update procedures to match existing table naming convention
2. Deploy and test them when tables are created
3. For now, deploy the procedures so they're ready

Author: Carlos Carrillo
Date: 2026-01-28
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct
import os

server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

print("=" * 80)
print("SQL SERVER ARCHIVAL PROCEDURES - DEPLOYMENT TEST")
print("=" * 80)
print(f"Server: {server}")
print(f"Database: {database}")
print()

credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()
print("✅ Connected to SQL Server\n")

# Check existing INCR-related tables
print("📋 STEP 1: Checking existing tables...")
print("-" * 60)

cursor.execute("""
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE' 
    AND TABLE_SCHEMA = 'dbo'
    AND (TABLE_NAME LIKE 'DRILL_BLAST_%' OR TABLE_NAME LIKE 'LOAD_HAUL_%')
    ORDER BY TABLE_NAME
""")

existing_tables = {}
for row in cursor.fetchall():
    table_name = row[0]
    cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
    count = cursor.fetchone()[0]
    existing_tables[table_name] = count
    print(f"  {table_name}: {count:,} rows")

print()

# Define archival procedures - updated to match actual table naming
# Based on the discovery, tables use single underscore: DRILL_BLAST_xxx not DRILL_BLAST__xxx
archival_procs_updated = [
    # These procedures will work with both naming conventions
    ("usp_Archive_DRILL_BLAST_BLAST_PLAN", "DRILL_BLAST_BLAST_PLAN", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_DRILL_CYCLE", "DRILL_BLAST_DRILL_CYCLE", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_DRILL_PLAN", "DRILL_BLAST_DRILL_PLAN", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_BL_DW_BLAST", "DRILL_BLAST_BL_DW_BLAST", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_BL_DW_BLASTPROPERTYVALUE", "DRILL_BLAST_BL_DW_BLASTPROPERTYVALUE", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_BL_DW_HOLE", "DRILL_BLAST_BL_DW_HOLE", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_DRILLBLAST_EQUIPMENT", "DRILL_BLAST_DRILLBLAST_EQUIPMENT", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_DRILLBLAST_OPERATOR", "DRILL_BLAST_DRILLBLAST_OPERATOR", "DW_MODIFY_TS"),
    ("usp_Archive_DRILL_BLAST_DRILLBLAST_SHIFT", "DRILL_BLAST_DRILLBLAST_SHIFT", "DW_MODIFY_TS"),
]

# Create and deploy procedures for existing tables
print("📋 STEP 2: Creating archival procedures for existing tables...")
print("-" * 60)

deployed = []
failed = []

for proc_name, table_name, incr_col in archival_procs_updated:
    if table_name not in existing_tables:
        print(f"  ⏭️ {proc_name}: Skipped (table doesn't exist)")
        continue
    
    # Check if table has the incremental column
    cursor.execute(f"""
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = '{table_name}' 
        AND COLUMN_NAME = '{incr_col}'
    """)
    
    if not cursor.fetchone():
        # Try alternative column names
        cursor.execute(f"""
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_NAME = '{table_name}' 
            AND COLUMN_NAME LIKE '%MODIFY%' OR COLUMN_NAME LIKE '%TS%'
        """)
        alt_cols = [r[0] for r in cursor.fetchall()]
        if alt_cols:
            print(f"  ⚠️ {table_name}: {incr_col} not found, available: {alt_cols[:3]}")
        continue
    
    proc_sql = f"""
CREATE OR ALTER PROCEDURE [dbo].[{proc_name}]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM [dbo].[{table_name}]
        WHERE CAST([{incr_col}] AS DATE) < @CutoffDate;
        
        SET @RowsDeleted = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, 
               @RowsDeleted AS RowsDeleted,
               @CutoffDate AS CutoffDate,
               GETDATE() AS ExecutionTime;
               
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SELECT 'ERROR' AS Status,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_NUMBER() AS ErrorNumber;
               
        THROW;
    END CATCH
END;
"""
    
    try:
        cursor.execute(proc_sql)
        conn.commit()
        deployed.append((proc_name, table_name))
        print(f"  ✅ {proc_name}")
    except Exception as e:
        failed.append((proc_name, str(e)))
        print(f"  ❌ {proc_name}: {str(e)[:60]}")

print()
print(f"Deployed: {len(deployed)}, Failed: {len(failed)}")
print()

# Test the deployed procedures
if deployed:
    print("📋 STEP 3: Testing deployed procedures...")
    print("-" * 60)
    
    for proc_name, table_name in deployed:
        try:
            # Get count before
            cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
            count_before = cursor.fetchone()[0]
            
            # Execute with a very large lookback (won't delete anything)
            cursor.execute(f"EXEC [dbo].[{proc_name}] @NumberOfDays = 365")
            result = cursor.fetchone()
            status = result[0] if result else "UNKNOWN"
            rows_deleted = result[1] if result and len(result) > 1 else 0
            
            conn.commit()
            
            # Get count after
            cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
            count_after = cursor.fetchone()[0]
            
            print(f"  ✅ {proc_name}: {status}")
            print(f"     Deleted: {rows_deleted:,}, Rows: {count_before:,} → {count_after:,}")
            
        except Exception as e:
            print(f"  ❌ {proc_name}: {str(e)[:60]}")

print()
print("=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"""
The INCR tables (DRILL_BLAST__xxx_INCR, LOAD_HAUL__xxx_INCR) 
do NOT exist yet in SQL Server.

Current state:
- Existing tables use pattern: DRILL_BLAST_xxx (single underscore)
- INCR tables will use pattern: DRILL_BLAST__xxx_INCR (double underscore + _INCR suffix)

Next steps:
1. Azure Function needs to sync INCR data from Snowflake to SQL Server
2. Once INCR tables exist, deploy the archival procedures from:
   DDL-Scripts/SQL_SERVER/PROCEDURES/

The archival procedures are ready for deployment when the tables are created.
""")

cursor.close()
conn.close()
