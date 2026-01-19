"""Script to fetch DDL and metadata for LH_BUCKET and LH_LOADING_CYCLE tables."""
from snowrefactor.snowflake_conn import connect

def main():
    with connect() as conn:
        cur = conn.cursor()
        
        # Set role for access
        try:
            cur.execute("USE ROLE FREEPORT_DE_DEV")
        except:
            pass  # Role may not be needed
        
        print("=" * 80)
        print("LH_BUCKET METADATA EXPLORATION")
        print("=" * 80)
        
        # 1. Check if LH_BUCKET is a table or view in PROD_WG.LOAD_HAUL
        print("\n--- Checking PROD_WG.LOAD_HAUL.LH_BUCKET ---")
        try:
            cur.execute("DESCRIBE TABLE PROD_WG.LOAD_HAUL.LH_BUCKET")
            print("COLUMNS:")
            for row in cur.fetchall():
                print(f"  {row[0]:40} {row[1]:30}")
        except Exception as e:
            print(f"Not a table or no access: {e}")
        
        # 2. Check LH_BUCKET_C in PROD_TARGET.COLLECTIONS (the _C suffix means collection)
        print("\n--- Checking PROD_TARGET.COLLECTIONS.LH_BUCKET_C ---")
        try:
            cur.execute("DESCRIBE VIEW PROD_TARGET.COLLECTIONS.LH_BUCKET_C")
            print("COLUMNS:")
            for row in cur.fetchall():
                print(f"  {row[0]:40} {row[1]:30}")
        except Exception as e:
            print(f"Error: {e}")
            
        # 3. Get the DDL for the source view
        print("\n--- LH_BUCKET_C VIEW DDL ---")
        try:
            cur.execute("SELECT GET_DDL('VIEW', 'PROD_TARGET.COLLECTIONS.LH_BUCKET_C')")
            result = cur.fetchone()
            if result:
                print(result[0][:3000])  # First 3000 chars
        except Exception as e:
            print(f"Error: {e}")
            
        # 4. Sample data to understand business keys
        print("\n--- SAMPLE DATA (first 3 rows) ---")
        try:
            cur.execute("SELECT * FROM PROD_TARGET.COLLECTIONS.LH_BUCKET_C LIMIT 3")
            cols = [desc[0] for desc in cur.description]
            print(f"Columns: {cols}")
            for row in cur.fetchall():
                print(row[:10], "...")  # First 10 values
        except Exception as e:
            print(f"Error: {e}")
            
        # 5. Check for existing CT procedures as reference
        print("\n--- EXISTING LH_BUCKET PROCEDURES ---")
        try:
            cur.execute("SHOW PROCEDURES LIKE '%LH_BUCKET%' IN ACCOUNT")
            for row in cur.fetchall():
                print(f"  {row}")
        except Exception as e:
            print(f"Error: {e}")
            
        # 6. Check DRILLBLAST reference procedure for pattern
        print("\n--- REFERENCE: DRILLBLAST_DRILL_CYCLE_CT_P ---")
        try:
            cur.execute("SELECT GET_DDL('PROCEDURE', 'SANDBOX_DATA_ENGINEER.HM2.DRILLBLAST_DRILL_CYCLE_CT_P(FLOAT)')")
            result = cur.fetchone()
            if result:
                print(result[0][:5000])  # First 5000 chars
        except Exception as e:
            print(f"Error getting procedure DDL: {e}")

if __name__ == "__main__":
    main()
