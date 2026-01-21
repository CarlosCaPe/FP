"""
Get DDL of Hidayath's LOAD_HAUL types from PROD to compare
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

# Get Azure AD token
print("Authenticating with Azure AD...")
credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')

# PROD server (where Hidayath's types are)
server = 'azwp22midbx02.8232c56adfdf.database.windows.net'
database = 'ConnectedOperations'

print(f"Connecting to PROD: {server}/{database}\n")

# Build connection
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})

cursor = conn.cursor()

# Get all IMO table types
cursor.execute("""
    SELECT t.name
    FROM sys.types t
    WHERE t.is_table_type = 1 AND t.name LIKE '%IMO%'
    ORDER BY t.name
""")

print("=" * 80)
print("IMO TABLE TYPES IN PROD")
print("=" * 80)

types = [row.name for row in cursor.fetchall()]
for t in types:
    print(f"  - [dbo].[{t}]")

# Get DDL for one of Hidayath's types to compare structure
print("\n" + "=" * 80)
print("DDL OF HIDAYATH's LOAD_HAUL__LH_BUCKET_IMO (for comparison)")
print("=" * 80)

cursor.execute("""
    SELECT t.name, tt.type_table_object_id
    FROM sys.types t
    JOIN sys.table_types tt ON t.user_type_id = tt.user_type_id
    WHERE t.name = 'LOAD_HAUL__LH_BUCKET_IMO' AND t.is_table_type = 1
""")

row = cursor.fetchone()
if row:
    cursor.execute("""
        SELECT 
            c.name as column_name,
            tp.name as data_type,
            c.max_length,
            c.precision,
            c.scale,
            c.is_nullable
        FROM sys.columns c
        JOIN sys.types tp ON c.user_type_id = tp.user_type_id
        WHERE c.object_id = ?
        ORDER BY c.column_id
    """, row.type_table_object_id)
    
    columns = cursor.fetchall()
    print(f"Columns: {len(columns)}\n")
    
    ddl_lines = ["CREATE TYPE [dbo].[LOAD_HAUL__LH_BUCKET_IMO] AS TABLE ("]
    for i, col in enumerate(columns):
        col_name = col.column_name
        data_type = col.data_type
        max_len = col.max_length
        precision = col.precision
        scale = col.scale
        nullable = "NULL" if col.is_nullable else "NOT NULL"
        
        if data_type in ('nvarchar', 'varchar', 'nchar', 'char'):
            if max_len == -1:
                type_str = f"{data_type.upper()}(MAX)"
            else:
                actual_len = max_len // 2 if data_type.startswith('n') else max_len
                type_str = f"{data_type.upper()}({actual_len})"
        elif data_type in ('decimal', 'numeric'):
            type_str = f"{data_type.upper()}({precision},{scale})"
        else:
            type_str = data_type.upper()
        
        comma = "," if i < len(columns) - 1 else ""
        ddl_lines.append(f"    [{col_name}] {type_str} {nullable}{comma}")
    
    ddl_lines.append(");")
    print("\n".join(ddl_lines))
else:
    print("NOT FOUND")

conn.close()
print("\nDone!")
