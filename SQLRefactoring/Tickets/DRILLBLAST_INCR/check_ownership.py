"""
Check database ownership and available roles
"""
import snowflake.connector
conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
)
cursor = conn.cursor()

# Check database ownership
print('Database ownership:')
cursor.execute('SHOW GRANTS ON DATABASE TEST_API_REF')
for g in cursor.fetchall():
    if 'OWNERSHIP' in g[1] or 'CREATE' in g[1]:
        print(f'  {g[1]}: grantee={g[3]}')

print()

# Check schema grants more detailed
print('Schema grants (detailed):')
cursor.execute('SHOW GRANTS ON SCHEMA TEST_API_REF.FUSE')
for g in cursor.fetchall():
    print(f'  {g}')
    if len([x for x in cursor.fetchall()]) > 5:
        break

# List grants to the role that owns the schema
print('\nLooking for SG-AZW-SFLK-API-REF-DEV or similar roles:')
cursor.execute("SHOW ROLES LIKE '%API%'")
for r in cursor.fetchall():
    print(f'  {r[1]}')

cursor.close()
conn.close()
