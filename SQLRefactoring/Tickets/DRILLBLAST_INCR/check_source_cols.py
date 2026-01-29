"""Check source table columns"""
import snowflake.connector

conn = snowflake.connector.connect(
    account='fcx.west-us-2.azure',
    user='CCARRILL2@fmi.com',
    authenticator='externalbrowser',
    warehouse='WH_BATCH_DE_NONPROD',
    database='PROD_WG',
    schema='DRILL_BLAST',
    role='SG-AZW-SFLK-ENG-GENERAL'
)
cursor = conn.cursor()

# Check if BLAST_DT exists in BLAST_PLAN
cursor.execute("""
    SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'DRILL_BLAST' 
    AND TABLE_NAME = 'BLAST_PLAN'
    AND COLUMN_NAME IN ('BLAST_DT', 'PLAN_DATE', 'CYCLE_START_TS_LOCAL', 'DW_MODIFY_TS')
""")
cols = [r[0] for r in cursor.fetchall()]
print("BLAST_PLAN columns:", cols)

# Check DRILL_CYCLE
cursor.execute("""
    SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'DRILL_BLAST' 
    AND TABLE_NAME = 'DRILL_CYCLE'
    AND COLUMN_NAME IN ('BLAST_DT', 'PLAN_DATE', 'CYCLE_START_TS_LOCAL', 'DW_MODIFY_TS')
""")
cols = [r[0] for r in cursor.fetchall()]
print("DRILL_CYCLE columns:", cols)

# Check DRILL_PLAN
cursor.execute("""
    SELECT COLUMN_NAME 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'DRILL_BLAST' 
    AND TABLE_NAME = 'DRILL_PLAN'
    AND COLUMN_NAME IN ('BLAST_DT', 'PLAN_DATE', 'CYCLE_START_TS_LOCAL', 'DW_MODIFY_TS')
""")
cols = [r[0] for r in cursor.fetchall()]
print("DRILL_PLAN columns:", cols)

conn.close()
