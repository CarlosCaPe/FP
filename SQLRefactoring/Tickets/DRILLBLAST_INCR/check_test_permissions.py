"""
Check permissions for TEST_API_REF database
"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

print("Checking grants on TEST_API_REF...")
cursor.execute("SHOW GRANTS ON DATABASE TEST_API_REF")
grants = cursor.fetchall()
for g in grants:
    print(f"  {g[1]} - {g[2]} - {g[3]}")

print("\nChecking my roles...")
cursor.execute("SELECT CURRENT_ROLE()")
print(f"Current role: {cursor.fetchone()[0]}")

print("\nTrying to use TEST_API_REF.FUSE...")
try:
    cursor.execute("USE DATABASE TEST_API_REF")
    cursor.execute("USE SCHEMA FUSE")
    print("  ✅ Can USE database/schema")
    
    cursor.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'FUSE'")
    print(f"  Tables in FUSE: {cursor.fetchone()[0]}")
except Exception as e:
    print(f"  ❌ Error: {e}")

print("\nChecking if I have a role with CREATE privileges...")
cursor.execute("SHOW GRANTS TO USER CCARRILL2")
grants = cursor.fetchall()
roles = set()
for g in grants:
    if g[1] == 'ROLE':
        roles.add(g[2])
print(f"My roles: {roles}")

cursor.close()
conn.close()
