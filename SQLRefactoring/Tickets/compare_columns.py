"""
Compare columns: VIEW vs TABLE _C
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

# Get columns from _C table
print("=" * 80)
print("COLUMNS IN LH_LOADING_CYCLE_C (TABLE)")
print("=" * 80)
cur.execute("DESCRIBE TABLE PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C")
table_cols = [row[0] for row in cur.fetchall()]
for col in table_cols:
    print(f"  {col}")

# Get columns from VIEW
print("\n" + "=" * 80)
print("COLUMNS IN LH_LOADING_CYCLE (VIEW)")
print("=" * 80)
cur.execute("DESCRIBE VIEW PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
view_cols = [row[0] for row in cur.fetchall()]
for col in view_cols:
    print(f"  {col}")

# Find differences
print("\n" + "=" * 80)
print("COLUMNS IN VIEW BUT NOT IN TABLE (calculated by JOIN):")
print("=" * 80)
for col in view_cols:
    if col not in table_cols:
        print(f"  ⚠️  {col}")

print("\n" + "=" * 80)
print("COLUMNS IN TABLE BUT NOT IN VIEW:")
print("=" * 80)
for col in table_cols:
    if col not in view_cols:
        print(f"  {col}")

cur.close()
conn.close()
print("\nDone!")
