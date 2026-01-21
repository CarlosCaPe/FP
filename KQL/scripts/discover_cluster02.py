"""
Discovery completo del cluster fctsnaproddatexp02
"""
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import InteractiveBrowserCredential

CLUSTER = 'https://fctsnaproddatexp02.westus2.kusto.windows.net'

print(f'Connecting to: {CLUSTER}')
credential = InteractiveBrowserCredential()
kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER, credential)
client = KustoClient(kcsb)

# 1. Listar databases
print('\n' + '=' * 70)
print('DATABASES EN CLUSTER fctsnaproddatexp02')
print('=' * 70)
try:
    result = client.execute_mgmt('AppIntegration', '.show databases')
    for row in result.primary_results[0]:
        print(f"   • {row[0]}")
except Exception as e:
    print(f"   Error: {e}")

# 2. Listar tablas en AppIntegration
print('\n' + '=' * 70)
print('TABLAS EN AppIntegration')
print('=' * 70)
try:
    result = client.execute_mgmt('AppIntegration', '.show tables')
    tables = list(result.primary_results[0])
    if tables:
        for row in tables:
            print(f"   • {row[0]}")
    else:
        print("   (sin tablas)")
except Exception as e:
    print(f"   Error: {e}")

# 3. Listar funciones
print('\n' + '=' * 70)
print('FUNCIONES EN AppIntegration')
print('=' * 70)
try:
    result = client.execute_mgmt('AppIntegration', '.show functions')
    funcs = list(result.primary_results[0])
    if funcs:
        for row in funcs:
            print(f"   • {row[0]}")
    else:
        print("   (sin funciones)")
except Exception as e:
    print(f"   Error: {e}")

# 4. Listar external tables
print('\n' + '=' * 70)
print('EXTERNAL TABLES EN AppIntegration')
print('=' * 70)
try:
    result = client.execute_mgmt('AppIntegration', '.show external tables')
    ext_tables = list(result.primary_results[0])
    if ext_tables:
        for row in ext_tables:
            print(f"   • {row[0]}")
    else:
        print("   (sin external tables)")
except Exception as e:
    print(f"   Error: {e}")

# 5. Probar query simple
print('\n' + '=' * 70)
print('PROBANDO QUERIES')
print('=' * 70)

# Probar diferentes databases que podrían existir
test_dbs = ['AppIntegration', 'FCTS', 'Global', 'BAG', 'MOR']
for db in test_dbs:
    try:
        result = client.execute(db, "print test='connected'")
        rows = list(result.primary_results[0])
        print(f"   ✅ {db}: Conectado")
    except Exception as e:
        err = str(e)
        if "not authorized" in err.lower():
            print(f"   🔒 {db}: Sin permiso")
        elif "not found" in err.lower():
            print(f"   ❌ {db}: No existe")
        else:
            print(f"   ⚠️ {db}: {str(e)[:50]}")

print('\n✅ Discovery completado')
