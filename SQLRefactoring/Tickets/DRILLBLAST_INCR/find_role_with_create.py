"""
Try different roles to find one with CREATE privileges on TEST_API_REF.FUSE
"""
import snowflake.connector

# Connect with default role first
conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
)
cursor = conn.cursor()

print("Finding roles with CREATE privileges on TEST_API_REF.FUSE...\n")

# First check what grants exist on TEST_API_REF.FUSE schema
print("Grants on TEST_API_REF.FUSE schema:")
try:
    cursor.execute("SHOW GRANTS ON SCHEMA TEST_API_REF.FUSE")
    grants = cursor.fetchall()
    for g in grants:
        priv = g[1]
        granted_to = g[3]
        if 'CREATE' in priv or 'OWNERSHIP' in priv or 'ALL' in priv:
            print(f"  {priv} -> {granted_to}")
except Exception as e:
    print(f"  Error: {e}")

# Try common roles
roles_to_try = [
    "SG-AZW-SFLK-ENG-GENERAL",
    "SG-AZW-SFLK-ENG-DEVELOPER",
    "SG-AZW-SFLK-DE-ADMIN",
    "SG-AZW-SFLK-DATA-ENGINEER",
    "SYSADMIN",
    "ACCOUNTADMIN",
]

print("\n\nTrying different roles:")
for role in roles_to_try:
    try:
        cursor.execute(f"USE ROLE \"{role}\"")
        cursor.execute("SELECT CURRENT_ROLE()")
        current = cursor.fetchone()[0]
        
        # Try to create a temp table
        cursor.execute("DROP TABLE IF EXISTS TEST_API_REF.FUSE._TEST_PERMISSION_CHECK")
        cursor.execute("CREATE TABLE TEST_API_REF.FUSE._TEST_PERMISSION_CHECK (ID INT)")
        cursor.execute("DROP TABLE TEST_API_REF.FUSE._TEST_PERMISSION_CHECK")
        print(f"  ✅ {role} - CAN CREATE TABLES!")
        
    except Exception as e:
        err_msg = str(e)[:60]
        if "does not exist" in err_msg.lower() or "not authorized" in err_msg.lower():
            print(f"  ❌ {role} - Role not available")
        elif "Insufficient privileges" in err_msg:
            print(f"  ❌ {role} - No CREATE privilege")
        else:
            print(f"  ❌ {role} - {err_msg}")

cursor.close()
conn.close()
