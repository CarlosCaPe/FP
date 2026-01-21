"""
Script para actualizar la tabla DRILL_CYCLE y crear el procedure de merge
para el nuevo diseño INCR (incremental)
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
print('ACTUALIZANDO DRILL_CYCLE PARA DISEÑO INCR')
print('=' * 80)

# ============================================================
# PASO 1: Añadir columna faltante DW_LOGICAL_DELETE_FLAG
# ============================================================
print('\n📋 PASO 1: Añadiendo columna DW_LOGICAL_DELETE_FLAG...')

cursor.execute("""
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = 'DRILL_CYCLE' AND COLUMN_NAME = 'DW_LOGICAL_DELETE_FLAG'
    )
    BEGIN
        ALTER TABLE [dbo].[DRILL_CYCLE] 
        ADD [DW_LOGICAL_DELETE_FLAG] NVARCHAR(MAX) NULL;
    END
""")
conn.commit()
print('   ✅ Columna DW_LOGICAL_DELETE_FLAG añadida (o ya existía)')

# ============================================================
# PASO 2: Crear/Actualizar el Stored Procedure de Merge
# ============================================================
print('\n⚙️ PASO 2: Creando procedure usp_Merge_DRILL_CYCLE...')

merge_proc = """
CREATE OR ALTER PROCEDURE [dbo].[usp_Merge_DRILL_CYCLE]
    @Data [dbo].[DRILL_BLAST__DRILL_CYCLE_IMO] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE [dbo].[DRILL_CYCLE] AS target
    USING @Data AS source
    ON target.[DRILL_CYCLE_SK] = source.[DRILL_CYCLE_SK]
    
    WHEN MATCHED THEN
        UPDATE SET
            target.[ORIG_SRC_ID] = source.[ORIG_SRC_ID],
            target.[SITE_CODE] = source.[SITE_CODE],
            target.[BENCH] = source.[BENCH],
            target.[PUSHBACK] = source.[PUSHBACK],
            target.[PATTERN_NAME] = source.[PATTERN_NAME],
            target.[ORIGINAL_PATTERN_NAME] = source.[ORIGINAL_PATTERN_NAME],
            target.[DRILL_HOLE_SHIFT_ID] = source.[DRILL_HOLE_SHIFT_ID],
            target.[DRILL_ID] = source.[DRILL_ID],
            target.[DRILL_BIT_ID] = source.[DRILL_BIT_ID],
            target.[SYSTEM_OPERATOR_ID] = source.[SYSTEM_OPERATOR_ID],
            target.[DRILL_HOLE_ID] = source.[DRILL_HOLE_ID],
            target.[DRILL_HOLE_NAME] = source.[DRILL_HOLE_NAME],
            target.[DRILL_PLAN_SK] = source.[DRILL_PLAN_SK],
            target.[DRILL_HOLE_STATUS] = source.[DRILL_HOLE_STATUS],
            target.[IS_HOLE_PLANNED_FLAG] = source.[IS_HOLE_PLANNED_FLAG],
            target.[START_HOLE_TS_UTC] = source.[START_HOLE_TS_UTC],
            target.[END_HOLE_TS_UTC] = source.[END_HOLE_TS_UTC],
            target.[START_HOLE_TS_LOCAL] = source.[START_HOLE_TS_LOCAL],
            target.[END_HOLE_TS_LOCAL] = source.[END_HOLE_TS_LOCAL],
            target.[DRILL_HOLE_DURATION_SECONDS] = source.[DRILL_HOLE_DURATION_SECONDS],
            target.[ACTUAL_DRILL_HOLE_DEPTH_FEET] = source.[ACTUAL_DRILL_HOLE_DEPTH_FEET],
            target.[ACTUAL_DRILL_HOLE_DEPTH_METERS] = source.[ACTUAL_DRILL_HOLE_DEPTH_METERS],
            target.[GPS_ACCURACY] = source.[GPS_ACCURACY],
            target.[ACTUAL_DRILL_HOLE_START_FEET_X] = source.[ACTUAL_DRILL_HOLE_START_FEET_X],
            target.[ACTUAL_DRILL_HOLE_START_FEET_Y] = source.[ACTUAL_DRILL_HOLE_START_FEET_Y],
            target.[ACTUAL_DRILL_HOLE_START_FEET_Z] = source.[ACTUAL_DRILL_HOLE_START_FEET_Z],
            target.[ACTUAL_DRILL_HOLE_END_FEET_X] = source.[ACTUAL_DRILL_HOLE_END_FEET_X],
            target.[ACTUAL_DRILL_HOLE_END_FEET_Y] = source.[ACTUAL_DRILL_HOLE_END_FEET_Y],
            target.[ACTUAL_DRILL_HOLE_END_FEET_Z] = source.[ACTUAL_DRILL_HOLE_END_FEET_Z],
            target.[ACTUAL_DRILL_HOLE_LONGITUDE] = source.[ACTUAL_DRILL_HOLE_LONGITUDE],
            target.[ACTUAL_DRILL_HOLE_LATITUDE] = source.[ACTUAL_DRILL_HOLE_LATITUDE],
            target.[ACTUAL_DRILL_HOLE_START_METERS_X] = source.[ACTUAL_DRILL_HOLE_START_METERS_X],
            target.[ACTUAL_DRILL_HOLE_START_METERS_Y] = source.[ACTUAL_DRILL_HOLE_START_METERS_Y],
            target.[ACTUAL_DRILL_HOLE_START_METERS_Z] = source.[ACTUAL_DRILL_HOLE_START_METERS_Z],
            target.[ACTUAL_DRILL_HOLE_END_METERS_X] = source.[ACTUAL_DRILL_HOLE_END_METERS_X],
            target.[ACTUAL_DRILL_HOLE_END_METERS_Y] = source.[ACTUAL_DRILL_HOLE_END_METERS_Y],
            target.[ACTUAL_DRILL_HOLE_END_METERS_Z] = source.[ACTUAL_DRILL_HOLE_END_METERS_Z],
            target.[AUTODRILL_DURATION_SECONDS] = source.[AUTODRILL_DURATION_SECONDS],
            target.[AUTODRILL_USAGE_PCT] = source.[AUTODRILL_USAGE_PCT],
            target.[DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR] = source.[DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR],
            target.[OPERATOR_LOGIN_TS_UTC] = source.[OPERATOR_LOGIN_TS_UTC],
            target.[OPERATOR_LOGOUT_TS_UTC] = source.[OPERATOR_LOGOUT_TS_UTC],
            target.[OPERATOR_LOGIN_TS_LOCAL] = source.[OPERATOR_LOGIN_TS_LOCAL],
            target.[OPERATOR_LOGOUT_TS_LOCAL] = source.[OPERATOR_LOGOUT_TS_LOCAL],
            target.[BEARING] = source.[BEARING],
            target.[DRILL_TOWER_ANGLE_DEGREE_CALCULATED] = source.[DRILL_TOWER_ANGLE_DEGREE_CALCULATED],
            target.[DRILL_TOWER_ANGLE_DEGREE_SYSTEM] = source.[DRILL_TOWER_ANGLE_DEGREE_SYSTEM],
            target.[DRILL_HOLE_DUPLICATED_FLAG] = source.[DRILL_HOLE_DUPLICATED_FLAG],
            target.[DRILL_HOLE_UPSIDE_DOWN_FLAG] = source.[DRILL_HOLE_UPSIDE_DOWN_FLAG],
            target.[DRILL_HOLE_START_END_TIME_INVALID_FLAG] = source.[DRILL_HOLE_START_END_TIME_INVALID_FLAG],
            target.[DRILL_HOLE_START_END_TIME_OVERLAP_FLAG] = source.[DRILL_HOLE_START_END_TIME_OVERLAP_FLAG],
            target.[DRILL_HOLE_DEPTH_INVALID_FLAG] = source.[DRILL_HOLE_DEPTH_INVALID_FLAG],
            target.[DRILL_HOLE_ANGLE_INVALID_FLAG] = source.[DRILL_HOLE_ANGLE_INVALID_FLAG],
            target.[DRILL_HOLE_POSITION_INVALID_FLAG] = source.[DRILL_HOLE_POSITION_INVALID_FLAG],
            target.[TIME_BETWEEN_DRILL_HOLES_SECONDS] = source.[TIME_BETWEEN_DRILL_HOLES_SECONDS],
            target.[AIR_PRESSURE_PSI] = source.[AIR_PRESSURE_PSI],
            target.[FEED_FORCE_NEWTONS] = source.[FEED_FORCE_NEWTONS],
            target.[ROTATION_TORQUE_NM] = source.[ROTATION_TORQUE_NM],
            target.[BIT_SPEED_RPM] = source.[BIT_SPEED_RPM],
            target.[WATER_FLOW_GPM] = source.[WATER_FLOW_GPM],
            target.[INSTANTANOUS_PENRATE_MWD_METERS_HOUR] = source.[INSTANTANOUS_PENRATE_MWD_METERS_HOUR],
            target.[INSTANTANOUS_PENRATE_MWD_FEET_HOUR] = source.[INSTANTANOUS_PENRATE_MWD_FEET_HOUR],
            target.[DRILL_HOLE_OFF_TARGET_FEET] = source.[DRILL_HOLE_OFF_TARGET_FEET],
            target.[DRILL_HOLE_OFF_TARGET_METERS] = source.[DRILL_HOLE_OFF_TARGET_METERS],
            target.[DRILL_HOLE_HORIZONTAL_ACCURACY_PCT] = source.[DRILL_HOLE_HORIZONTAL_ACCURACY_PCT],
            target.[DRILL_HOLE_VERTICAL_ACCURACY_PCT] = source.[DRILL_HOLE_VERTICAL_ACCURACY_PCT],
            target.[OVERDRILL_UNDERDRILL_FLAG] = source.[OVERDRILL_UNDERDRILL_FLAG],
            target.[OVERDRILL_UNDERDRILL_FEET] = source.[OVERDRILL_UNDERDRILL_FEET],
            target.[OVERDRILL_UNDERDRILL_METERS] = source.[OVERDRILL_UNDERDRILL_METERS],
            target.[DRILLING_STOPS_COUNT] = source.[DRILLING_STOPS_COUNT],
            target.[DRILL_HOLE_REDRILL_FLAG] = source.[DRILL_HOLE_REDRILL_FLAG],
            target.[PROPEL_START_TS_UTC] = source.[PROPEL_START_TS_UTC],
            target.[PROPEL_END_TS_UTC] = source.[PROPEL_END_TS_UTC],
            target.[PARK_POSITION_START_TS_UTC] = source.[PARK_POSITION_START_TS_UTC],
            target.[PARK_POSITION_END_TS_UTC] = source.[PARK_POSITION_END_TS_UTC],
            target.[LEVEL_START_TS_UTC] = source.[LEVEL_START_TS_UTC],
            target.[LEVEL_END_TS_UTC] = source.[LEVEL_END_TS_UTC],
            target.[DRILL_START_TS_UTC] = source.[DRILL_START_TS_UTC],
            target.[DRILL_END_TS_UTC] = source.[DRILL_END_TS_UTC],
            target.[RETRACT_START_TS_UTC] = source.[RETRACT_START_TS_UTC],
            target.[RETRACT_END_TS_UTC] = source.[RETRACT_END_TS_UTC],
            target.[PROPEL_START_TS_LOCAL] = source.[PROPEL_START_TS_LOCAL],
            target.[PROPEL_END_TS_LOCAL] = source.[PROPEL_END_TS_LOCAL],
            target.[PARK_POSITION_START_TS_LOCAL] = source.[PARK_POSITION_START_TS_LOCAL],
            target.[PARK_POSITION_END_TS_LOCAL] = source.[PARK_POSITION_END_TS_LOCAL],
            target.[LEVEL_START_TS_LOCAL] = source.[LEVEL_START_TS_LOCAL],
            target.[LEVEL_END_TS_LOCAL] = source.[LEVEL_END_TS_LOCAL],
            target.[DRILL_START_TS_LOCAL] = source.[DRILL_START_TS_LOCAL],
            target.[DRILL_END_TS_LOCAL] = source.[DRILL_END_TS_LOCAL],
            target.[RETRACT_START_TS_LOCAL] = source.[RETRACT_START_TS_LOCAL],
            target.[RETRACT_END_TS_LOCAL] = source.[RETRACT_END_TS_LOCAL],
            target.[PROPEL_DURATION] = source.[PROPEL_DURATION],
            target.[PARK_POSITION_DURATION] = source.[PARK_POSITION_DURATION],
            target.[LEVEL_DURATION] = source.[LEVEL_DURATION],
            target.[DRILL_DURATION] = source.[DRILL_DURATION],
            target.[RETRACT_DURATION] = source.[RETRACT_DURATION],
            target.[SYSTEM_DRILL_STATE_DURATION_SECONDS] = source.[SYSTEM_DRILL_STATE_DURATION_SECONDS],
            target.[SYSTEM_SETUP_STATE_DURATION_SECONDS] = source.[SYSTEM_SETUP_STATE_DURATION_SECONDS],
            target.[SYSTEM_AUTO_LEVEL_DURATION_SECONDS] = source.[SYSTEM_AUTO_LEVEL_DURATION_SECONDS],
            target.[SYSTEM_AUTO_DELEVEL_DURATION_SECONDS] = source.[SYSTEM_AUTO_DELEVEL_DURATION_SECONDS],
            target.[PLAN_CREATION_TS_LOCAL] = source.[PLAN_CREATION_TS_LOCAL],
            target.[SYSTEM_VERSION] = source.[SYSTEM_VERSION],
            target.[ACTUAL_MCF_BLOCK_ID] = source.[ACTUAL_MCF_BLOCK_ID],
            target.[DESIGN_MCF_BLOCK_ID] = source.[DESIGN_MCF_BLOCK_ID],
            target.[DW_LOGICAL_DELETE_FLAG] = source.[DW_LOGICAL_DELETE_FLAG],
            target.[DW_LOAD_TS] = source.[DW_LOAD_TS],
            target.[DW_MODIFY_TS] = source.[DW_MODIFY_TS]
    
    WHEN NOT MATCHED THEN
        INSERT (
            [ORIG_SRC_ID], [SITE_CODE], [BENCH], [PUSHBACK], [PATTERN_NAME],
            [ORIGINAL_PATTERN_NAME], [DRILL_CYCLE_SK], [DRILL_HOLE_SHIFT_ID],
            [DRILL_ID], [DRILL_BIT_ID], [SYSTEM_OPERATOR_ID], [DRILL_HOLE_ID],
            [DRILL_HOLE_NAME], [DRILL_PLAN_SK], [DRILL_HOLE_STATUS],
            [IS_HOLE_PLANNED_FLAG], [START_HOLE_TS_UTC], [END_HOLE_TS_UTC],
            [START_HOLE_TS_LOCAL], [END_HOLE_TS_LOCAL], [DRILL_HOLE_DURATION_SECONDS],
            [ACTUAL_DRILL_HOLE_DEPTH_FEET], [ACTUAL_DRILL_HOLE_DEPTH_METERS],
            [GPS_ACCURACY], [ACTUAL_DRILL_HOLE_START_FEET_X], [ACTUAL_DRILL_HOLE_START_FEET_Y],
            [ACTUAL_DRILL_HOLE_START_FEET_Z], [ACTUAL_DRILL_HOLE_END_FEET_X],
            [ACTUAL_DRILL_HOLE_END_FEET_Y], [ACTUAL_DRILL_HOLE_END_FEET_Z],
            [ACTUAL_DRILL_HOLE_LONGITUDE], [ACTUAL_DRILL_HOLE_LATITUDE],
            [ACTUAL_DRILL_HOLE_START_METERS_X], [ACTUAL_DRILL_HOLE_START_METERS_Y],
            [ACTUAL_DRILL_HOLE_START_METERS_Z], [ACTUAL_DRILL_HOLE_END_METERS_X],
            [ACTUAL_DRILL_HOLE_END_METERS_Y], [ACTUAL_DRILL_HOLE_END_METERS_Z],
            [AUTODRILL_DURATION_SECONDS], [AUTODRILL_USAGE_PCT],
            [DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR], [OPERATOR_LOGIN_TS_UTC],
            [OPERATOR_LOGOUT_TS_UTC], [OPERATOR_LOGIN_TS_LOCAL], [OPERATOR_LOGOUT_TS_LOCAL],
            [BEARING], [DRILL_TOWER_ANGLE_DEGREE_CALCULATED], [DRILL_TOWER_ANGLE_DEGREE_SYSTEM],
            [DRILL_HOLE_DUPLICATED_FLAG], [DRILL_HOLE_UPSIDE_DOWN_FLAG],
            [DRILL_HOLE_START_END_TIME_INVALID_FLAG], [DRILL_HOLE_START_END_TIME_OVERLAP_FLAG],
            [DRILL_HOLE_DEPTH_INVALID_FLAG], [DRILL_HOLE_ANGLE_INVALID_FLAG],
            [DRILL_HOLE_POSITION_INVALID_FLAG], [TIME_BETWEEN_DRILL_HOLES_SECONDS],
            [AIR_PRESSURE_PSI], [FEED_FORCE_NEWTONS], [ROTATION_TORQUE_NM],
            [BIT_SPEED_RPM], [WATER_FLOW_GPM], [INSTANTANOUS_PENRATE_MWD_METERS_HOUR],
            [INSTANTANOUS_PENRATE_MWD_FEET_HOUR], [DRILL_HOLE_OFF_TARGET_FEET],
            [DRILL_HOLE_OFF_TARGET_METERS], [DRILL_HOLE_HORIZONTAL_ACCURACY_PCT],
            [DRILL_HOLE_VERTICAL_ACCURACY_PCT], [OVERDRILL_UNDERDRILL_FLAG],
            [OVERDRILL_UNDERDRILL_FEET], [OVERDRILL_UNDERDRILL_METERS],
            [DRILLING_STOPS_COUNT], [DRILL_HOLE_REDRILL_FLAG], [PROPEL_START_TS_UTC],
            [PROPEL_END_TS_UTC], [PARK_POSITION_START_TS_UTC], [PARK_POSITION_END_TS_UTC],
            [LEVEL_START_TS_UTC], [LEVEL_END_TS_UTC], [DRILL_START_TS_UTC],
            [DRILL_END_TS_UTC], [RETRACT_START_TS_UTC], [RETRACT_END_TS_UTC],
            [PROPEL_START_TS_LOCAL], [PROPEL_END_TS_LOCAL], [PARK_POSITION_START_TS_LOCAL],
            [PARK_POSITION_END_TS_LOCAL], [LEVEL_START_TS_LOCAL], [LEVEL_END_TS_LOCAL],
            [DRILL_START_TS_LOCAL], [DRILL_END_TS_LOCAL], [RETRACT_START_TS_LOCAL],
            [RETRACT_END_TS_LOCAL], [PROPEL_DURATION], [PARK_POSITION_DURATION],
            [LEVEL_DURATION], [DRILL_DURATION], [RETRACT_DURATION],
            [SYSTEM_DRILL_STATE_DURATION_SECONDS], [SYSTEM_SETUP_STATE_DURATION_SECONDS],
            [SYSTEM_AUTO_LEVEL_DURATION_SECONDS], [SYSTEM_AUTO_DELEVEL_DURATION_SECONDS],
            [PLAN_CREATION_TS_LOCAL], [SYSTEM_VERSION], [ACTUAL_MCF_BLOCK_ID],
            [DESIGN_MCF_BLOCK_ID], [DW_LOGICAL_DELETE_FLAG], [DW_LOAD_TS], [DW_MODIFY_TS]
        )
        VALUES (
            source.[ORIG_SRC_ID], source.[SITE_CODE], source.[BENCH], source.[PUSHBACK],
            source.[PATTERN_NAME], source.[ORIGINAL_PATTERN_NAME], source.[DRILL_CYCLE_SK],
            source.[DRILL_HOLE_SHIFT_ID], source.[DRILL_ID], source.[DRILL_BIT_ID],
            source.[SYSTEM_OPERATOR_ID], source.[DRILL_HOLE_ID], source.[DRILL_HOLE_NAME],
            source.[DRILL_PLAN_SK], source.[DRILL_HOLE_STATUS], source.[IS_HOLE_PLANNED_FLAG],
            source.[START_HOLE_TS_UTC], source.[END_HOLE_TS_UTC], source.[START_HOLE_TS_LOCAL],
            source.[END_HOLE_TS_LOCAL], source.[DRILL_HOLE_DURATION_SECONDS],
            source.[ACTUAL_DRILL_HOLE_DEPTH_FEET], source.[ACTUAL_DRILL_HOLE_DEPTH_METERS],
            source.[GPS_ACCURACY], source.[ACTUAL_DRILL_HOLE_START_FEET_X],
            source.[ACTUAL_DRILL_HOLE_START_FEET_Y], source.[ACTUAL_DRILL_HOLE_START_FEET_Z],
            source.[ACTUAL_DRILL_HOLE_END_FEET_X], source.[ACTUAL_DRILL_HOLE_END_FEET_Y],
            source.[ACTUAL_DRILL_HOLE_END_FEET_Z], source.[ACTUAL_DRILL_HOLE_LONGITUDE],
            source.[ACTUAL_DRILL_HOLE_LATITUDE], source.[ACTUAL_DRILL_HOLE_START_METERS_X],
            source.[ACTUAL_DRILL_HOLE_START_METERS_Y], source.[ACTUAL_DRILL_HOLE_START_METERS_Z],
            source.[ACTUAL_DRILL_HOLE_END_METERS_X], source.[ACTUAL_DRILL_HOLE_END_METERS_Y],
            source.[ACTUAL_DRILL_HOLE_END_METERS_Z], source.[AUTODRILL_DURATION_SECONDS],
            source.[AUTODRILL_USAGE_PCT], source.[DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR],
            source.[OPERATOR_LOGIN_TS_UTC], source.[OPERATOR_LOGOUT_TS_UTC],
            source.[OPERATOR_LOGIN_TS_LOCAL], source.[OPERATOR_LOGOUT_TS_LOCAL],
            source.[BEARING], source.[DRILL_TOWER_ANGLE_DEGREE_CALCULATED],
            source.[DRILL_TOWER_ANGLE_DEGREE_SYSTEM], source.[DRILL_HOLE_DUPLICATED_FLAG],
            source.[DRILL_HOLE_UPSIDE_DOWN_FLAG], source.[DRILL_HOLE_START_END_TIME_INVALID_FLAG],
            source.[DRILL_HOLE_START_END_TIME_OVERLAP_FLAG], source.[DRILL_HOLE_DEPTH_INVALID_FLAG],
            source.[DRILL_HOLE_ANGLE_INVALID_FLAG], source.[DRILL_HOLE_POSITION_INVALID_FLAG],
            source.[TIME_BETWEEN_DRILL_HOLES_SECONDS], source.[AIR_PRESSURE_PSI],
            source.[FEED_FORCE_NEWTONS], source.[ROTATION_TORQUE_NM], source.[BIT_SPEED_RPM],
            source.[WATER_FLOW_GPM], source.[INSTANTANOUS_PENRATE_MWD_METERS_HOUR],
            source.[INSTANTANOUS_PENRATE_MWD_FEET_HOUR], source.[DRILL_HOLE_OFF_TARGET_FEET],
            source.[DRILL_HOLE_OFF_TARGET_METERS], source.[DRILL_HOLE_HORIZONTAL_ACCURACY_PCT],
            source.[DRILL_HOLE_VERTICAL_ACCURACY_PCT], source.[OVERDRILL_UNDERDRILL_FLAG],
            source.[OVERDRILL_UNDERDRILL_FEET], source.[OVERDRILL_UNDERDRILL_METERS],
            source.[DRILLING_STOPS_COUNT], source.[DRILL_HOLE_REDRILL_FLAG],
            source.[PROPEL_START_TS_UTC], source.[PROPEL_END_TS_UTC],
            source.[PARK_POSITION_START_TS_UTC], source.[PARK_POSITION_END_TS_UTC],
            source.[LEVEL_START_TS_UTC], source.[LEVEL_END_TS_UTC], source.[DRILL_START_TS_UTC],
            source.[DRILL_END_TS_UTC], source.[RETRACT_START_TS_UTC], source.[RETRACT_END_TS_UTC],
            source.[PROPEL_START_TS_LOCAL], source.[PROPEL_END_TS_LOCAL],
            source.[PARK_POSITION_START_TS_LOCAL], source.[PARK_POSITION_END_TS_LOCAL],
            source.[LEVEL_START_TS_LOCAL], source.[LEVEL_END_TS_LOCAL],
            source.[DRILL_START_TS_LOCAL], source.[DRILL_END_TS_LOCAL],
            source.[RETRACT_START_TS_LOCAL], source.[RETRACT_END_TS_LOCAL],
            source.[PROPEL_DURATION], source.[PARK_POSITION_DURATION], source.[LEVEL_DURATION],
            source.[DRILL_DURATION], source.[RETRACT_DURATION],
            source.[SYSTEM_DRILL_STATE_DURATION_SECONDS], source.[SYSTEM_SETUP_STATE_DURATION_SECONDS],
            source.[SYSTEM_AUTO_LEVEL_DURATION_SECONDS], source.[SYSTEM_AUTO_DELEVEL_DURATION_SECONDS],
            source.[PLAN_CREATION_TS_LOCAL], source.[SYSTEM_VERSION], source.[ACTUAL_MCF_BLOCK_ID],
            source.[DESIGN_MCF_BLOCK_ID], source.[DW_LOGICAL_DELETE_FLAG],
            source.[DW_LOAD_TS], source.[DW_MODIFY_TS]
        );
    
    SELECT @@ROWCOUNT AS RowsAffected;
END
"""

cursor.execute(merge_proc)
conn.commit()
print('   ✅ Procedure usp_Merge_DRILL_CYCLE creado/actualizado')

# ============================================================
# VERIFICACIÓN FINAL
# ============================================================
print('\n' + '=' * 80)
print('VERIFICACIÓN FINAL')
print('=' * 80)

# Verificar columnas de la tabla
cursor.execute("""
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'DRILL_CYCLE' AND TABLE_SCHEMA = 'dbo'
""")
col_count = cursor.fetchone()[0]
print(f'\n📋 Tabla DRILL_CYCLE: {col_count} columnas')

# Verificar procedure existe
cursor.execute("""
    SELECT name FROM sys.procedures WHERE name = 'usp_Merge_DRILL_CYCLE'
""")
proc = cursor.fetchone()
print(f'⚙️ Procedure: {proc[0] if proc else "NO EXISTE"}')

conn.close()

print('\n' + '=' * 80)
print('✅ ¡COMPLETADO!')
print('=' * 80)
