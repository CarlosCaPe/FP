"""
Comparar y crear objetos SQL Azure para LH_BUCKET y LH_LOADING_CYCLE
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

print('=' * 80)
print('COMPARACIÓN SQL AZURE: Tablas vs Table Types')
print('=' * 80)

comparisons = [
    ('LOAD_HAUL__LH_BUCKET', 'LOAD_HAUL__LH_BUCKET_IMO'),
    ('LOAD_HAUL__LH_LOADING_CYCLE', 'LOAD_HAUL__LH_LOADING_CYCLE_IMO'),
]

for table_name, type_name in comparisons:
    print(f'\n📋 {table_name}:')
    
    # Columnas de la tabla
    cursor.execute(f"""
        SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = '{table_name}' AND TABLE_SCHEMA = 'dbo'
    """)
    table_cols = cursor.fetchone()[0]
    
    # Columnas del Table Type
    cursor.execute(f"""
        SELECT COUNT(*) FROM sys.columns c
        JOIN sys.table_types tt ON c.object_id = tt.type_table_object_id
        WHERE tt.name = '{type_name}'
    """)
    type_cols = cursor.fetchone()[0]
    
    print(f'   Tabla: {table_cols} columnas')
    print(f'   Type:  {type_cols} columnas')
    
    if table_cols == type_cols:
        print('   ✅ Coinciden')
    else:
        print(f'   ⚠️ Diferencia: {abs(table_cols - type_cols)} columnas')

# Check if procedures exist
print('\n' + '=' * 80)
print('PROCEDURES EXISTENTES:')
print('=' * 80)

cursor.execute("""
    SELECT name FROM sys.procedures 
    WHERE name LIKE '%LH_BUCKET%' OR name LIKE '%LH_LOADING%' OR name LIKE '%DRILL_CYCLE%'
    ORDER BY name
""")
procs = cursor.fetchall()
if procs:
    for p in procs:
        print(f'   ✅ {p[0]}')
else:
    print('   ❌ No hay procedures para estos pipelines')

conn.close()
