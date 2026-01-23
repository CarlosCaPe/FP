"""
Schema Discovery - Get all columns for Load/Haul tables
"""
import os
from dotenv import load_dotenv
load_dotenv()

import snowflake.connector

conn = snowflake.connector.connect(
    account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
    user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
    authenticator='externalbrowser',
    role=os.getenv('CONN_LIB_SNOWFLAKE_ROLE'),
    warehouse=os.getenv('CONN_LIB_SNOWFLAKE_WAREHOUSE'),
    database=os.getenv('CONN_LIB_SNOWFLAKE_DATABASE'),
)

cursor = conn.cursor()

print("=" * 80)
print("LH_LOADING_CYCLE - ALL COLUMNS")
print("=" * 80)
cursor.execute("""
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' AND table_name = 'LH_LOADING_CYCLE'
ORDER BY ordinal_position
""")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

print("\n" + "=" * 80)
print("LH_HAUL_CYCLE - FIRST 50 COLUMNS")
print("=" * 80)
cursor.execute("""
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' AND table_name = 'LH_HAUL_CYCLE'
ORDER BY ordinal_position
LIMIT 50
""")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

print("\n" + "=" * 80)
print("SEARCHING FOR TRUCK/SHOVEL/EQUIPMENT COLUMNS")
print("=" * 80)
cursor.execute("""
SELECT table_name, column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND (column_name ILIKE '%truck%' OR column_name ILIKE '%shovel%' OR column_name ILIKE '%equip%' OR column_name ILIKE '%loader%')
ORDER BY table_name, column_name
""")
for row in cursor.fetchall():
    print(f"  {row[0]}.{row[1]}: {row[2]}")

conn.close()
