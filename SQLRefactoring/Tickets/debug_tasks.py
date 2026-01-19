"""Debug task state"""
from snowrefactor.snowflake_conn import connect

conn = connect()
cur = conn.cursor()
cur.execute("SHOW TASKS IN SCHEMA DEV_API_REF.FUSE")
rows = cur.fetchall()
cols = [c[0] for c in cur.description]

print("Columns:")
for i, c in enumerate(cols):
    print(f"  [{i}] {c}")

print("\nTasks:")
for r in rows:
    if "LH_" in str(r[1]):
        print(f"\n  Name: {r[1]}")
        for i, c in enumerate(cols):
            print(f"    {c}: {r[i]}")
