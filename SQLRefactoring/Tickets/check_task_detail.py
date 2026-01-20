"""
Check detailed task status
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

print("Task details:")
print("=" * 80)
cur.execute("SHOW TASKS LIKE '%INCR%' IN SCHEMA DEV_API_REF.FUSE")
rows = cur.fetchall()

# Get column names
desc = cur.description
col_names = [col[0] for col in desc]

for row in rows:
    row_dict = dict(zip(col_names, row))
    print(f"Name: {row_dict.get('name')}")
    print(f"State: {row_dict.get('state')}")
    print(f"Schedule: {row_dict.get('schedule')}")
    print(f"Definition: {row_dict.get('definition', '')[:100]}...")
    print("---")

# Try to see the actual state field
print("\nRaw data for first task:")
if rows:
    for i, col in enumerate(col_names):
        print(f"  {i}: {col} = {rows[0][i]}")

cur.close()
conn.close()
