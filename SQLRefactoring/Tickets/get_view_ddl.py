"""
Get full view definitions to understand the overhead
"""
import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv('../tools/.env')

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()

# Get full DDL
for view in ['PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE', 'PROD_WG.LOAD_HAUL.LH_BUCKET']:
    print("=" * 80)
    print(f"VIEW: {view}")
    print("=" * 80)
    cur.execute(f"SELECT GET_DDL('VIEW', '{view}')")
    ddl = cur.fetchone()[0]
    print(ddl)
    print("\n\n")

# Also check EXPLAIN PLAN
print("=" * 80)
print("EXPLAIN PLAN: LH_LOADING_CYCLE VIEW vs TABLE")
print("=" * 80)

cur.execute("""
EXPLAIN 
SELECT * FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE 
WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
""")
print("\n--- VIEW EXPLAIN ---")
for row in cur.fetchall():
    print(row)

cur.execute("""
EXPLAIN 
SELECT * FROM PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C 
WHERE cycle_start_ts_local::date >= DATEADD(day, -3, CURRENT_DATE)
AND dw_logical_delete_flag = 'N'
""")
print("\n--- TABLE EXPLAIN ---")
for row in cur.fetchall():
    print(row)

cur.close()
conn.close()
