"""
Script para crear DRILL_BLAST__DRILL_CYCLE_IMO en SNOWFLAKE_WG (DEV)
Siguiendo la naming convention de Hidayath: CATEGORY__TABLENAME_IMO

También limpia el DRILL_CYCLE_IMO incorrecto de ambas bases.
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

server = "azwd22midbx02.eb8a77f2eea6.database.windows.net"

# Columnas del DRILL_CYCLE (107 columnas de DRILLBLAST_DRILL_CYCLE_V)
columns = """
    [CYCLE_KEY] NVARCHAR(MAX),
    [SOURCE_SYSTEM] NVARCHAR(MAX),
    [CYCLE_START_DATETIME] DATETIME2,
    [CYCLE_END_DATETIME] DATETIME2,
    [DURATION_SECONDS] FLOAT,
    [EQUIPMENT_KEY] NVARCHAR(MAX),
    [EQUIPMENT_NAME] NVARCHAR(MAX),
    [EQUIPMENT_CLASS_KEY] NVARCHAR(MAX),
    [EQUIPMENT_CLASS_NAME] NVARCHAR(MAX),
    [EQUIPMENT_TYPE_KEY] NVARCHAR(MAX),
    [EQUIPMENT_TYPE_NAME] NVARCHAR(MAX),
    [OPERATOR_KEY] NVARCHAR(MAX),
    [OPERATOR_NAME] NVARCHAR(MAX),
    [OPERATOR_TYPE_KEY] NVARCHAR(MAX),
    [OPERATOR_TYPE_NAME] NVARCHAR(MAX),
    [SHIFT_KEY] NVARCHAR(MAX),
    [SHIFT_NAME] NVARCHAR(MAX),
    [CALENDAR_KEY] NVARCHAR(MAX),
    [CALENDAR_NAME] NVARCHAR(MAX),
    [AREA_KEY] NVARCHAR(MAX),
    [AREA_NAME] NVARCHAR(MAX),
    [BENCH_KEY] NVARCHAR(MAX),
    [BENCH_NAME] NVARCHAR(MAX),
    [PIT_KEY] NVARCHAR(MAX),
    [PIT_NAME] NVARCHAR(MAX),
    [SITE_KEY] NVARCHAR(MAX),
    [SITE_NAME] NVARCHAR(MAX),
    [PATTERN_KEY] NVARCHAR(MAX),
    [PATTERN_NAME] NVARCHAR(MAX),
    [HOLE_KEY] NVARCHAR(MAX),
    [HOLE_NAME] NVARCHAR(MAX),
    [MATERIAL_KEY] NVARCHAR(MAX),
    [MATERIAL_NAME] NVARCHAR(MAX),
    [MATERIAL_TYPE_KEY] NVARCHAR(MAX),
    [MATERIAL_TYPE_NAME] NVARCHAR(MAX),
    [DRILLING_MATERIAL_KEY] NVARCHAR(MAX),
    [DRILLING_MATERIAL_NAME] NVARCHAR(MAX),
    [DRILLING_MATERIAL_TYPE_KEY] NVARCHAR(MAX),
    [DRILLING_MATERIAL_TYPE_NAME] NVARCHAR(MAX),
    [PLANNED_AZIMUTH_DEGREES] FLOAT,
    [PLANNED_COLLAR_ELEVATION_METERS] FLOAT,
    [PLANNED_COLLAR_ELEVATION_FEET] FLOAT,
    [PLANNED_COLLAR_X] FLOAT,
    [PLANNED_COLLAR_Y] FLOAT,
    [PLANNED_DEPTH_METERS] FLOAT,
    [PLANNED_DEPTH_FEET] FLOAT,
    [PLANNED_DIP_DEGREES] FLOAT,
    [PLANNED_SUBDRILL_METERS] FLOAT,
    [PLANNED_SUBDRILL_FEET] FLOAT,
    [PLANNED_TOE_ELEVATION_METERS] FLOAT,
    [PLANNED_TOE_ELEVATION_FEET] FLOAT,
    [PLANNED_TOE_X] FLOAT,
    [PLANNED_TOE_Y] FLOAT,
    [ACTUAL_AZIMUTH_DEGREES] FLOAT,
    [ACTUAL_COLLAR_ELEVATION_METERS] FLOAT,
    [ACTUAL_COLLAR_ELEVATION_FEET] FLOAT,
    [ACTUAL_COLLAR_X] FLOAT,
    [ACTUAL_COLLAR_Y] FLOAT,
    [ACTUAL_DEPTH_METERS] FLOAT,
    [ACTUAL_DEPTH_FEET] FLOAT,
    [ACTUAL_DIP_DEGREES] FLOAT,
    [ACTUAL_SUBDRILL_METERS] FLOAT,
    [ACTUAL_SUBDRILL_FEET] FLOAT,
    [ACTUAL_TOE_ELEVATION_METERS] FLOAT,
    [ACTUAL_TOE_ELEVATION_FEET] FLOAT,
    [ACTUAL_TOE_X] FLOAT,
    [ACTUAL_TOE_Y] FLOAT,
    [COLLAR_VARIANCE_HORIZONTAL_METERS] FLOAT,
    [COLLAR_VARIANCE_HORIZONTAL_FEET] FLOAT,
    [COLLAR_VARIANCE_VERTICAL_METERS] FLOAT,
    [COLLAR_VARIANCE_VERTICAL_FEET] FLOAT,
    [TOE_VARIANCE_HORIZONTAL_METERS] FLOAT,
    [TOE_VARIANCE_HORIZONTAL_FEET] FLOAT,
    [TOE_VARIANCE_VERTICAL_METERS] FLOAT,
    [TOE_VARIANCE_VERTICAL_FEET] FLOAT,
    [VARIANCE_AZIMUTH_DEGREES] FLOAT,
    [VARIANCE_DEPTH_METERS] FLOAT,
    [VARIANCE_DEPTH_FEET] FLOAT,
    [VARIANCE_DIP_DEGREES] FLOAT,
    [VARIANCE_SUBDRILL_METERS] FLOAT,
    [VARIANCE_SUBDRILL_FEET] FLOAT,
    [PROPEL_METERS] FLOAT,
    [PROPEL_FEET] FLOAT,
    [RETRACT_METERS] FLOAT,
    [RETRACT_FEET] FLOAT,
    [SINGLE_PASS_METERS] FLOAT,
    [SINGLE_PASS_FEET] FLOAT,
    [ACTUAL_HOLE_DIAMETER_MILLIMETERS] FLOAT,
    [ACTUAL_HOLE_DIAMETER_INCHES] FLOAT,
    [PLANNED_HOLE_DIAMETER_MILLIMETERS] FLOAT,
    [PLANNED_HOLE_DIAMETER_INCHES] FLOAT,
    [WATER_INFLOW_LITERS] FLOAT,
    [WATER_INFLOW_GALLONS] FLOAT,
    [WATER_DEPTH_METERS] FLOAT,
    [WATER_DEPTH_FEET] FLOAT,
    [REDRILL_COUNT] FLOAT,
    [HOLE_STATUS] NVARCHAR(MAX),
    [STATE_DRILLING_DURATION_SECONDS] FLOAT,
    [STATE_IN_PROPEL_DURATION_SECONDS] FLOAT,
    [STATE_IN_RETRACT_DURATION_SECONDS] FLOAT,
    [STATE_OTHER_DURATION_SECONDS] FLOAT,
    [STATE_LEVELING_DURATION_SECONDS] FLOAT,
    [STATE_POSITIONING_DURATION_SECONDS] FLOAT,
    [STATE_ON_HOLE_DURATION_SECONDS] FLOAT,
    [DW_LAST_UPDATED] DATETIME2,
    [IS_DELETED] INT,
    [ETL_DATA_DATETIME] DATETIME2
"""

create_type_sql = f"""
CREATE TYPE [dbo].[DRILL_BLAST__DRILL_CYCLE_IMO] AS TABLE (
{columns}
)
"""

credential = InteractiveBrowserCredential()
token = credential.get_token("https://database.windows.net/.default")
token_bytes = token.token.encode("utf-16-le")
token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)

# ============================================================
# PASO 1: Limpiar ConnectedOperations (el incorrecto)
# ============================================================
print("=" * 60)
print("PASO 1: Limpiando ConnectedOperations...")
print("=" * 60)

conn_str = f"Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database=ConnectedOperations"
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

cursor.execute("SELECT name FROM sys.table_types WHERE name = 'DRILL_CYCLE_IMO'")
if cursor.fetchone():
    cursor.execute("DROP TYPE [dbo].[DRILL_CYCLE_IMO]")
    conn.commit()
    print("  ✅ Eliminado DRILL_CYCLE_IMO de ConnectedOperations")
else:
    print("  ℹ️  No existía DRILL_CYCLE_IMO en ConnectedOperations")
conn.close()

# ============================================================
# PASO 2: Limpiar y crear en SNOWFLAKE_WG
# ============================================================
print("\n" + "=" * 60)
print("PASO 2: Configurando SNOWFLAKE_WG...")
print("=" * 60)

# Nueva conexión para SNOWFLAKE_WG
token = credential.get_token("https://database.windows.net/.default")
token_bytes = token.token.encode("utf-16-le")
token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)

conn_str = f"Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database=SNOWFLAKE_WG"
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

# Eliminar el viejo DRILL_CYCLE_IMO si existe
cursor.execute("SELECT name FROM sys.table_types WHERE name = 'DRILL_CYCLE_IMO'")
if cursor.fetchone():
    cursor.execute("DROP TYPE [dbo].[DRILL_CYCLE_IMO]")
    conn.commit()
    print("  ✅ Eliminado DRILL_CYCLE_IMO (nombre viejo) de SNOWFLAKE_WG")

# Verificar si ya existe con el nombre nuevo
cursor.execute("SELECT name FROM sys.table_types WHERE name = 'DRILL_BLAST__DRILL_CYCLE_IMO'")
if cursor.fetchone():
    print("  ⚠️  DRILL_BLAST__DRILL_CYCLE_IMO ya existe, eliminando para recrear...")
    cursor.execute("DROP TYPE [dbo].[DRILL_BLAST__DRILL_CYCLE_IMO]")
    conn.commit()

# Crear con el nombre correcto
cursor.execute(create_type_sql)
conn.commit()
print("  ✅ Creado DRILL_BLAST__DRILL_CYCLE_IMO en SNOWFLAKE_WG")

# ============================================================
# PASO 3: Verificación final
# ============================================================
print("\n" + "=" * 60)
print("VERIFICACIÓN FINAL - Table Types en SNOWFLAKE_WG:")
print("=" * 60)

cursor.execute("""
    SELECT '[' + SCHEMA_NAME(schema_id) + '].[' + name + ']' as full_name 
    FROM sys.table_types 
    ORDER BY name
""")
for row in cursor.fetchall():
    print(f"  - {row[0]}")

conn.close()

print("\n" + "=" * 60)
print("✅ ¡COMPLETADO!")
print("=" * 60)
print("\n⚠️  NOTA: Debes actualizar DRILL_CYCLE.json:")
print('   "sql_table_type": "[dbo].[DRILL_BLAST__DRILL_CYCLE_IMO]"')
