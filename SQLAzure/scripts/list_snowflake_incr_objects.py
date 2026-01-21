"""
Lista los objetos INCR creados en Snowflake para los 3 pipelines
"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='ccarrill2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='SANDBOX_DATA_ENGINEER',
    schema='HM2'
)
cursor = conn.cursor()

# Asegurar warehouse activo
cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")

print('=' * 80)
print('TODOS LOS OBJETOS EN SNOWFLAKE - SANDBOX_DATA_ENGINEER.HM2')
print('=' * 80)

# Buscar TODAS las views/tables
print('\n📋 TODAS LAS VIEWS/TABLES:')
cursor.execute("""
    SELECT TABLE_NAME, TABLE_TYPE 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'HM2' 
    ORDER BY TABLE_NAME
""")
for row in cursor.fetchall():
    print(f"   • {row[0]} ({row[1]})")

# Buscar TODOS los procedures
print('\n📋 TODOS LOS PROCEDURES:')
cursor.execute("""
    SELECT PROCEDURE_NAME 
    FROM INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_SCHEMA = 'HM2' 
    ORDER BY PROCEDURE_NAME
""")
for row in cursor.fetchall():
    print(f"   • {row[0]}")

# Buscar TODOS los tasks
print('\n📋 TODOS LOS TASKS:')
cursor.execute("""
    SHOW TASKS IN SCHEMA SANDBOX_DATA_ENGINEER.HM2
""")
for row in cursor.fetchall():
    print(f"   • {row[1]} (state: {row[9]})")  # name y state

# También buscar en LH
print('\n' + '=' * 80)
print('BUSCANDO TAMBIÉN OBJETOS LH_BUCKET Y LH_LOADING_CYCLE...')
print('=' * 80)

print('\n📋 VIEWS/TABLES LH:')
cursor.execute("""
    SELECT TABLE_NAME, TABLE_TYPE 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'HM2' 
    AND (TABLE_NAME LIKE '%LH_BUCKET%' OR TABLE_NAME LIKE '%LH_LOADING%')
    ORDER BY TABLE_NAME
""")
for row in cursor.fetchall():
    print(f"   • {row[0]} ({row[1]})")

print('\n📋 PROCEDURES LH:')
cursor.execute("""
    SELECT PROCEDURE_NAME 
    FROM INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_SCHEMA = 'HM2' 
    AND (PROCEDURE_NAME LIKE '%LH_BUCKET%' OR PROCEDURE_NAME LIKE '%LH_LOADING%')
    ORDER BY PROCEDURE_NAME
""")
for row in cursor.fetchall():
    print(f"   • {row[0]}")

print('\n📋 TASKS LH:')
cursor.execute("""
    SHOW TASKS LIKE '%LH_%' IN SCHEMA SANDBOX_DATA_ENGINEER.HM2
""")
for row in cursor.fetchall():
    print(f"   • {row[1]} (state: {row[9]})")

cursor.close()
conn.close()

print('\n✅ Listado completo')
