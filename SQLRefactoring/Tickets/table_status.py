"""Check table status - last 12 hours"""
from snowrefactor.snowflake_conn import connect
from datetime import datetime

conn = connect()
cur = conn.cursor()
cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")

print("="*60)
print(f"TABLE STATUS CHECK - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("="*60)

tables = [
    ("LH_BUCKET_CT", "DEV_API_REF.FUSE.LH_BUCKET_CT"),
    ("LH_LOADING_CYCLE_CT", "DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT"),
    ("DRILLBLAST_DRILL_CYCLE_CT", "DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT")
]

for name, fqn in tables:
    cur.execute(f"SELECT COUNT(*), MIN(DW_MODIFY_TS), MAX(DW_MODIFY_TS) FROM {fqn}")
    r = cur.fetchone()
    print(f"\n{name}:")
    print(f"  Rows: {r[0]:,}")
    print(f"  First modified: {r[1]}")
    print(f"  Last modified: {r[2]}")
