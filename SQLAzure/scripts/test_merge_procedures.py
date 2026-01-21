"""
Prueba los 3 stored procedures de merge en SQL Azure
"""
import pyodbc
from azure.identity import InteractiveBrowserCredential

# Configuración
server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

# Obtener token de Azure AD
credential = InteractiveBrowserCredential()
token = credential.get_token("https://database.windows.net/.default")

# Conexión con token
conn_str = f'DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={server};DATABASE={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token.token.encode('utf-16-le')})
cursor = conn.cursor()

print('=' * 80)
print('PROBANDO STORED PROCEDURES EN SQL AZURE - SNOWFLAKE_WG')
print('=' * 80)

procedures = [
    'usp_Merge_DRILL_CYCLE',
    'usp_Merge_LH_BUCKET', 
    'usp_Merge_LH_LOADING_CYCLE'
]

for proc in procedures:
    print(f'\n🔍 Verificando {proc}...')
    
    # 1. Verificar que existe
    cursor.execute("""
        SELECT COUNT(*) FROM sys.procedures WHERE name = ?
    """, proc)
    exists = cursor.fetchone()[0]
    
    if exists:
        print(f'   ✅ Existe')
        
        # 2. Obtener la definición para ver la estructura
        cursor.execute("""
            SELECT OBJECT_DEFINITION(OBJECT_ID(?))
        """, proc)
        definition = cursor.fetchone()[0]
        
        # Mostrar primeras líneas
        lines = definition.split('\n')[:15]
        print(f'   📄 Primeras líneas:')
        for line in lines:
            if line.strip():
                print(f'      {line.rstrip()[:80]}')
        
        # 3. Intentar ejecutar con tabla vacía (debería funcionar sin errores)
        print(f'\n   🚀 Ejecutando {proc} con TVP vacío...')
        try:
            # Crear una tabla temporal vacía del tipo correcto
            if 'DRILL_CYCLE' in proc:
                type_name = 'DRILL_BLAST__DRILL_CYCLE_IMO'
            elif 'LH_BUCKET' in proc:
                type_name = 'LOAD_HAUL__LH_BUCKET_IMO'
            else:
                type_name = 'LOAD_HAUL__LH_LOADING_CYCLE_IMO'
            
            # Ejecutar con DECLARE para probar sintaxis
            test_sql = f"""
                DECLARE @TestData {type_name};
                EXEC {proc} @TestData;
            """
            cursor.execute(test_sql)
            conn.commit()
            print(f'   ✅ Ejecutado correctamente (0 filas procesadas)')
        except Exception as e:
            print(f'   ❌ Error: {str(e)[:100]}')
    else:
        print(f'   ❌ No existe')

print('\n' + '=' * 80)
print('✅ PRUEBAS COMPLETADAS')
print('=' * 80)

cursor.close()
conn.close()
