"""
Generate _INCR DDL files for DrillBlast tables
==============================================
Following the pattern from LH_BUCKET_INCR (refactor_ddl_v2.sql)

Tables to create:
1. LH_HAUL_CYCLE_INCR (first priority per Vikas)
2. BL_DW_BLAST_INCR
3. BL_DW_BLASTPROPERTYVALUE_INCR
4. BL_DW_HOLE_INCR
5. BLAST_PLAN_INCR
6. BLAST_PLAN_EXECUTION_INCR
7. DRILL_CYCLE_INCR
8. DRILL_PLAN_INCR
9. DRILLBLAST_EQUIPMENT_INCR
10. DRILLBLAST_OPERATOR_INCR
11. DRILLBLAST_SHIFT_INCR

Pattern: MERGE-driven upserts with hash-based conditional updates
Suffix: _INCR (not _CT)
Objects: TABLE + PROCEDURE only (no TASK per Vikas)
"""

import snowflake.connector
from pathlib import Path
import os

# Configuration
TABLES_CONFIG = [
    {
        "name": "LH_HAUL_CYCLE",
        "source_schema": "PROD_WG.LOAD_HAUL",
        "source_view": "LH_HAUL_CYCLE_V",
        "primary_key": ["HAUL_CYCLE_ID"],
        "timestamp_column": "CYCLE_END_TS_LOCAL",
        "description": "Haulage cycle data - truck movements from load to dump"
    },
    {
        "name": "BL_DW_BLAST",
        "source_schema": "PROD_WG.DRILLBLAST",
        "source_view": "BL_DW_BLAST",
        "primary_key": ["ORIG_SRC_ID", "SITE_CODE", "ID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Blast event master data"
    },
    {
        "name": "BL_DW_BLASTPROPERTYVALUE",
        "source_schema": "PROD_WG.DRILLBLAST",
        "source_view": "BL_DW_BLASTPROPERTYVALUE",
        "primary_key": ["ORIG_SRC_ID", "SITE_CODE", "BLASTID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Blast property values and parameters"
    },
    {
        "name": "BL_DW_HOLE",
        "source_schema": "PROD_WG.DRILLBLAST",
        "source_view": "BL_DW_HOLE",
        "primary_key": ["ORIG_SRC_ID", "SITE_CODE", "ID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Drill hole details within blasts"
    },
    {
        "name": "BLAST_PLAN",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "BLAST_PLAN",
        "primary_key": ["BLAST_PLAN_SK"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Blast planning data"
    },
    {
        "name": "BLAST_PLAN_EXECUTION",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "BLAST_PLAN_EXECUTION",
        "primary_key": ["ORIG_SRC_ID", "SITE_CODE", "BENCH", "PUSHBACK", "PATTERN_NAME", "BLAST_NAME", "DRILLED_HOLE_ID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Blast execution data"
    },
    {
        "name": "DRILL_CYCLE",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "DRILL_CYCLE",
        "primary_key": ["DRILL_CYCLE_SK"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Drill cycle metrics per hole"
    },
    {
        "name": "DRILL_PLAN",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "DRILL_PLAN",
        "primary_key": ["DRILL_PLAN_SK"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Drill planning data"
    },
    {
        "name": "DRILLBLAST_EQUIPMENT",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "DRILLBLAST_EQUIPMENT",
        "primary_key": ["ORIG_SRC_ID", "SITE_CODE", "DRILL_ID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Drill equipment master data"
    },
    {
        "name": "DRILLBLAST_OPERATOR",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "DRILLBLAST_OPERATOR",
        "primary_key": ["SYSTEM_OPERATOR_ID", "SITE_CODE"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Drill operator master data"
    },
    {
        "name": "DRILLBLAST_SHIFT",
        "source_schema": "PROD_WG.DRILL_BLAST",
        "source_view": "DRILLBLAST_SHIFT",
        "primary_key": ["SITE_CODE", "SHIFT_ID"],
        "timestamp_column": "DW_MODIFY_TS",
        "description": "Shift definitions for drill/blast operations"
    }
]

TARGET_SCHEMA = "DEV_API_REF.FUSE"
OUTPUT_DIR = Path(__file__).parent / "DRILLBLAST_INCR"


def get_snowflake_connection():
    """Connect to Snowflake using externalbrowser auth."""
    return snowflake.connector.connect(
        account="FCX-NA",
        authenticator="externalbrowser",
        warehouse="WH_BATCH_DE_NONPROD",
        database="PROD_WG",
        role="ROLE_API_REF_RW"
    )


def get_column_info(conn, source_schema: str, source_view: str) -> list:
    """Get column definitions from source view."""
    query = f"""
    SELECT 
        COLUMN_NAME,
        DATA_TYPE,
        NUMERIC_PRECISION,
        NUMERIC_SCALE,
        CHARACTER_MAXIMUM_LENGTH,
        IS_NULLABLE,
        COLLATION_NAME
    FROM {source_schema.split('.')[0]}.INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{source_schema.split('.')[1] if '.' in source_schema else source_schema}'
      AND TABLE_NAME = '{source_view}'
    ORDER BY ORDINAL_POSITION
    """
    cursor = conn.cursor()
    cursor.execute(query)
    return cursor.fetchall()


def format_column_type(col_info: tuple) -> str:
    """Format column type from metadata."""
    col_name, data_type, precision, scale, char_len, nullable, collation = col_info
    
    if data_type == 'NUMBER':
        if precision and scale is not None:
            type_str = f"NUMBER({precision},{scale})"
        elif precision:
            type_str = f"NUMBER({precision},0)"
        else:
            type_str = "NUMBER"
    elif data_type in ('VARCHAR', 'TEXT'):
        if char_len:
            type_str = f"VARCHAR({char_len})"
        else:
            type_str = "VARCHAR"
        if collation:
            type_str += f" COLLATE '{collation}'"
    elif data_type == 'TIMESTAMP_NTZ':
        type_str = "TIMESTAMP_NTZ(9)"
    elif data_type == 'TIMESTAMP_LTZ':
        type_str = "TIMESTAMP_LTZ(9)"
    elif data_type == 'TIMESTAMP_TZ':
        type_str = "TIMESTAMP_TZ(9)"
    elif data_type == 'FLOAT':
        type_str = "FLOAT"
    elif data_type == 'BOOLEAN':
        type_str = "BOOLEAN"
    elif data_type == 'DATE':
        type_str = "DATE"
    else:
        type_str = data_type
    
    return type_str


def generate_ddl(config: dict, columns: list) -> str:
    """Generate the full DDL for table and procedure."""
    name = config["name"]
    source = f"{config['source_schema']}.{config['source_view']}"
    pk_cols = config["primary_key"]
    ts_col = config["timestamp_column"]
    desc = config["description"]
    
    # Column definitions
    col_defs = []
    col_names = []
    hash_cols = []
    
    for col in columns:
        col_name = col[0]
        col_type = format_column_type(col)
        col_names.append(col_name.lower())
        
        # Skip PK and timestamp from hash
        if col_name.upper() not in [c.upper() for c in pk_cols] and col_name.upper() not in ['DW_LOAD_TS', 'DW_MODIFY_TS', 'DW_LOGICAL_DELETE_FLAG']:
            hash_cols.append(col_name.lower())
        
        col_defs.append(f"    {col_name.upper():<40} {col_type}")
    
    # Add audit columns if not present
    audit_cols = ['DW_LOGICAL_DELETE_FLAG', 'DW_LOAD_TS', 'DW_MODIFY_TS']
    for ac in audit_cols:
        if ac.lower() not in [c.lower() for c in col_names]:
            if ac == 'DW_LOGICAL_DELETE_FLAG':
                col_defs.append(f"    {ac:<40} VARCHAR(1) DEFAULT 'N'")
            else:
                col_defs.append(f"    {ac:<40} TIMESTAMP_NTZ(0)")
            col_names.append(ac.lower())
    
    # Build DDL
    ddl = f"""-- =============================================================================
-- {name}_INCR - Incremental Table and Procedure
-- Target: {TARGET_SCHEMA}.{name}_INCR
-- =============================================================================
-- Author: Carlos Carrillo (based on DRILLBLAST pattern by Hidayath)
-- Date: 2026-01-23
-- Pattern: MERGE-driven upserts with hash-based conditional updates
-- Incremental window: 3 days (default)
-- Description: {desc}
-- =============================================================================
-- Source: {source}
-- Business Key: {', '.join(pk_cols)}
-- Timestamp for incremental: {ts_col}
-- =============================================================================


-- ============================================================================
-- STEP 1: CREATE INCR TABLE
-- ============================================================================
CREATE OR REPLACE TABLE {TARGET_SCHEMA}.{name}_INCR (
{chr(10).join([c + ',' for c in col_defs[:-1]])}
{col_defs[-1]}
)
COMMENT = 'Incremental table for {name} - MERGE-driven upserts with 3-day incremental window';


-- ============================================================================
-- STEP 2: CREATE INCR PROCEDURE
-- ============================================================================
CREATE OR REPLACE PROCEDURE {TARGET_SCHEMA}.{name}_INCR_P("NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3')
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : The {name}_INCR_P procedure merges data from the source view 
*             into the {name}_INCR incremental table.
*             Processes data from last 3 days (default), max 30 days.
*
* NOTES     : IROC project - Incremental table for Snowflake to SQL sync
*             using high watermark strategy.
*
* USAGE     : CALL {TARGET_SCHEMA}.{name}_INCR_P(''3'');
*
* SOURCE    : {source}
* TARGET    : {TARGET_SCHEMA}.{name}_INCR
* BUSINESS KEY: {', '.join(pk_cols)}
* INCREMENTAL COLUMN: {ts_col}
*
* CREATE/CHANGE LOG :
* DATE                     MOD BY                GCC                         DESC
*------------------------------------------------------------------------------------------
* 2026-01-23:             CARLOS CARRILLO       IROC Incremental            Initial Version
******************************************************************************************/

var sp_result="";
var sql_count_incr="";
var rs_count_incr="";
var rs_records_incr="";
var sql_delete_incr="";
var rs_delete_incr="";
var rs_deleted_records_incr="";
var sql_merge="";
var rs_merge="";
var rs_merged_records=""
var sql_delete="";
var rs_delete="";
var rs_delete_records="";

// Count records outside the lookback window
sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {TARGET_SCHEMA.lower()}.{name.lower()}_incr 
                  WHERE {ts_col.lower()}::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// Delete records outside the lookback window
sql_delete_incr = `DELETE FROM {TARGET_SCHEMA.lower()}.{name.lower()}_incr 
                   WHERE {ts_col.lower()}::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// MERGE: Upsert new/changed records
sql_merge = `MERGE INTO {TARGET_SCHEMA.lower()}.{name.lower()}_incr tgt
USING (
    SELECT
        {(',' + chr(10) + '        ').join(col_names)},
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts_new,
        CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_modify_ts_new
    FROM {source.lower()}
    WHERE {ts_col.lower()}::date >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE)
) AS src

ON {' AND '.join([f'tgt.{pk.lower()} = src.{pk.lower()}' for pk in pk_cols])}

WHEN MATCHED AND HASH(
    {(',' + chr(10) + '    ').join([f'src.{c}' for c in hash_cols[:20]])}
) <> HASH(
    {(',' + chr(10) + '    ').join([f'tgt.{c}' for c in hash_cols[:20]])}
) THEN UPDATE SET
    {(',' + chr(10) + '    ').join([f'tgt.{c} = src.{c}' for c in col_names if c.lower() not in ['dw_load_ts', 'dw_logical_delete_flag']])},
    tgt.dw_modify_ts = src.dw_modify_ts_new

WHEN NOT MATCHED THEN INSERT (
    {(',' + chr(10) + '    ').join(col_names)}
) VALUES (
    {(',' + chr(10) + '    ').join([f'src.{c}' for c in col_names])}
);`;

// Soft delete: Mark records no longer in source
sql_delete = `UPDATE {TARGET_SCHEMA.lower()}.{name.lower()}_incr tgt
              SET dw_logical_delete_flag = ''Y'',
                  dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (
                  SELECT 1
                  FROM {source.lower()} src
                  WHERE {' AND '.join([f'src.{pk.lower()} = tgt.{pk.lower()}' for pk in pk_cols])}
              );`;

try {{
    snowflake.execute({{sqlText: "BEGIN WORK;"}});

    rs_count_incr = snowflake.execute({{sqlText: sql_count_incr}});
    rs_count_incr.next();
    var rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');

    if (rs_records_incr > 0) {{
        rs_delete_incr = snowflake.execute({{sqlText: sql_delete_incr}});
        rs_deleted_records_incr = rs_delete_incr.getNumRowsAffected();
        
        rs_merge = snowflake.execute({{sqlText: sql_merge}});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        rs_delete = snowflake.execute({{sqlText: sql_delete}});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Deleted: " + rs_deleted_records_incr + ", Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    }} else {{
        rs_merge = snowflake.execute({{sqlText: sql_merge}});
        rs_merged_records = rs_merge.getNumRowsAffected();
        
        rs_delete = snowflake.execute({{sqlText: sql_delete}});
        rs_delete_records = rs_delete.getNumRowsAffected();
        
        sp_result = "Merged: " + rs_merged_records + ", Archived: " + rs_delete_records;
    }}

    snowflake.execute({{sqlText: "COMMIT WORK;"}});
    return sp_result;
}}
catch (err) {{
    snowflake.execute({{sqlText: "ROLLBACK WORK;"}});
    throw err;
}}
return sp_result;
';


-- ============================================================================
-- TESTING QUERIES
-- ============================================================================
-- Initial load (30 days):
-- CALL {TARGET_SCHEMA}.{name}_INCR_P('30');

-- Regular refresh (3 days):
-- CALL {TARGET_SCHEMA}.{name}_INCR_P('3');

-- Verify row counts:
-- SELECT COUNT(*) FROM {TARGET_SCHEMA}.{name}_INCR;

-- Check logical deletes:
-- SELECT dw_logical_delete_flag, COUNT(*) 
-- FROM {TARGET_SCHEMA}.{name}_INCR 
-- GROUP BY dw_logical_delete_flag;
"""
    return ddl


def main():
    """Generate DDL files for all tables."""
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    print("=" * 60)
    print("Generating INCR DDL files for DrillBlast tables")
    print("=" * 60)
    
    conn = get_snowflake_connection()
    
    for config in TABLES_CONFIG:
        name = config["name"]
        print(f"\n📄 Processing {name}...")
        
        try:
            # Get column info
            columns = get_column_info(conn, config["source_schema"], config["source_view"])
            
            if not columns:
                print(f"  ⚠️ No columns found for {config['source_schema']}.{config['source_view']}")
                continue
            
            print(f"  ✅ Found {len(columns)} columns")
            
            # Generate DDL
            ddl = generate_ddl(config, columns)
            
            # Write file
            output_file = OUTPUT_DIR / f"{name}_INCR.sql"
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(ddl)
            
            print(f"  ✅ Written to {output_file.name}")
            
        except Exception as e:
            print(f"  ❌ Error: {e}")
    
    conn.close()
    print("\n" + "=" * 60)
    print(f"Done! Check {OUTPUT_DIR}")
    print("=" * 60)


if __name__ == "__main__":
    main()
