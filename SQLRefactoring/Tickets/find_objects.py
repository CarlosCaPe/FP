"""
Search for all LH_LOADING_CYCLE and LH_BUCKET objects
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

# Search in PROD_WG.LOAD_HAUL
print("=" * 80)
print("OBJECTS IN PROD_WG.LOAD_HAUL (like LH_LOADING_CYCLE%)")
print("=" * 80)
cur.execute("""
    SHOW OBJECTS IN SCHEMA PROD_WG.LOAD_HAUL
""")
objects = cur.fetchall()
for obj in objects:
    name = obj[1]
    kind = obj[3]
    if 'LH_LOADING_CYCLE' in name or 'LH_BUCKET' in name:
        print(f"  {kind:<10} | {name}")

# Search in PROD_TARGET.COLLECTIONS
print("\n" + "=" * 80)
print("OBJECTS IN PROD_TARGET.COLLECTIONS (like LH_LOADING_CYCLE% or LH_BUCKET%)")
print("=" * 80)
cur.execute("""
    SHOW OBJECTS IN SCHEMA PROD_TARGET.COLLECTIONS
""")
objects = cur.fetchall()
for obj in objects:
    name = obj[1]
    kind = obj[3]
    if 'LH_LOADING_CYCLE' in name or 'LH_BUCKET' in name:
        print(f"  {kind:<10} | {name}")

# Check what view LH_LOADING_CYCLE points to
print("\n" + "=" * 80)
print("VIEW DEFINITION: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
print("=" * 80)
try:
    cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE')")
    ddl = cur.fetchone()[0]
    # Find the FROM clause
    import re
    match = re.search(r'from\s+(\S+)', ddl, re.IGNORECASE)
    if match:
        print(f"  Points to: {match.group(1)}")
except Exception as e:
    print(f"  Error: {e}")

# Check LH_LOADING_CYCLE_V if exists
print("\n" + "=" * 80)
print("VIEW DEFINITION: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE_V (if exists)")
print("=" * 80)
try:
    cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE_V')")
    ddl = cur.fetchone()[0]
    match = re.search(r'from\s+(\S+)', ddl, re.IGNORECASE)
    if match:
        print(f"  Points to: {match.group(1)}")
except Exception as e:
    print(f"  Does not exist or no access: {e}")

# Check PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
print("\n" + "=" * 80)
print("VIEW DEFINITION: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V (if exists)")
print("=" * 80)
try:
    cur.execute("SELECT GET_DDL('VIEW', 'PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V')")
    ddl = cur.fetchone()[0]
    # Show first 500 chars
    print(ddl[:1000])
except Exception as e:
    print(f"  Error: {e}")

# Check LH_BUCKET views
print("\n" + "=" * 80)
print("VIEW DEFINITION: PROD_WG.LOAD_HAUL.LH_BUCKET")
print("=" * 80)
try:
    cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_BUCKET')")
    ddl = cur.fetchone()[0]
    print(ddl[:1000])
except Exception as e:
    print(f"  Error: {e}")

print("\n" + "=" * 80)
print("VIEW DEFINITION: PROD_WG.LOAD_HAUL.LH_BUCKET_V (if exists)")
print("=" * 80)
try:
    cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_BUCKET_V')")
    ddl = cur.fetchone()[0]
    print(ddl[:1000])
except Exception as e:
    print(f"  Does not exist: {e}")

cur.close()
conn.close()
print("\nDone!")
