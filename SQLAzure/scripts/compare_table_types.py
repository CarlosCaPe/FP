"""
Compare DRILL_CYCLE_IMO with Hidayath's LOAD_HAUL types
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

# Get Azure AD token
print("Authenticating with Azure AD...")
credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')

# DEV server
server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'ConnectedOperations'

print(f"Connecting to DEV: {server}/{database}\n")

# Build connection
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})

cursor = conn.cursor()

# Get all table types of interest
types_to_compare = [
    'LOAD_HAUL__LH_BUCKET_IMO',
    'LOAD_HAUL__LH_LOADING_CYCLE_IMO', 
    'DRILL_CYCLE_IMO',
    'tt_DRILL_CYCLE'
]

print("=" * 80)
print("COMPARING TABLE TYPES")
print("=" * 80)

for type_name in types_to_compare:
    cursor.execute("""
        SELECT t.name, tt.type_table_object_id
        FROM sys.types t
        JOIN sys.table_types tt ON t.user_type_id = tt.user_type_id
        WHERE t.name = ? AND t.is_table_type = 1
    """, type_name)
    
    row = cursor.fetchone()
    if not row:
        print(f"\n[{type_name}] - NOT FOUND")
        continue
    
    print(f"\n{'=' * 80}")
    print(f"[dbo].[{type_name}]")
    print("=" * 80)
    
    # Get columns for this table type
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
    print(f"Columns: {len(columns)}")
    print("-" * 80)
    
    # Generate DDL
    ddl_lines = [f"CREATE TYPE [dbo].[{type_name}] AS TABLE ("]
    for i, col in enumerate(columns):
        col_name = col.column_name
        data_type = col.data_type
        max_len = col.max_length
        precision = col.precision
        scale = col.scale
        nullable = "NULL" if col.is_nullable else "NOT NULL"
        
        # Format data type
        if data_type in ('nvarchar', 'varchar', 'nchar', 'char'):
            if max_len == -1:
                type_str = f"{data_type.upper()}(MAX)"
            else:
                # nvarchar uses 2 bytes per char
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

# Test if DRILL_CYCLE_IMO can be used
print("\n" + "=" * 80)
print("TESTING DRILL_CYCLE_IMO USAGE")
print("=" * 80)

try:
    cursor.execute("""
        DECLARE @test [dbo].[DRILL_CYCLE_IMO];
        SELECT COUNT(*) as col_count FROM (
            SELECT * FROM @test
        ) t;
    """)
    result = cursor.fetchone()
    print(f"✅ SUCCESS: DRILL_CYCLE_IMO can be declared and used!")
    print(f"   Table variable has {len(types_to_compare)} accessible structure")
except Exception as e:
    print(f"❌ ERROR: {e}")

conn.close()
print("\nDone!")
