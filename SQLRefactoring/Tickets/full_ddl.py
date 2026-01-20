"""
Full chain analysis for LH_LOADING_CYCLE and LH_BUCKET
"""
import snowflake.connector
from dotenv import load_dotenv
import os

load_dotenv('../tools/.env')

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)

cur = conn.cursor()
print("Connected!\n")

print("=" * 100)
print("FULL DDL: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
print("=" * 100)
cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE')")
ddl = cur.fetchone()[0]
print(ddl)

print("\n" + "=" * 100)
print("FULL DDL: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V")
print("=" * 100)
cur.execute("SELECT GET_DDL('VIEW', 'PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V')")
ddl = cur.fetchone()[0]
print(ddl)

print("\n" + "=" * 100)
print("FULL DDL: PROD_WG.LOAD_HAUL.LH_BUCKET")
print("=" * 100)
cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_BUCKET')")
ddl = cur.fetchone()[0]
print(ddl)

cur.close()
conn.close()
print("\n\nDone!")
