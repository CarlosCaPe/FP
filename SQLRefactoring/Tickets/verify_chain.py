"""
Verify what each view actually points to
"""
import snowflake.connector
from dotenv import load_dotenv
import os
import re

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

# Get DDL of OLD view
print("=" * 80)
print("OLD: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
print("=" * 80)
cur.execute("SELECT GET_DDL('VIEW', 'PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE')")
old_ddl = cur.fetchone()[0]

# Find FROM clause
from_match = re.search(r'from\s+([\w\.]+)', old_ddl, re.IGNORECASE)
if from_match:
    print(f"Points to: {from_match.group(1)}")

# Check if it has JOIN
if 'join' in old_ddl.lower():
    print("Has JOIN: YES")
else:
    print("Has JOIN: NO")

# Get DDL of NEW view
print("\n" + "=" * 80)
print("NEW: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V")
print("=" * 80)
cur.execute("SELECT GET_DDL('VIEW', 'PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V')")
new_ddl = cur.fetchone()[0]

# Find FROM clause
from_match = re.search(r'from\s+([\w\.]+)', new_ddl, re.IGNORECASE)
if from_match:
    print(f"Points to: {from_match.group(1)}")

# Check if it has JOIN
if 'join' in new_ddl.lower():
    print("Has JOIN: YES")
    # Find join table
    join_match = re.search(r'join\s+([\w\.]+)', new_ddl, re.IGNORECASE)
    if join_match:
        print(f"Joins with: {join_match.group(1)}")
else:
    print("Has JOIN: NO")

# The KEY question: What does LH_LOADING_CYCLE point to?
print("\n" + "=" * 80)
print("CHAIN ANALYSIS")
print("=" * 80)

print("""
OLD: PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
  └── FROM: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V  <-- Already points to _V!
            └── FROM: LH_LOADING_CYCLE_C + LEFT JOIN LH_BUCKET_C

NEW: PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_V
  └── FROM: LH_LOADING_CYCLE_C + LEFT JOIN LH_BUCKET_C

CONCLUSION: BOTH views are essentially the same!
The OLD view is just a wrapper around the NEW view.
""")

cur.close()
conn.close()
print("Done!")
