"""
Ejecuta los 22 scripts INCR individuales en Snowflake DEV
- 11 Tables DDL
- 11 Stored Procedures
"""
import snowflake.connector
import os
from pathlib import Path

# Conectar a Snowflake con externalbrowser (SSO)
print("🔐 Conectando a Snowflake (se abrirá el navegador para autenticación)...")
conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='ccarrill2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE'
)
cursor = conn.cursor()
print("✅ Conectado a DEV_API_REF.FUSE")

# Rutas base
BASE_PATH = Path(__file__).parent / "DDL-Scripts" / "API_REF" / "FUSE"
TABLES_PATH = BASE_PATH / "TABLES"
PROCEDURES_PATH = BASE_PATH / "PROCEDURES"

# Archivos de tablas (11)
TABLE_FILES = [
    "R__BLAST_PLAN_EXECUTION_INCR.sql",
    "R__BLAST_PLAN_INCR.sql",
    "R__BL_DW_BLASTPROPERTYVALUE_INCR.sql",
    "R__BL_DW_BLAST_INCR.sql",
    "R__BL_DW_HOLE_INCR.sql",
    "R__DRILLBLAST_EQUIPMENT_INCR.sql",
    "R__DRILLBLAST_OPERATOR_INCR.sql",
    "R__DRILLBLAST_SHIFT_INCR.sql",
    "R__DRILL_CYCLE_INCR.sql",
    "R__DRILL_PLAN_INCR.sql",
    "R__LH_HAUL_CYCLE_INCR.sql",
]

# Archivos de procedures (11)
PROCEDURE_FILES = [
    "R__BLAST_PLAN_EXECUTION_INCR_P.sql",
    "R__BLAST_PLAN_INCR_P.sql",
    "R__BL_DW_BLASTPROPERTYVALUE_INCR_P.sql",
    "R__BL_DW_BLAST_INCR_P.sql",
    "R__BL_DW_HOLE_INCR_P.sql",
    "R__DRILLBLAST_EQUIPMENT_INCR_P.sql",
    "R__DRILLBLAST_OPERATOR_INCR_P.sql",
    "R__DRILLBLAST_SHIFT_INCR_P.sql",
    "R__DRILL_CYCLE_INCR_P.sql",
    "R__DRILL_PLAN_INCR_P.sql",
    "R__LH_HAUL_CYCLE_INCR_P.sql",
]

def execute_sql_file(cursor, filepath, description, environment='DEV'):
    """Execute a SQL file and return success/failure."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            sql = f.read()
        
        # Reemplazar templates Jinja {{ envi }} con el ambiente
        sql = sql.replace('{{ envi }}', environment)
        sql = sql.replace('{{envi}}', environment)
        
        # Ejecutar el SQL
        cursor.execute(sql)
        print(f"  ✅ {description}")
        return True
    except Exception as e:
        print(f"  ❌ {description}: {str(e)[:100]}")
        return False

# ============================================
# PASO 1: Ejecutar DDL de Tablas (11)
# ============================================
print("\n" + "=" * 60)
print("📋 PASO 1: CREANDO 11 TABLAS INCR")
print("=" * 60)

tables_success = 0
tables_failed = 0

for filename in TABLE_FILES:
    filepath = TABLES_PATH / filename
    if filepath.exists():
        if execute_sql_file(cursor, filepath, filename):
            tables_success += 1
        else:
            tables_failed += 1
    else:
        print(f"  ⚠️ Archivo no encontrado: {filename}")
        tables_failed += 1

print(f"\n📊 Tablas: {tables_success} OK, {tables_failed} FAILED")

# ============================================
# PASO 2: Ejecutar Stored Procedures (11)
# ============================================
print("\n" + "=" * 60)
print("📋 PASO 2: CREANDO 11 STORED PROCEDURES")
print("=" * 60)

# Los 5 procedures arreglados con Vikas fix tienen nuevo parámetro,
# hay que DROP primero para evitar conflicto de overload
PROCEDURES_WITH_NEW_PARAM = [
    "BLAST_PLAN_INCR_P",
    "DRILL_CYCLE_INCR_P",
    "DRILL_PLAN_INCR_P",
    "DRILLBLAST_SHIFT_INCR_P",
    "LH_HAUL_CYCLE_INCR_P",
]

print("  🗑️ Eliminando procedures con nuevo parámetro MAX_DAYS_TO_KEEP...")
for proc in PROCEDURES_WITH_NEW_PARAM:
    try:
        cursor.execute(f"DROP PROCEDURE IF EXISTS DEV_API_REF.FUSE.{proc}(VARCHAR)")
        cursor.execute(f"DROP PROCEDURE IF EXISTS DEV_API_REF.FUSE.{proc}(VARCHAR, VARCHAR)")
        print(f"    ✓ Dropped {proc}")
    except Exception as e:
        print(f"    ⚠️ {proc}: {str(e)[:50]}")

procs_success = 0
procs_failed = 0

for filename in PROCEDURE_FILES:
    filepath = PROCEDURES_PATH / filename
    if filepath.exists():
        if execute_sql_file(cursor, filepath, filename):
            procs_success += 1
        else:
            procs_failed += 1
    else:
        print(f"  ⚠️ Archivo no encontrado: {filename}")
        procs_failed += 1

print(f"\n📊 Procedures: {procs_success} OK, {procs_failed} FAILED")

# ============================================
# PASO 3: Verificar objetos creados
# ============================================
print("\n" + "=" * 60)
print("📋 PASO 3: VERIFICANDO OBJETOS EN DEV_API_REF.FUSE")
print("=" * 60)

# Verificar tablas
cursor.execute("""
    SELECT TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'FUSE' 
    AND TABLE_NAME LIKE '%_INCR'
    ORDER BY TABLE_NAME
""")
tables = cursor.fetchall()
print(f"\n📋 Tablas INCR encontradas ({len(tables)}):")
for t in tables:
    print(f"   • {t[0]}")

# Verificar procedures
cursor.execute("""
    SELECT PROCEDURE_NAME 
    FROM INFORMATION_SCHEMA.PROCEDURES 
    WHERE PROCEDURE_SCHEMA = 'FUSE' 
    AND PROCEDURE_NAME LIKE '%_INCR_P'
    ORDER BY PROCEDURE_NAME
""")
procs = cursor.fetchall()
print(f"\n📋 Procedures INCR encontrados ({len(procs)}):")
for p in procs:
    print(f"   • {p[0]}")

# ============================================
# RESUMEN FINAL
# ============================================
print("\n" + "=" * 60)
print("📋 RESUMEN FINAL")
print("=" * 60)
total_success = tables_success + procs_success
total_failed = tables_failed + procs_failed
print(f"✅ Exitosos: {total_success}/22")
print(f"❌ Fallidos: {total_failed}/22")

if total_failed == 0:
    print("\n🎉 ¡TODOS LOS 22 SCRIPTS EJECUTADOS CORRECTAMENTE!")
else:
    print(f"\n⚠️ Hay {total_failed} errores que revisar")

cursor.close()
conn.close()
print("\n🔌 Conexión cerrada")
