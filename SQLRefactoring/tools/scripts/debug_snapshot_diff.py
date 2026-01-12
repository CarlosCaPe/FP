from __future__ import annotations

from snowrefactor.snowflake_conn import connect

BASELINE_SQL = """
SELECT *
FROM TABLE(PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET(
  'MOR',
  FALSE,
  ARRAY_CONSTRUCT(''),
  ARRAY_CONSTRUCT(
    'CR03_CRUSH_OUT_TIME',
    'PE_MOR_CC_MflPileTonnage',
    'PE_MOR_CC_MillPileTonnage'
  )
))
ORDER BY 1,2,3,4,5
""".strip()

REFACTOR_SQL = """
SELECT *
FROM TABLE(SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET(
  'MOR',
  FALSE,
  ARRAY_CONSTRUCT(''),
  ARRAY_CONSTRUCT(
    'CR03_CRUSH_OUT_TIME',
    'PE_MOR_CC_MflPileTonnage',
    'PE_MOR_CC_MillPileTonnage'
  )
))
ORDER BY 1,2,3,4,5
""".strip()


def main() -> None:
    with connect() as conn:
        cur = conn.cursor()
        try:
            cur.execute(BASELINE_SQL)
            baseline = cur.fetchall()
            cur.execute(REFACTOR_SQL)
            refactor = cur.fetchall()
        finally:
            cur.close()

    print(f"baseline rows: {len(baseline)}")
    print(f"refactor rows: {len(refactor)}")
    print("\nBaseline:")
    for r in baseline:
        print(r)
    print("\nRefactor:")
    for r in refactor:
        print(r)

    bset = set(baseline)
    rset = set(refactor)
    only_b = sorted(bset - rset)
    only_r = sorted(rset - bset)

    print("\nDiff (set-based):")
    print(f"only in baseline: {len(only_b)}")
    for r in only_b:
        print(r)
    print(f"only in refactor: {len(only_r)}")
    for r in only_r:
        print(r)


if __name__ == "__main__":
    main()
