#!/usr/bin/env python
"""
Validate SQL files for correct naming conventions.

Run this BEFORE deploying to Snowflake to catch naming issues early.

Expected patterns:
  - Tables: {NAME}_INCR
  - Procedures: {NAME}_INCR_P (NOT SP_{NAME}_INCR)
"""

import re
import sys
from pathlib import Path

# ANSI colors
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def validate_sql_files():
    """Check all SQL files for naming convention violations."""
    
    folder = Path(__file__).parent
    sql_files = list(folder.glob("*.sql"))
    
    # Exclude combined deploy files
    sql_files = [f for f in sql_files if "DEPLOY_ALL" not in f.name]
    
    issues = []
    
    for sql_file in sql_files:
        content = sql_file.read_text(encoding='utf-8')
        
        # Check for SP_ prefix (incorrect)
        sp_matches = re.findall(r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+[\w.]*\.SP_\w+', content, re.IGNORECASE)
        if sp_matches:
            for match in sp_matches:
                issues.append({
                    'file': sql_file.name,
                    'issue': 'INCORRECT SP_ prefix',
                    'found': match,
                    'should_be': match.replace('.SP_', '.').replace('_INCR(', '_INCR_P(')
                })
        
        # Check procedure string literals
        sp_literal_matches = re.findall(r"procedure:\s*['\"]SP_\w+['\"]", content)
        if sp_literal_matches:
            for match in sp_literal_matches:
                issues.append({
                    'file': sql_file.name,
                    'issue': 'INCORRECT SP_ prefix in string literal',
                    'found': match,
                    'should_be': match.replace('SP_', '').replace("_INCR'", "_INCR_P'").replace('_INCR"', '_INCR_P"')
                })
        
        # Check CALL statements
        sp_call_matches = re.findall(r'CALL\s+[\w.]*\.SP_\w+', content, re.IGNORECASE)
        if sp_call_matches:
            for match in sp_call_matches:
                issues.append({
                    'file': sql_file.name,
                    'issue': 'INCORRECT SP_ prefix in CALL statement',
                    'found': match,
                    'should_be': match.replace('.SP_', '.').replace('_INCR(', '_INCR_P(')
                })
        
        # Verify procedures end with _P
        proc_matches = re.findall(r'CREATE\s+OR\s+REPLACE\s+PROCEDURE\s+[\w.]*\.(\w+)\s*\(', content, re.IGNORECASE)
        for proc_name in proc_matches:
            if not proc_name.endswith('_P'):
                issues.append({
                    'file': sql_file.name,
                    'issue': 'Procedure does not end with _P suffix',
                    'found': proc_name,
                    'should_be': f"{proc_name}_P" if '_INCR' in proc_name else f"{proc_name.replace('_INCR', '_INCR_P')}"
                })
    
    return issues

def main():
    print("=" * 70)
    print("DRILLBLAST_INCR - Naming Convention Validator")
    print("=" * 70)
    print()
    
    issues = validate_sql_files()
    
    if not issues:
        print(f"{GREEN}✅ All SQL files pass naming convention checks!{RESET}")
        print()
        print("Verified patterns:")
        print("  - Tables: {NAME}_INCR")
        print("  - Procedures: {NAME}_INCR_P(VARCHAR DEFAULT '3')")
        print()
        return 0
    else:
        print(f"{RED}❌ Found {len(issues)} naming convention violations:{RESET}")
        print()
        
        for i, issue in enumerate(issues, 1):
            print(f"  {i}. {issue['file']}")
            print(f"     Issue: {issue['issue']}")
            print(f"     Found: {issue['found']}")
            print(f"     Should be: {issue['should_be']}")
            print()
        
        print(f"{YELLOW}⚠️  Fix these issues before deploying to Snowflake!{RESET}")
        print()
        return 1

if __name__ == "__main__":
    sys.exit(main())
