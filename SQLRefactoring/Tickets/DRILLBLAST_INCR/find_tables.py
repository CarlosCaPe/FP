#!/usr/bin/env python3
"""Find correct paths for missing DRILLBLAST tables."""

import snowflake.connector

def main():
    conn = snowflake.connector.connect(
        account='fcx.west-us-2.azure',
        user='CCARRILL2@fmi.com',
        authenticator='externalbrowser',
        warehouse='WH_BATCH_DE_NONPROD'
    )
    cur = conn.cursor()

    # Search in known databases
    databases = ['PROD_WG', 'DEV_WG', 'PROD_API_REF', 'DEV_API_REF']
    
    for db in databases:
        print(f'\n=== Searching in {db} ===')
        try:
            cur.execute(f"USE DATABASE {db}")
            
            # Search for HAUL_CYCLE
            cur.execute(f"""
                SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
                FROM {db}.INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME ILIKE '%HAUL_CYCLE%'
            """)
            rows = cur.fetchall()
            if rows:
                print(f"  HAUL_CYCLE tables:")
                for row in rows:
                    print(f"    {db}.{row[0]}.{row[1]} ({row[2]})")
            
            # Search for BL_DW_BLAST
            cur.execute(f"""
                SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
                FROM {db}.INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME ILIKE 'BL_DW_BLAST%'
            """)
            rows = cur.fetchall()
            if rows:
                print(f"  BL_DW_BLAST tables:")
                for row in rows:
                    print(f"    {db}.{row[0]}.{row[1]} ({row[2]})")
            
            # Search for BL_DW_HOLE
            cur.execute(f"""
                SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
                FROM {db}.INFORMATION_SCHEMA.TABLES
                WHERE TABLE_NAME ILIKE 'BL_DW_HOLE%'
            """)
            rows = cur.fetchall()
            if rows:
                print(f"  BL_DW_HOLE tables:")
                for row in rows:
                    print(f"    {db}.{row[0]}.{row[1]} ({row[2]})")
                    
            # Also check for schemas with DRILL or BLAST
            cur.execute(f"""
                SELECT SCHEMA_NAME 
                FROM {db}.INFORMATION_SCHEMA.SCHEMATA
                WHERE SCHEMA_NAME ILIKE '%DRILL%' OR SCHEMA_NAME ILIKE '%BLAST%'
            """)
            rows = cur.fetchall()
            if rows:
                print(f"  Schemas with DRILL/BLAST:")
                for row in rows:
                    print(f"    {db}.{row[0]}")
                    
        except Exception as e:
            print(f"  Error: {e}")

    conn.close()
    print('\nDone!')

if __name__ == '__main__':
    main()
