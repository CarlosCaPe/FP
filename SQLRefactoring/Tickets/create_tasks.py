"""
Create TASKs for LH_BUCKET_CT and LH_LOADING_CYCLE_CT
=====================================================
Parameters from Hidayath:
- Schedule: Every 15 minutes (CRON */15 * * * * UTC)
- Incremental window: 3 days (default)
- Warehouse: WH_BATCH_DE_NONPROD
"""
from snowrefactor.snowflake_conn import connect

def main():
    print("="*60)
    print("CREATE TASKS FOR LH_BUCKET_CT & LH_LOADING_CYCLE_CT")
    print("="*60)
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        print("\n[1] Setting context...")
        cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        print("    ✓ Done")
        
        # Create LH_BUCKET_CT_T task
        print("\n[2] Creating LH_BUCKET_CT_T task...")
        task1_ddl = """
        CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_BUCKET_CT_T
            WAREHOUSE = 'WH_BATCH_DE_NONPROD'
            SCHEDULE = 'USING CRON */15 * * * * UTC'
            COMMENT = 'Task to run LH_BUCKET_CT_P every 15 minutes with 3-day lookback'
        AS
            CALL DEV_API_REF.FUSE.LH_BUCKET_CT_P('3')
        """
        cur.execute(task1_ddl)
        print("    ✓ Task LH_BUCKET_CT_T created (SUSPENDED)")
        
        # Create LH_LOADING_CYCLE_CT_T task
        print("\n[3] Creating LH_LOADING_CYCLE_CT_T task...")
        task2_ddl = """
        CREATE OR REPLACE TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_T
            WAREHOUSE = 'WH_BATCH_DE_NONPROD'
            SCHEDULE = 'USING CRON */15 * * * * UTC'
            COMMENT = 'Task to run LH_LOADING_CYCLE_CT_P every 15 minutes with 3-day lookback'
        AS
            CALL DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_P('3')
        """
        cur.execute(task2_ddl)
        print("    ✓ Task LH_LOADING_CYCLE_CT_T created (SUSPENDED)")
        
        # Show task status
        print("\n[4] Verifying tasks...")
        cur.execute("SHOW TASKS LIKE '%LH_%' IN SCHEMA DEV_API_REF.FUSE")
        rows = cur.fetchall()
        print(f"\n    Tasks found: {len(rows)}")
        for r in rows:
            name = r[1]
            state = r[4] if len(r) > 4 else "unknown"
            schedule = r[6] if len(r) > 6 else "unknown"
            print(f"    - {name}: state={state}, schedule={schedule}")
        
    print("\n" + "="*60)
    print("DONE!")
    print("="*60)
    print("\n⚠️  Tasks are SUSPENDED by default.")
    print("    To enable, run:")
    print("    ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_CT_T RESUME;")
    print("    ALTER TASK DEV_API_REF.FUSE.LH_LOADING_CYCLE_CT_T RESUME;")

if __name__ == "__main__":
    main()
