"""Debug LH_EQUIPMENT_STATUS_EVENT_INCR_P error"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='DEV_API_REF',
    schema='FUSE',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

try:
    print("Calling LH_EQUIPMENT_STATUS_EVENT_INCR_P...")
    cursor.execute("CALL DEV_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_INCR_P('3')")
    print('Result:', cursor.fetchone()[0])
except Exception as e:
    print('ERROR:', str(e))

cursor.close()
conn.close()
