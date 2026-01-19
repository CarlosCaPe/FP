"""Get DRILLBLAST_DRILL_CYCLE_CT_P procedure DDL with correct signature."""
from snowrefactor.snowflake_conn import connect

def main():
    with connect() as conn:
        cur = conn.cursor()
        
        print("=" * 80)
        print("DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P DDL")
        print("=" * 80)
        
        # Correct signature: DEFAULT VARCHAR means the parameter has a default value
        try:
            cur.execute("SELECT GET_DDL('PROCEDURE', 'DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P(VARCHAR)')")
            result = cur.fetchone()
            if result:
                print(result[0])
        except Exception as e:
            print(f"Error: {e}")
        
        # Also get LH_EQUIPMENT_STATUS_EVENT_CT_P as another reference
        print("\n" + "=" * 80)
        print("DEV_API_REF.FUSE.LH_EQUIPMENT_STATUS_EVENT_CT_P DDL")
        print("=" * 80)
        try:
            cur.execute("SHOW PROCEDURES LIKE 'LH_EQUIPMENT_STATUS_EVENT_CT_P' IN DEV_API_REF.FUSE")
            for row in cur.fetchall():
                sig = row[8]
                print(f"Signature: {sig}")
                # Extract arg types
                import re
                match = re.search(r'\((.*?)\)', sig)
                if match:
                    args = match.group(1)
                    print(f"Args: {args}")
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()
