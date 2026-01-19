"""Script to fetch DDL and metadata for LH_LOADING_CYCLE."""
from snowrefactor.snowflake_conn import connect

def main():
    with connect() as conn:
        cur = conn.cursor()
        
        print("=" * 80)
        print("LH_LOADING_CYCLE METADATA EXPLORATION")
        print("=" * 80)
        
        # 1. Check LH_LOADING_CYCLE in PROD_WG.LOAD_HAUL
        print("\n--- Checking PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE ---")
        try:
            cur.execute("DESCRIBE TABLE PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE")
            print("COLUMNS:")
            for row in cur.fetchall():
                print(f"  {row[0]:45} {row[1]:35}")
        except Exception as e:
            print(f"Not a table or no access: {e}")
        
        # 2. Check LH_LOADING_CYCLE_C in PROD_TARGET.COLLECTIONS
        print("\n--- Checking PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C ---")
        try:
            cur.execute("DESCRIBE TABLE PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C")
            print("COLUMNS:")
            for row in cur.fetchall():
                print(f"  {row[0]:45} {row[1]:35}")
        except Exception as e:
            print(f"Error: {e}")
            
        # 3. Get the DDL for the source
        print("\n--- LH_LOADING_CYCLE_C DDL ---")
        try:
            cur.execute("SELECT GET_DDL('TABLE', 'PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C')")
            result = cur.fetchone()
            if result:
                print(result[0][:4000])
        except Exception as e:
            print(f"Error: {e}")
            
        # 4. Check existing procedures
        print("\n--- EXISTING LH_LOADING_CYCLE PROCEDURES ---")
        try:
            cur.execute("SHOW PROCEDURES LIKE '%LH_LOADING_CYCLE%' IN ACCOUNT")
            for row in cur.fetchall():
                print(f"  {row[1]} in {row[10]}.{row[2]}")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()
