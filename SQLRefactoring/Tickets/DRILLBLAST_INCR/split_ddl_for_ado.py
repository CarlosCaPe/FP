"""
Split DDL into ADO-compatible folder structure with Jinja2 templates
=====================================================================
Target structure (matching Snowflake_NA repo):

DDL-Scripts/
  API_REF/
    FUSE/
      TABLES/
        R__BL_DW_BLAST_INCR.sql
        R__BLAST_PLAN_EXECUTION_INCR.sql
        ...
      PROCEDURES/
        R__BL_DW_BLAST_INCR_P.sql
        R__BLAST_PLAN_EXECUTION_INCR_P.sql
        ...

Template variables (from Snowflake_NA repo):
  {{ envi }}    = DEV | TEST | PROD (target environment)
  {{ RO_PROD }} = PROD (read-only source, always PROD)
  {{ RO_DEV }}  = DEV (read-only source)
  {{ RO_TEST }} = TEST (read-only source)

Example: 
  Target: {{ envi }}_API_REF.FUSE.TABLE_NAME
  Source: {{ RO_PROD }}_WG.DRILL_BLAST.TABLE_NAME
"""

import snowflake.connector
import os
import re
from datetime import datetime
from pathlib import Path

# Load environment variables from root .env
from dotenv import load_dotenv
root_env = Path(__file__).parent.parent.parent / ".env"
load_dotenv(root_env)

# Also load local .env for SNOWFLAKE_ENV override
local_env = Path(__file__).parent / ".env"
load_dotenv(local_env, override=True)

# =============================================================================
# Configuration from .env
# =============================================================================
ENV = os.getenv("SNOWFLAKE_ENV", "DEV")  # DEV, TEST, PROD
SOURCE_DATABASE = f"{ENV}_API_REF"
SCHEMA = "FUSE"

INCR_TABLES = [
    "BL_DW_BLAST_INCR",
    "BL_DW_BLASTPROPERTYVALUE_INCR",
    "BL_DW_HOLE_INCR",
    "BLAST_PLAN_INCR",
    "BLAST_PLAN_EXECUTION_INCR",
    "DRILL_CYCLE_INCR",
    "DRILL_PLAN_INCR",
    "DRILLBLAST_EQUIPMENT_INCR",
    "DRILLBLAST_OPERATOR_INCR",
    "DRILLBLAST_SHIFT_INCR",
    "LH_HAUL_CYCLE_INCR"
]

# Output base path - matches ADO repo structure
OUTPUT_BASE = os.path.join(os.path.dirname(__file__), "DDL-Scripts")

# =============================================================================
# Template replacement - convert hardcoded env to Jinja2 templates
# =============================================================================
def templatize_ddl(ddl: str, object_type: str, object_name: str) -> str:
    """
    Replace hardcoded database references with Jinja2 template variables.
    Also add full qualified name to CREATE statements.
    
    Target database (DEV/TEST/PROD_API_REF) -> {{ envi }}_API_REF
    Source database (PROD_WG) -> {{ RO_PROD }}_WG (always PROD for source)
    """
    # Target: DEV_API_REF, TEST_API_REF, PROD_API_REF -> {{ envi }}_API_REF
    ddl = re.sub(r'(DEV|TEST|PROD)_API_REF', r'{{ envi }}_API_REF', ddl, flags=re.IGNORECASE)
    
    # Source: PROD_WG (read from production) -> {{ RO_PROD }}_WG
    ddl = re.sub(r'PROD_WG', r'{{ RO_PROD }}_WG', ddl, flags=re.IGNORECASE)
    
    # Add full qualified name to CREATE TABLE statements
    # Pattern: create or replace TABLE TABLE_NAME (
    # Replace with: create or replace TABLE {{ envi }}_API_REF.FUSE.TABLE_NAME (
    if object_type == 'TABLE':
        ddl = re.sub(
            rf'(create\s+or\s+replace\s+TABLE\s+){re.escape(object_name)}(\s*\()',
            rf'\g<1>{{{{ envi }}}}_API_REF.FUSE.{object_name}\2',
            ddl,
            flags=re.IGNORECASE
        )
    
    # Add full qualified name to CREATE PROCEDURE statements
    # Pattern: CREATE OR REPLACE PROCEDURE "PROC_NAME"(
    # Replace with: CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.PROC_NAME(
    if object_type == 'PROCEDURE':
        # Handle quoted procedure names
        ddl = re.sub(
            rf'(CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+)"{re.escape(object_name)}"(\s*\()',
            rf'\g<1>{{{{ envi }}}}_API_REF.FUSE.{object_name}\2',
            ddl,
            flags=re.IGNORECASE
        )
        # Handle unquoted procedure names
        ddl = re.sub(
            rf'(CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+){re.escape(object_name)}(\s*\()',
            rf'\g<1>{{{{ envi }}}}_API_REF.FUSE.{object_name}\2',
            ddl,
            flags=re.IGNORECASE
        )
    
    return ddl

# =============================================================================
# Main
# =============================================================================
def main():
    print("=" * 76)
    print("Splitting DDL into ADO folder structure with Jinja2 templates")
    print(f"Source: {SOURCE_DATABASE}.{SCHEMA}")
    print(f"Started: {datetime.now().isoformat()}")
    print("=" * 76)

    # Create folder structure: DDL-Scripts/API_REF/FUSE/{TABLES,PROCEDURES}
    tables_dir = os.path.join(OUTPUT_BASE, "API_REF", SCHEMA, "TABLES")
    procs_dir = os.path.join(OUTPUT_BASE, "API_REF", SCHEMA, "PROCEDURES")
    
    os.makedirs(tables_dir, exist_ok=True)
    os.makedirs(procs_dir, exist_ok=True)
    
    print(f"\nFolder structure:")
    print(f"  {tables_dir}")
    print(f"  {procs_dir}")

    # Connect to Snowflake
    conn = snowflake.connector.connect(
        account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
        authenticator="externalbrowser",
        user="ccarrill2@fmi.com",
        warehouse="WH_BATCH_DE",
        database=SOURCE_DATABASE,
        schema=SCHEMA
    )
    cursor = conn.cursor()
    
    print(f"\n" + "-" * 76)
    print("TABLES")
    print("-" * 76)
    
    tables_ok = 0
    for table_name in INCR_TABLES:
        print(f"  {table_name}...")
        try:
            cursor.execute(f"SELECT GET_DDL('TABLE', '{SOURCE_DATABASE}.{SCHEMA}.{table_name}')")
            ddl = cursor.fetchone()[0]
            
            # Apply template variable and add full qualified name
            ddl = templatize_ddl(ddl, 'TABLE', table_name)
            
            # Write file (no header, just clean DDL like in the repo)
            file_path = os.path.join(tables_dir, f"R__{table_name}.sql")
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(ddl)
                if not ddl.strip().endswith(';'):
                    f.write(";")
                f.write("\n")
            
            print(f"    ✅ R__{table_name}.sql")
            tables_ok += 1
        except Exception as e:
            print(f"    ❌ {table_name}: {str(e)[:60]}")
    
    print(f"\n  Tables: {tables_ok}/{len(INCR_TABLES)}")
    
    print(f"\n" + "-" * 76)
    print("PROCEDURES")
    print("-" * 76)
    
    procs_ok = 0
    for table_name in INCR_TABLES:
        proc_name = f"{table_name}_P"
        print(f"  {proc_name}...")
        try:
            cursor.execute(f"SELECT GET_DDL('PROCEDURE', '{SOURCE_DATABASE}.{SCHEMA}.{proc_name}(VARCHAR)')")
            ddl = cursor.fetchone()[0]
            
            # Apply template variable and add full qualified name
            ddl = templatize_ddl(ddl, 'PROCEDURE', proc_name)
            
            # Write file
            file_path = os.path.join(procs_dir, f"R__{proc_name}.sql")
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(ddl)
                f.write("\n")
            
            print(f"    ✅ R__{proc_name}.sql")
            procs_ok += 1
        except Exception as e:
            print(f"    ❌ {proc_name}: {str(e)[:60]}")
    
    print(f"\n  Procedures: {procs_ok}/{len(INCR_TABLES)}")
    
    cursor.close()
    conn.close()
    
    # Summary
    print("\n" + "=" * 76)
    print("✅ COMPLETE")
    print("=" * 76)
    print(f"\nOutput:")
    print(f"  DDL-Scripts/")
    print(f"    API_REF/")
    print(f"      {SCHEMA}/")
    print(f"        TABLES/     ({tables_ok} files)")
    print(f"        PROCEDURES/ ({procs_ok} files)")
    print(f"\nTemplate: {{{{ env }}}}_API_REF (ADO replaces with DEV/TEST/PROD)")
    print(f"\nCopy to: https://dev.azure.com/fmvso/BI-EDW/_git/Snowflake_NA/DDL-Scripts/API_REF/FUSE/")

if __name__ == "__main__":
    main()
