"""
Verificar si las tablas tienen MEMORY_OPTIMIZED = ON en DEV
Y corregirlo si es necesario (DEV = OFF, PROD = ON)
"""
import pyodbc
import struct
from azure.identity import InteractiveBrowserCredential

# Configuración DEV
server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

# Obtener token de Azure AD
credential = InteractiveBrowserCredential()
token_bytes = credential.get_token("https://database.windows.net/.default").token.encode("UTF-16-LE")
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

# Conexión con token
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

print('=' * 80)
print('VERIFICANDO MEMORY_OPTIMIZED EN TABLAS - SNOWFLAKE_WG (DEV)')
print('=' * 80)

# Verificar tablas con memory optimized
cursor.execute("""
    SELECT 
        t.name AS table_name,
        t.is_memory_optimized
    FROM sys.tables t
    WHERE t.name IN ('DRILL_CYCLE', 'LOAD_HAUL__LH_BUCKET', 'LOAD_HAUL__LH_LOADING_CYCLE')
    ORDER BY t.name
""")

tables = cursor.fetchall()
print('\n📋 Estado actual de las tablas:')
for table in tables:
    status = '🔴 MEMORY_OPTIMIZED=ON (debe ser OFF en DEV)' if table[1] else '✅ MEMORY_OPTIMIZED=OFF (correcto para DEV)'
    print(f'   • {table[0]}: {status}')

# Verificar Table Types
print('\n📋 Table Types (no tienen memory_optimized, solo durability):')
cursor.execute("""
    SELECT 
        tt.name AS type_name,
        tt.is_memory_optimized
    FROM sys.table_types tt
    WHERE tt.name IN ('DRILL_BLAST__DRILL_CYCLE_IMO', 'LOAD_HAUL__LH_BUCKET_IMO', 'LOAD_HAUL__LH_LOADING_CYCLE_IMO')
    ORDER BY tt.name
""")

types = cursor.fetchall()
for t in types:
    status = '🔴 MEMORY_OPTIMIZED=ON' if t[1] else '✅ MEMORY_OPTIMIZED=OFF'
    print(f'   • {t[0]}: {status}')

print('\n' + '=' * 80)
print('NOTA: Según Vikas Uttam:')
print('  - DEV: NO memory optimized')
print('  - PROD: SÍ memory optimized')
print('=' * 80)

cursor.close()
conn.close()
