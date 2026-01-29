"""Get detailed error for failing procedures"""
import snowflake.connector

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

procs = ['BLAST_PLAN_INCR_P', 'DRILL_CYCLE_INCR_P', 'DRILL_PLAN_INCR_P']

for proc in procs:
    print(f"\n{'='*60}")
    print(f"Testing {proc}")
    print('='*60)
    try:
        cursor.execute(f"CALL DEV_API_REF.FUSE.{proc}('3');")
        result = cursor.fetchone()[0]
        print(f"SUCCESS: {result}")
    except Exception as e:
        print(f"ERROR: {str(e)}")

conn.close()
