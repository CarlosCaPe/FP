"""
Validate DDL scripts for ADO deployment
========================================
Checks all generated DDL files against organization standards.

Run this BEFORE sending scripts to Vikas/ADO team.
"""

import os
import re
from pathlib import Path

# =============================================================================
# Configuration
# =============================================================================
DDL_PATH = Path(__file__).parent / "DDL-Scripts" / "API_REF" / "FUSE"
EXPECTED_TABLES = [
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

# =============================================================================
# Validation Functions
# =============================================================================
def validate_file_exists(folder: str, name: str) -> tuple[bool, str]:
    """Check if file exists with correct R__ prefix"""
    file_path = DDL_PATH / folder / f"R__{name}.sql"
    if file_path.exists():
        return True, str(file_path)
    return False, f"Missing: R__{name}.sql"

def validate_create_statement(file_path: Path, object_type: str, object_name: str) -> list[str]:
    """Validate CREATE statement has full qualified name with {{ envi }}"""
    errors = []
    content = file_path.read_text(encoding='utf-8')
    
    if object_type == "TABLE":
        # Check for: create or replace TABLE {{ envi }}_API_REF.FUSE.<NAME>
        pattern = rf'create\s+or\s+replace\s+TABLE\s+\{{\{{\s*envi\s*\}}\}}_API_REF\.FUSE\.{re.escape(object_name)}\s*\('
        if not re.search(pattern, content, re.IGNORECASE):
            errors.append(f"Missing full qualified name in CREATE TABLE for {object_name}")
            # Check what's actually there
            match = re.search(r'create\s+or\s+replace\s+TABLE\s+(\S+)\s*\(', content, re.IGNORECASE)
            if match:
                errors.append(f"  Found: CREATE TABLE {match.group(1)}")
                errors.append(f"  Expected: CREATE TABLE {{{{ envi }}}}_API_REF.FUSE.{object_name}")
    
    elif object_type == "PROCEDURE":
        # Check for: CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.<NAME>
        pattern = rf'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+\{{\{{\s*envi\s*\}}\}}_API_REF\.FUSE\.{re.escape(object_name)}\s*\('
        if not re.search(pattern, content, re.IGNORECASE):
            errors.append(f"Missing full qualified name in CREATE PROCEDURE for {object_name}")
            match = re.search(r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+(\S+)\s*\(', content, re.IGNORECASE)
            if match:
                errors.append(f"  Found: CREATE PROCEDURE {match.group(1)}")
                errors.append(f"  Expected: CREATE PROCEDURE {{{{ envi }}}}_API_REF.FUSE.{object_name}")
    
    return errors

def validate_no_hardcoded_env(file_path: Path) -> list[str]:
    """Check for hardcoded DEV_API_REF, TEST_API_REF, PROD_API_REF"""
    errors = []
    content = file_path.read_text(encoding='utf-8')
    
    # Check for hardcoded environment references
    for env in ['DEV_API_REF', 'TEST_API_REF', 'PROD_API_REF']:
        if env in content.upper():
            matches = re.findall(rf'{env}', content, re.IGNORECASE)
            errors.append(f"Hardcoded {env} found ({len(matches)} occurrences)")
    
    # Check for hardcoded PROD_WG (should be {{ RO_PROD }}_WG)
    if 'PROD_WG' in content.upper() and '{{ RO_PROD }}_WG' not in content:
        errors.append("Hardcoded PROD_WG found (should be {{ RO_PROD }}_WG)")
    
    return errors

def validate_template_variables(file_path: Path) -> list[str]:
    """Check for valid template variables"""
    errors = []
    content = file_path.read_text(encoding='utf-8')
    
    # Find all template variables
    templates = re.findall(r'\{\{.*?\}\}', content)
    valid_templates = ['{{ envi }}', '{{ RO_PROD }}', '{{ RO_DEV }}', '{{ RO_TEST }}', 
                       '{{envi}}', '{{RO_PROD}}', '{{RO_DEV}}', '{{RO_TEST}}']
    
    for t in templates:
        # Normalize whitespace for comparison
        normalized = re.sub(r'\s+', '', t)
        if normalized not in [re.sub(r'\s+', '', v) for v in valid_templates]:
            errors.append(f"Unknown template variable: {t}")
    
    return errors

def validate_sql_syntax(file_path: Path) -> list[str]:
    """Basic SQL syntax validation"""
    errors = []
    content = file_path.read_text(encoding='utf-8')
    
    # Check for common issues
    if content.count('(') != content.count(')'):
        errors.append("Mismatched parentheses")
    
    # Check for unclosed quotes (basic check)
    single_quotes = content.count("'") - content.count("\\'")
    if single_quotes % 2 != 0:
        errors.append("Possible unclosed single quote")
    
    return errors

# =============================================================================
# Main
# =============================================================================
def main():
    print("=" * 76)
    print("DDL Validation for ADO Deployment")
    print("=" * 76)
    
    all_errors = []
    tables_ok = 0
    procs_ok = 0
    
    # Validate Tables
    print("\n📋 TABLES")
    print("-" * 40)
    for table_name in EXPECTED_TABLES:
        exists, msg = validate_file_exists("TABLES", table_name)
        if not exists:
            print(f"  ❌ {table_name}: {msg}")
            all_errors.append(msg)
            continue
        
        file_path = DDL_PATH / "TABLES" / f"R__{table_name}.sql"
        errors = []
        errors.extend(validate_create_statement(file_path, "TABLE", table_name))
        errors.extend(validate_no_hardcoded_env(file_path))
        errors.extend(validate_template_variables(file_path))
        errors.extend(validate_sql_syntax(file_path))
        
        if errors:
            print(f"  ❌ {table_name}")
            for e in errors:
                print(f"      {e}")
                all_errors.append(f"{table_name}: {e}")
        else:
            print(f"  ✅ R__{table_name}.sql")
            tables_ok += 1
    
    # Validate Procedures
    print("\n📋 PROCEDURES")
    print("-" * 40)
    for table_name in EXPECTED_TABLES:
        proc_name = f"{table_name}_P"
        exists, msg = validate_file_exists("PROCEDURES", proc_name)
        if not exists:
            print(f"  ❌ {proc_name}: {msg}")
            all_errors.append(msg)
            continue
        
        file_path = DDL_PATH / "PROCEDURES" / f"R__{proc_name}.sql"
        errors = []
        errors.extend(validate_create_statement(file_path, "PROCEDURE", proc_name))
        errors.extend(validate_no_hardcoded_env(file_path))
        errors.extend(validate_template_variables(file_path))
        errors.extend(validate_sql_syntax(file_path))
        
        if errors:
            print(f"  ❌ {proc_name}")
            for e in errors:
                print(f"      {e}")
                all_errors.append(f"{proc_name}: {e}")
        else:
            print(f"  ✅ R__{proc_name}.sql")
            procs_ok += 1
    
    # Summary
    print("\n" + "=" * 76)
    if all_errors:
        print(f"❌ VALIDATION FAILED")
        print(f"   Tables: {tables_ok}/{len(EXPECTED_TABLES)}")
        print(f"   Procedures: {procs_ok}/{len(EXPECTED_TABLES)}")
        print(f"   Errors: {len(all_errors)}")
        print("\n⚠️  DO NOT send to ADO until all errors are fixed!")
        return 1
    else:
        print(f"✅ VALIDATION PASSED")
        print(f"   Tables: {tables_ok}/{len(EXPECTED_TABLES)}")
        print(f"   Procedures: {procs_ok}/{len(EXPECTED_TABLES)}")
        print(f"   Total: {tables_ok + procs_ok} files ready for ADO")
        print("\n✅ Safe to send to Vikas/ADO team")
        return 0

if __name__ == "__main__":
    exit(main())
