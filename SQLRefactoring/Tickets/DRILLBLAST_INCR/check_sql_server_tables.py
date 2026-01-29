"""
Check existing tables in SQL Server SNOWFLAKE_WG database
to understand the current state and naming convention
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

print("=" * 80)
print("SQL SERVER TABLE DISCOVERY")
print("=" * 80)

credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

# Find all tables with INCR or similar patterns
print("\n📋 Searching for INCR-related tables...")
print("-" * 60)

cursor.execute("""
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE' 
    AND TABLE_SCHEMA = 'dbo'
    AND (TABLE_NAME LIKE '%INCR%' 
         OR TABLE_NAME LIKE '%DRILL%' 
         OR TABLE_NAME LIKE '%BLAST%'
         OR TABLE_NAME LIKE '%LOAD_HAUL%'
         OR TABLE_NAME LIKE '%LH_%')
    ORDER BY TABLE_NAME
""")

tables = cursor.fetchall()
print(f"\nFound {len(tables)} matching tables:\n")

for row in tables:
    table_name = row[0]
    cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
    count = cursor.fetchone()[0]
    print(f"  {table_name}: {count:,} rows")

# Also check for all tables to see full list
print("\n\n📋 All tables in database...")
print("-" * 60)

cursor.execute("""
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE' 
    AND TABLE_SCHEMA = 'dbo'
    ORDER BY TABLE_NAME
""")

all_tables = cursor.fetchall()
print(f"\nTotal tables: {len(all_tables)}\n")

for row in all_tables[:50]:  # Limit to first 50
    table_name = row[0]
    cursor.execute(f"SELECT COUNT(*) FROM [dbo].[{table_name}]")
    count = cursor.fetchone()[0]
    print(f"  {table_name}: {count:,} rows")

if len(all_tables) > 50:
    print(f"\n  ... and {len(all_tables) - 50} more tables")

cursor.close()
conn.close()
