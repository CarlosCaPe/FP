"""
COMPREHENSIVE REVIEW - For Vikas
"Please review all the changes before sending it across"

This script validates ALL Snowflake objects before SQL Server deployment
"""

import os
import re
from pathlib import Path
from datetime import datetime

def main():
    base = Path(r"C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR")
    deploy_dev = base / "DEPLOY_DEV"
    
    print("=" * 80)
    print("COMPREHENSIVE REVIEW - ALL CHANGES")
    print("For Vikas: 'Please review all the changes before sending it across'")
    print("=" * 80)
    print(f"Date: {datetime.now().isoformat()}")
    print()
    
    # Expected business columns per table (from dynamic tables logic)
    EXPECTED_COLUMNS = {
        "DRILL_CYCLE": "CYCLE_START_TS_LOCAL",
        "DRILL_PLAN": "PLAN_DATE", 
        "DRILLBLAST_SHIFT": "SHIFT_START_TS_LOCAL",
        "BLAST_PLAN": "PLAN_DATE",
        "BLAST_PLAN_EXECUTION": "BLAST_DT",
        "BL_DW_BLAST": "DW_MODIFY_TS",
        "BL_DW_BLASTPROPERTYVALUE": "DW_MODIFY_TS",
        "BL_DW_HOLE": "DW_MODIFY_TS",
        "DRILLBLAST_EQUIPMENT": "DW_MODIFY_TS",
        "DRILLBLAST_OPERATOR": "DW_MODIFY_TS",
        "LH_HAUL_CYCLE": "CYCLE_START_TS_LOCAL",
        "LH_LOADING_CYCLE": "CYCLE_START_TS_LOCAL",
        "LH_BUCKET": "TRIP_TS_LOCAL",
        "LH_EQUIPMENT_STATUS_EVENT": "START_TS_LOCAL",
    }
    
    issues = []
    passed = []
    
    # ========================================
    # REVIEW 1: TABLES - No DW_ROW_HASH column
    # ========================================
    print("=" * 80)
    print("REVIEW 1: TABLES - Checking for DW_ROW_HASH bug")
    print("=" * 80)
    
    tables_dir = deploy_dev / "TABLES"
    for f in sorted(tables_dir.glob("*.sql")):
        content = f.read_text(encoding="utf-8")
        name = f.stem.replace("R__", "")
        
        if "DW_ROW_HASH" in content:
            issues.append(f"❌ {name}: Contains DW_ROW_HASH column (BUG)")
            print(f"  ❌ {name}: Contains DW_ROW_HASH column")
        else:
            passed.append(f"✅ {name}: No DW_ROW_HASH")
            print(f"  ✅ {name}: No DW_ROW_HASH column")
    
    # ========================================
    # REVIEW 2: PROCEDURES - HASH comparison
    # ========================================
    print()
    print("=" * 80)
    print("REVIEW 2: PROCEDURES - HASH key for true delta detection")
    print("=" * 80)
    
    procs_dir = deploy_dev / "PROCEDURES"
    for f in sorted(procs_dir.glob("*.sql")):
        content = f.read_text(encoding="utf-8")
        name = f.stem.replace("R__", "")
        
        # Check for HASH comparison in MERGE
        has_hash = "HASH(src." in content or "HASH(tgt." in content
        
        if not has_hash:
            issues.append(f"❌ {name}: Missing HASH comparison in MERGE")
            print(f"  ❌ {name}: Missing HASH comparison")
        else:
            passed.append(f"✅ {name}: Has HASH comparison")
            print(f"  ✅ {name}: Has HASH comparison")
    
    # ========================================
    # REVIEW 3: PROCEDURES - Consistent columns
    # ========================================
    print()
    print("=" * 80)
    print("REVIEW 3: PROCEDURES - DELETE and MERGE use same column")
    print("=" * 80)
    
    for f in sorted(procs_dir.glob("*.sql")):
        content = f.read_text(encoding="utf-8")
        name = f.stem.replace("R__", "").replace("_INCR_P", "")
        
        expected_col = EXPECTED_COLUMNS.get(name, "DW_MODIFY_TS")
        
        # Find DELETE column
        delete_match = re.search(r"DELETE\s+FROM[^;]+WHERE[^;]+(\w+_TS(?:_LOCAL)?)\s*<", content, re.IGNORECASE)
        delete_col = delete_match.group(1) if delete_match else "NOT_FOUND"
        
        # Find MERGE source column  
        merge_match = re.search(r"WHERE\s+(\w+_TS(?:_LOCAL)?|PLAN_DATE|BLAST_DT)\s*>=\s*DATEADD", content, re.IGNORECASE)
        merge_col = merge_match.group(1) if merge_match else "NOT_FOUND"
        
        if delete_col == merge_col:
            passed.append(f"✅ {name}_INCR_P: DELETE/MERGE use {delete_col}")
            print(f"  ✅ {name}_INCR_P: DELETE and MERGE both use {delete_col}")
        else:
            issues.append(f"❌ {name}_INCR_P: DELETE({delete_col}) != MERGE({merge_col})")
            print(f"  ❌ {name}_INCR_P: Mismatch DELETE({delete_col}) vs MERGE({merge_col})")
    
    # ========================================
    # REVIEW 4: Template variables
    # ========================================
    print()
    print("=" * 80)
    print("REVIEW 4: Template variables replaced correctly")
    print("=" * 80)
    
    for subdir in ["TABLES", "PROCEDURES"]:
        for f in sorted((deploy_dev / subdir).glob("*.sql")):
            content = f.read_text(encoding="utf-8")
            name = f.stem.replace("R__", "")
            
            has_envi = "{{ envi }}" in content
            has_ro_prod = "{{ RO_PROD }}" in content
            has_dev = "DEV_API_REF" in content
            has_prod = "PROD_WG" in content
            
            if has_envi or has_ro_prod:
                issues.append(f"❌ {name}: Still has template variables")
                print(f"  ❌ {name}: Template variables NOT replaced")
            elif has_dev and has_prod:
                passed.append(f"✅ {name}: DEV_API_REF + PROD_WG")
                print(f"  ✅ {name}: Correctly uses DEV_API_REF target, PROD_WG source")
    
    # ========================================
    # SUMMARY
    # ========================================
    print()
    print("=" * 80)
    print("REVIEW SUMMARY")
    print("=" * 80)
    print(f"  ✅ PASSED: {len(passed)}")
    print(f"  ❌ ISSUES: {len(issues)}")
    
    if issues:
        print()
        print("ISSUES TO FIX:")
        for issue in issues:
            print(f"  {issue}")
        return False
    else:
        print()
        print("🎉 ALL CHECKS PASSED - Ready for SQL Server deployment")
        return True


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
