"""
LH_BUCKET_CT Stress Test - Days 1-90
=====================================
Run procedure with varying lookback days and log execution times
"""
import time
import json
from datetime import datetime
from snowrefactor.snowflake_conn import connect

TEST_DAYS = [1, 3, 5, 7, 10, 14, 21, 30, 45, 60, 75, 90]

def main():
    print("="*70)
    print("🧪 LH_BUCKET_CT STRESS TEST")
    print(f"   Days to test: {TEST_DAYS}")
    print(f"   Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)
    
    results = []
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        cur.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        
        print("\n" + "-"*70)
        print(f"{'Days':>6} | {'Duration':>10} | {'Rows':>12} | Result")
        print("-"*70)
        
        for days in TEST_DAYS:
            try:
                # Truncate table for clean measurement
                cur.execute("TRUNCATE TABLE DEV_API_REF.FUSE.LH_BUCKET_CT")
                
                # Run procedure
                start_time = time.time()
                cur.execute(f"CALL DEV_API_REF.FUSE.LH_BUCKET_CT_P('{days}')")
                result = cur.fetchone()[0]
                duration = time.time() - start_time
                
                # Get row count
                cur.execute("SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_BUCKET_CT")
                row_count = cur.fetchone()[0]
                
                entry = {
                    "days": days,
                    "duration_seconds": round(duration, 2),
                    "rows": row_count,
                    "result": result[:80] if result else "OK"
                }
                results.append(entry)
                
                # Extract metrics from result
                status = "✅"
                print(f"{days:>6} | {duration:>9.2f}s | {row_count:>12,} | {status} {result[:40]}")
                
            except Exception as e:
                print(f"{days:>6} | {'ERROR':>10} | {'-':>12} | ❌ {str(e)[:50]}")
                results.append({
                    "days": days,
                    "error": str(e)[:200]
                })
        
        print("-"*70)
    
    # Save results
    output_file = r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\LH_BUCKET\stress_test_results.json"
    with open(output_file, "w") as f:
        json.dump({
            "test_date": datetime.now().isoformat(),
            "table": "LH_BUCKET_CT",
            "results": results
        }, f, indent=2)
    
    print(f"\n✓ Results saved to: {output_file}")
    
    # Summary stats
    print("\n" + "="*70)
    print("📊 SUMMARY")
    print("="*70)
    successful = [r for r in results if "error" not in r]
    if successful:
        total_duration = sum(r["duration_seconds"] for r in successful)
        max_rows = max(r["rows"] for r in successful)
        print(f"   Tests run: {len(successful)}/{len(TEST_DAYS)}")
        print(f"   Total time: {total_duration:.1f}s")
        print(f"   Max rows (90 days): {max_rows:,}")
        
        # Performance trend
        print("\n   Performance trend:")
        for r in successful:
            bar_len = int(r["duration_seconds"] * 2)  # Scale bar
            bar = "█" * bar_len
            print(f"      {r['days']:>2}d: {bar} {r['duration_seconds']:.1f}s ({r['rows']:,} rows)")

if __name__ == "__main__":
    main()
