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

# DESC the correct view names (without _V suffix)
print('=== PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE ===')
cur.execute("DESC VIEW PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
for row in cur.fetchall():
    print(f'{row[0]:40} {row[1]}')

print()
print('=== PROD_WG.LOAD_HAUL.LH_BUCKET ===')
cur.execute("DESC VIEW PROD_WG.LOAD_HAUL.LH_BUCKET")
for row in cur.fetchall():
    print(f'{row[0]:40} {row[1]}')

cur.close()
conn.close()
