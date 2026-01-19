"""Get DRILLBLAST_DRILL_CYCLE_CT_P procedure DDL as reference."""
from snowrefactor.snowflake_conn import connect

def main():
    with connect() as conn:
        cur = conn.cursor()
        
        print("=" * 80)
        print("DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P DDL (Reference)")
        print("=" * 80)
        
        try:
            cur.execute("SELECT GET_DDL('PROCEDURE', 'DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P(FLOAT)')")
            result = cur.fetchone()
            if result:
                print(result[0])
        except Exception as e:
            print(f"Error with FLOAT signature: {e}")
            # Try without signature
            try:
                cur.execute("SHOW PROCEDURES LIKE 'DRILLBLAST_DRILL_CYCLE_CT_P' IN DEV_API_REF.FUSE")
                for row in cur.fetchall():
                    sig = row[8]  # arguments column
                    print(f"Found signature: {sig}")
            except Exception as e2:
                print(f"Error: {e2}")
        
        # Also get the CT table DDL
        print("\n" + "=" * 80)
        print("DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT TABLE DDL")
        print("=" * 80)
        try:
            cur.execute("SELECT GET_DDL('TABLE', 'DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT')")
            result = cur.fetchone()
            if result:
                print(result[0])
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()
