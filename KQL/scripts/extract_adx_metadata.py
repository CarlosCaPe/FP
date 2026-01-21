"""
Extrae toda la metadata del cluster ADX fctsnaproddatexp02 para análisis offline
Similar a lo que hicimos con SQL Azure schemas
"""
import json
from datetime import datetime
from pathlib import Path
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import InteractiveBrowserCredential

CLUSTER = 'https://fctsnaproddatexp02.westus2.kusto.windows.net'
OUTPUT_DIR = Path(__file__).parent.parent / 'schemas'
OUTPUT_DIR.mkdir(exist_ok=True)

print(f'Connecting to: {CLUSTER}')
credential = InteractiveBrowserCredential()
kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER, credential)
client = KustoClient(kcsb)

metadata = {
    'cluster': CLUSTER,
    'extracted_at': datetime.utcnow().isoformat() + 'Z',
    'databases': {}
}

# 1. Obtener lista de databases
print('\n📋 Obteniendo databases...')
try:
    result = client.execute_mgmt('AppIntegration', '.show databases')
    databases = [row[0] for row in result.primary_results[0]]
    print(f'   Found {len(databases)} databases')
except Exception as e:
    print(f'   Error: {e}')
    databases = []

# 2. Para cada database, obtener metadata
for db in databases:
    print(f'\n📁 Procesando {db}...')
    db_meta = {
        'name': db,
        'tables': [],
        'functions': [],
        'external_tables': [],
        'materialized_views': []
    }
    
    # Tablas
    try:
        result = client.execute_mgmt(db, '.show tables details')
        cols = [col.column_name for col in result.primary_results[0].columns]
        for row in result.primary_results[0]:
            table_info = dict(zip(cols, row))
            db_meta['tables'].append({
                'name': table_info.get('TableName'),
                'folder': table_info.get('Folder'),
                'doc_string': table_info.get('DocString'),
                'total_extents': table_info.get('TotalExtents'),
                'total_original_size': table_info.get('TotalOriginalSize'),
                'total_row_count': table_info.get('TotalRowCount'),
            })
        print(f'   ✅ {len(db_meta["tables"])} tables')
    except Exception as e:
        if 'not authorized' not in str(e).lower():
            print(f'   ⚠️ Tables error: {str(e)[:50]}')
    
    # Funciones
    try:
        result = client.execute_mgmt(db, '.show functions')
        cols = [col.column_name for col in result.primary_results[0].columns]
        for row in result.primary_results[0]:
            func_info = dict(zip(cols, row))
            db_meta['functions'].append({
                'name': func_info.get('Name'),
                'parameters': func_info.get('Parameters'),
                'body': func_info.get('Body'),
                'folder': func_info.get('Folder'),
                'doc_string': func_info.get('DocString'),
            })
        print(f'   ✅ {len(db_meta["functions"])} functions')
    except Exception as e:
        if 'not authorized' not in str(e).lower():
            print(f'   ⚠️ Functions error: {str(e)[:50]}')
    
    # External tables
    try:
        result = client.execute_mgmt(db, '.show external tables')
        cols = [col.column_name for col in result.primary_results[0].columns]
        for row in result.primary_results[0]:
            ext_info = dict(zip(cols, row))
            db_meta['external_tables'].append({
                'name': ext_info.get('TableName'),
                'table_type': ext_info.get('TableType'),
            })
        print(f'   ✅ {len(db_meta["external_tables"])} external tables')
    except Exception as e:
        if 'not authorized' not in str(e).lower():
            pass  # Normal que no haya
    
    # Materialized views
    try:
        result = client.execute_mgmt(db, '.show materialized-views')
        cols = [col.column_name for col in result.primary_results[0].columns]
        for row in result.primary_results[0]:
            mv_info = dict(zip(cols, row))
            db_meta['materialized_views'].append({
                'name': mv_info.get('Name'),
                'source_table': mv_info.get('SourceTable'),
            })
        print(f'   ✅ {len(db_meta["materialized_views"])} materialized views')
    except Exception as e:
        if 'not authorized' not in str(e).lower():
            pass  # Normal que no haya

    # Schema de tablas principales (FCTS, FCTSCURRENT si existen)
    for table in ['FCTS', 'FCTSCURRENT']:
        try:
            result = client.execute_mgmt(db, f'.show table {table} schema as json')
            for row in result.primary_results[0]:
                schema_json = row[0]
                # Buscar la tabla en db_meta y agregar schema
                for t in db_meta['tables']:
                    if t['name'] == table:
                        t['schema'] = json.loads(schema_json) if schema_json else None
                        break
        except:
            pass
    
    metadata['databases'][db] = db_meta

# 3. Guardar metadata
output_file = OUTPUT_DIR / f'adx_fctsnaproddatexp02_{datetime.now().strftime("%Y%m%d_%H%M%S")}.json'
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(metadata, f, indent=2, default=str)

print(f'\n✅ Metadata guardada en: {output_file}')

# 4. Resumen
print('\n' + '=' * 70)
print('RESUMEN')
print('=' * 70)
total_tables = sum(len(db['tables']) for db in metadata['databases'].values())
total_functions = sum(len(db['functions']) for db in metadata['databases'].values())
print(f'Databases: {len(metadata["databases"])}')
print(f'Total tables: {total_tables}')
print(f'Total functions: {total_functions}')

# 5. Listar tablas FCTS por sitio (las que reemplazan a Snowflake)
print('\n' + '=' * 70)
print('TABLAS FCTS POR SITIO (reemplazan SENSOR_READING_*_B de Snowflake)')
print('=' * 70)
for db_name, db_data in metadata['databases'].items():
    fcts_tables = [t for t in db_data['tables'] if 'FCTS' in t['name'].upper()]
    if fcts_tables:
        print(f'\n{db_name}:')
        for t in fcts_tables:
            rows = t.get('total_row_count', 'N/A')
            size = t.get('total_original_size', 0)
            size_gb = size / (1024**3) if size else 0
            print(f'   • {t["name"]}: {rows:,} rows, {size_gb:.2f} GB' if isinstance(rows, int) else f'   • {t["name"]}')
