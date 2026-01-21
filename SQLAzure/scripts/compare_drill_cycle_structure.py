"""
Comparar estructura de tabla DRILL_CYCLE actual vs Table Type DRILL_BLAST__DRILL_CYCLE_IMO
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
print('COMPARACIÓN: DRILL_CYCLE table vs DRILL_BLAST__DRILL_CYCLE_IMO type')
print('=' * 80)

# Columnas de la tabla DRILL_CYCLE
cursor.execute("""
    SELECT COLUMN_NAME, DATA_TYPE 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'DRILL_CYCLE' AND TABLE_SCHEMA = 'dbo'
    ORDER BY ORDINAL_POSITION
""")
table_cols = {row[0]: row[1] for row in cursor.fetchall()}

# Columnas del Table Type DRILL_BLAST__DRILL_CYCLE_IMO
cursor.execute("""
    SELECT c.name, t.name as data_type
    FROM sys.columns c
    JOIN sys.types t ON c.user_type_id = t.user_type_id
    JOIN sys.table_types tt ON c.object_id = tt.type_table_object_id
    WHERE tt.name = 'DRILL_BLAST__DRILL_CYCLE_IMO'
    ORDER BY c.column_id
""")
type_cols = {row[0]: row[1] for row in cursor.fetchall()}

print(f'\n📋 Tabla DRILL_CYCLE: {len(table_cols)} columnas')
print(f'📦 Type DRILL_BLAST__DRILL_CYCLE_IMO: {len(type_cols)} columnas')

# Columnas solo en Type (faltan en tabla)
missing_in_table = set(type_cols.keys()) - set(table_cols.keys())
if missing_in_table:
    print(f'\n❌ FALTAN EN TABLA ({len(missing_in_table)}):')
    for col in sorted(missing_in_table):
        print(f'   + {col} ({type_cols[col]})')

# Columnas solo en Tabla (sobran)
extra_in_table = set(table_cols.keys()) - set(type_cols.keys())
if extra_in_table:
    print(f'\n⚠️ EXTRA EN TABLA ({len(extra_in_table)}):')
    for col in sorted(extra_in_table):
        print(f'   - {col} ({table_cols[col]})')

# Columnas comunes
common = set(table_cols.keys()) & set(type_cols.keys())
print(f'\n✅ COLUMNAS COMUNES: {len(common)}')

if not missing_in_table and not extra_in_table:
    print('\n🎉 ¡La tabla coincide perfectamente con el Type!')
else:
    print('\n⚠️ La tabla necesita ser actualizada para coincidir con el nuevo diseño INCR')

conn.close()
