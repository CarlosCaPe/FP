"""
Full E2E Test - All 14 INCR Procedures in DEV
Real execution, no dry run

Author: Carlos Carrillo
Date: 2026-01-29
"""
import snowflake.connector
from datetime import datetime
import json

print("=" * 80)
print("FULL E2E TEST - ALL 14 INCR PROCEDURES")
print("=" * 80)
print(f"Time: {datetime.now().isoformat()}")
print(f"Environment: DEV_API_REF.FUSE")
print()

# Connect to Snowflake
conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

# All 14 INCR procedures
all_procedures = [
    # DRILL_BLAST tables (11)
    'BL_DW_BLAST_INCR_P',
    'BL_DW_BLASTPROPERTYVALUE_INCR_P',
    'BL_DW_HOLE_INCR_P',
    'BLAST_PLAN_INCR_P',
    'BLAST_PLAN_EXECUTION_INCR_P',
    'DRILL_CYCLE_INCR_P',
    'DRILL_PLAN_INCR_P',
    'DRILLBLAST_EQUIPMENT_INCR_P',
    'DRILLBLAST_OPERATOR_INCR_P',
    'DRILLBLAST_SHIFT_INCR_P',
    # LOAD_HAUL tables (4)
    'LH_BUCKET_INCR_P',
    'LH_EQUIPMENT_STATUS_EVENT_INCR_P',
    'LH_HAUL_CYCLE_INCR_P',
    'LH_LOADING_CYCLE_INCR_P',
]

results = []
passed = 0
failed = 0

print("📋 Testing all 14 INCR procedures...")
print("-" * 80)

for i, proc in enumerate(all_procedures, 1):
    try:
        start_time = datetime.now()
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3');")
        result = cursor.fetchone()[0]
        elapsed = (datetime.now() - start_time).total_seconds()
        
        # Parse result
        parts = result.split(', ')
        deleted = int(parts[0].split(': ')[1])
        merged = int(parts[1].split(': ')[1])
        archived = int(parts[2].split(': ')[1])
        
        print(f"  {i:2}. ✅ {proc:40} | Merged: {merged:>6} | Time: {elapsed:.1f}s")
        results.append({
            'procedure': proc,
            'status': 'PASS',
            'deleted': deleted,
            'merged': merged,
            'archived': archived,
            'time_seconds': elapsed
        })
        passed += 1
    except Exception as e:
        print(f"  {i:2}. ❌ {proc:40} | ERROR: {str(e)[:40]}")
        results.append({
            'procedure': proc,
            'status': 'FAIL',
            'error': str(e)[:200]
        })
        failed += 1

print("-" * 80)

# Verify table row counts
print("\n📋 Verifying table row counts...")
print("-" * 80)

tables = [p.replace('_P', '') for p in all_procedures]
for table in tables:
    try:
        cursor.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}")
        count = cursor.fetchone()[0]
        print(f"  {table:45} | Rows: {count:>10}")
    except Exception as e:
        print(f"  {table:45} | ERROR: {str(e)[:40]}")

cursor.close()
conn.close()

# Summary
print("\n" + "=" * 80)
print("E2E TEST SUMMARY")
print("=" * 80)
print(f"  Total Procedures: {len(all_procedures)}")
print(f"  ✅ Passed: {passed}")
print(f"  ❌ Failed: {failed}")
print(f"  Success Rate: {passed/len(all_procedures)*100:.1f}%")

if failed == 0:
    print("\n🎉 ALL TESTS PASSED - E2E CYCLE COMPLETE!")
else:
    print(f"\n⚠️ {failed} tests failed - please review errors above")

# Save results
with open('e2e_test_results.json', 'w') as f:
    json.dump({
        'timestamp': datetime.now().isoformat(),
        'environment': 'DEV_API_REF.FUSE',
        'passed': passed,
        'failed': failed,
        'results': results
    }, f, indent=2)
print(f"\nResults saved to: e2e_test_results.json")
