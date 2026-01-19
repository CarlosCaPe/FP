"""Script to get existing LH_BUCKET procedure DDL and understand the pattern."""
from snowrefactor.snowflake_conn import connect

def main():
    with connect() as conn:
        cur = conn.cursor()
        
        # Get existing DISPATCH procedure DDL
        print("=" * 80)
        print("PROD_TARGET.DISPATCH.DISPATCH_LH_BUCKET_C_P DDL")
        print("=" * 80)
        try:
            cur.execute("""
                SELECT GET_DDL('PROCEDURE', 
                    'PROD_TARGET.DISPATCH.DISPATCH_LH_BUCKET_C_P(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR)')
            """)
            result = cur.fetchone()
            if result:
                print(result[0])
        except Exception as e:
            print(f"Error: {e}")
        
        print("\n" + "=" * 80)
        print("FLEET_LH_BUCKET_C_P DDL")
        print("=" * 80)
        try:
            cur.execute("""
                SELECT GET_DDL('PROCEDURE', 
                    'PROD_TARGET.MSFLEET.FLEET_LH_BUCKET_C_P(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR)')
            """)
            result = cur.fetchone()
            if result:
                print(result[0])
        except Exception as e:
            print(f"Error: {e}")
            
        # Check what's in DEV_API_REF.FUSE schema
        print("\n" + "=" * 80)
        print("DEV_API_REF.FUSE EXISTING OBJECTS")
        print("=" * 80)
        try:
            cur.execute("SHOW TABLES IN DEV_API_REF.FUSE")
            tables = cur.fetchall()
            print(f"Tables: {len(tables)}")
            for t in tables[:20]:
                print(f"  {t[1]}")
        except Exception as e:
            print(f"Error: {e}")
            
        try:
            cur.execute("SHOW PROCEDURES IN DEV_API_REF.FUSE")
            procs = cur.fetchall()
            print(f"\nProcedures: {len(procs)}")
            for p in procs[:20]:
                print(f"  {p[1]}")
        except Exception as e:
            print(f"Error listing procs: {e}")

if __name__ == "__main__":
    main()
