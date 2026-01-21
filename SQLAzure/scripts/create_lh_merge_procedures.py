"""
Crear stored procedures de merge para LH_BUCKET y LH_LOADING_CYCLE
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
print('CREANDO STORED PROCEDURES PARA LH_BUCKET Y LH_LOADING_CYCLE')
print('=' * 80)

# ============================================================
# Función para generar procedure de merge dinámicamente
# ============================================================
def generate_merge_proc(table_name, type_name, pk_column):
    # Obtener columnas del table type
    cursor.execute(f"""
        SELECT c.name
        FROM sys.columns c
        JOIN sys.table_types tt ON c.object_id = tt.type_table_object_id
        WHERE tt.name = '{type_name}'
        ORDER BY c.column_id
    """)
    columns = [row[0] for row in cursor.fetchall()]
    
    # Columnas para UPDATE (excluir PK)
    update_cols = [c for c in columns if c != pk_column]
    update_set = ',\n            '.join([f'target.[{c}] = source.[{c}]' for c in update_cols])
    
    # Columnas para INSERT
    insert_cols = ', '.join([f'[{c}]' for c in columns])
    insert_vals = ', '.join([f'source.[{c}]' for c in columns])
    
    proc_name = f'usp_Merge_{table_name.replace("LOAD_HAUL__", "")}'
    
    proc_sql = f"""
CREATE OR ALTER PROCEDURE [dbo].[{proc_name}]
    @Data [dbo].[{type_name}] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE [dbo].[{table_name}] AS target
    USING @Data AS source
    ON target.[{pk_column}] = source.[{pk_column}]
    
    WHEN MATCHED THEN
        UPDATE SET
            {update_set}
    
    WHEN NOT MATCHED THEN
        INSERT ({insert_cols})
        VALUES ({insert_vals});
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
"""
    return proc_name, proc_sql

# ============================================================
# LH_BUCKET
# ============================================================
print('\n⚙️ Creando usp_Merge_LH_BUCKET...')
proc_name, proc_sql = generate_merge_proc(
    'LOAD_HAUL__LH_BUCKET', 
    'LOAD_HAUL__LH_BUCKET_IMO', 
    'BUCKET_ID'
)
cursor.execute(proc_sql)
conn.commit()
print(f'   ✅ {proc_name} creado')

# ============================================================
# LH_LOADING_CYCLE
# ============================================================
print('\n⚙️ Creando usp_Merge_LH_LOADING_CYCLE...')
proc_name, proc_sql = generate_merge_proc(
    'LOAD_HAUL__LH_LOADING_CYCLE', 
    'LOAD_HAUL__LH_LOADING_CYCLE_IMO', 
    'LOADING_CYCLE_ID'
)
cursor.execute(proc_sql)
conn.commit()
print(f'   ✅ {proc_name} creado')

# ============================================================
# VERIFICACIÓN FINAL
# ============================================================
print('\n' + '=' * 80)
print('VERIFICACIÓN FINAL - TODOS LOS PROCEDURES')
print('=' * 80)

cursor.execute("""
    SELECT name FROM sys.procedures 
    WHERE name LIKE 'usp_Merge_%'
    ORDER BY name
""")
for p in cursor.fetchall():
    print(f'   ✅ {p[0]}')

conn.close()

print('\n' + '=' * 80)
print('✅ ¡COMPLETADO!')
print('=' * 80)
