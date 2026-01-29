"""Force deploy the fixed procedures"""
import snowflake.connector
from pathlib import Path

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

base = Path(__file__).parent / "DEPLOY_DEV" / "PROCEDURES"

procs = [
    "R__BLAST_PLAN_INCR_P.sql",
    "R__DRILL_CYCLE_INCR_P.sql", 
    "R__DRILL_PLAN_INCR_P.sql",
]

print("Force deploying procedures...")

for proc in procs:
    path = base / proc
    sql = path.read_text(encoding="utf-8")
    
    # Show first few lines to verify content
    lines = sql.split('\n')
    print(f"\n{proc}:")
    for i, line in enumerate(lines[20:28]):
        print(f"  {i+21}: {line[:70]}")
    
    try:
        cursor.execute(sql)
        print(f"  ✅ Deployed successfully")
    except Exception as e:
        print(f"  ❌ Error: {str(e)[:100]}")

# Verify
print("\n\nVerifying deployed versions...")
for proc_name in ['BLAST_PLAN_INCR_P', 'DRILL_CYCLE_INCR_P', 'DRILL_PLAN_INCR_P']:
    cursor.execute(f"SELECT GET_DDL('PROCEDURE', '{proc_name}(VARCHAR)');")
    ddl = cursor.fetchone()[0]
    
    if 'DW_MODIFY_TS' in ddl:
        print(f"  ✅ {proc_name}: Uses DW_MODIFY_TS (FIXED)")
    else:
        print(f"  ❌ {proc_name}: Still uses old columns (NOT FIXED)")

conn.close()
