"""Check current procedure definition in Snowflake"""
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

# Get DDL for BLAST_PLAN_INCR_P
cursor.execute("SELECT GET_DDL('PROCEDURE', 'BLAST_PLAN_INCR_P(VARCHAR)');")
ddl = cursor.fetchone()[0]

# Check if it uses DW_MODIFY_TS or BLAST_DT
if 'BLAST_DT' in ddl:
    print("❌ BLAST_PLAN_INCR_P still uses BLAST_DT (old version)")
elif 'DW_MODIFY_TS' in ddl:
    print("✅ BLAST_PLAN_INCR_P uses DW_MODIFY_TS (new version)")

# Show relevant part
import re
match = re.search(r'sql_delete_incr.*?;', ddl, re.DOTALL)
if match:
    print("\nDELETE statement in procedure:")
    print(match.group(0)[:200])

conn.close()
