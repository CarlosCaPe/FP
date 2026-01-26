"""
Try each available role to see which one can CREATE in TEST_API_REF.FUSE
"""
import snowflake.connector

ROLES_TO_TRY = [
    "SG-AZW-SFLK-ENG-GENERAL",
    "_AR_ENG_GENERAL",
    "_AR_GENERAL_DBO_DEV",      # This looks promising!
    "_AR_GENERAL_RO_DEV",
    "_AR_GENERAL_RO_PROD", 
    "_AR_GENERAL_RO_TEST",
    "_AR_SANDBOX_ENG_GENERAL",
    "_TASK_HISTORY_VIEW",
    "PIPELINE_AUTHOR",
    "PUBLIC",
]

print("Connecting to Snowflake...")
conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
)
cursor = conn.cursor()

print("\nTrying each role to CREATE TABLE in TEST_API_REF.FUSE...\n")

working_role = None

for role in ROLES_TO_TRY:
    try:
        # Try to use the role
        cursor.execute(f'USE ROLE "{role}"')
        cursor.execute("SELECT CURRENT_ROLE()")
        current = cursor.fetchone()[0]
        
        # Try to create a test table
        cursor.execute("DROP TABLE IF EXISTS TEST_API_REF.FUSE._PERMISSION_TEST_CARLOS")
        cursor.execute("CREATE TABLE TEST_API_REF.FUSE._PERMISSION_TEST_CARLOS (ID INT)")
        cursor.execute("DROP TABLE TEST_API_REF.FUSE._PERMISSION_TEST_CARLOS")
        
        print(f"✅ {role} - CAN CREATE TABLES IN TEST_API_REF.FUSE!")
        working_role = role
        
    except Exception as e:
        err = str(e)[:80]
        if "Insufficient privileges" in err:
            print(f"❌ {role} - No CREATE privilege")
        elif "does not exist" in err.lower() or "not authorized" in err.lower():
            print(f"⚠️  {role} - Role not accessible")
        else:
            print(f"❌ {role} - {err}")

cursor.close()
conn.close()

if working_role:
    print(f"\n🎉 SUCCESS! Use role: {working_role}")
else:
    print("\n😞 No role with CREATE privileges found")
