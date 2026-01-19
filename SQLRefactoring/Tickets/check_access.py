"""Quick check of DEV_API_REF.FUSE access"""
from snowrefactor.snowflake_conn import connect

with connect() as conn:
    cur = conn.cursor()
    cur.execute("USE DATABASE DEV_API_REF")
    cur.execute("USE SCHEMA FUSE")
    print("✓ Can access DEV_API_REF.FUSE")
    
    # Show existing DRILL tables
    cur.execute("SHOW TABLES LIKE '%DRILL%' IN SCHEMA DEV_API_REF.FUSE")
    rows = cur.fetchall()
    print(f"\nExisting DRILL tables: {len(rows)}")
    for r in rows:
        print(f"  - {r[1]}")
    
    # Show existing procedures
    cur.execute("SHOW PROCEDURES LIKE '%DRILL%' IN SCHEMA DEV_API_REF.FUSE")
    rows = cur.fetchall()
    print(f"\nExisting DRILL procedures: {len(rows)}")
    for r in rows:
        print(f"  - {r[1]}")
    
    # Show existing LH tables
    cur.execute("SHOW TABLES LIKE '%LH_%' IN SCHEMA DEV_API_REF.FUSE")
    rows = cur.fetchall()
    print(f"\nExisting LH_ tables: {len(rows)}")
    for r in rows:
        print(f"  - {r[1]}")
