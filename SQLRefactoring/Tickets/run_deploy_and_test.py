"""
Deploy LH_BUCKET_CT and run stress tests
=========================================
Steps:
1. Execute refactor_ddl.sql for LH_BUCKET
2. Run stress tests with days 1-90
3. Log execution times
"""
import time
import json
from datetime import datetime
from snowrefactor.snowflake_conn import connect

TEST_DAYS = [1, 3, 5, 7, 10, 14, 21, 30, 45, 60, 75, 90]

def execute_ddl_from_file(cur, file_path: str, skip_task: bool = True):
    """Execute DDL statements from a SQL file."""
    print(f"\n📄 Reading: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split by statement boundaries
    # We'll execute: CREATE TABLE, CREATE PROCEDURE (skip task)
    statements = []
    
    # Find CREATE TABLE statement
    table_start = content.find("CREATE OR REPLACE TABLE")
    if table_start != -1:
        # Find the end of the table definition (first standalone semicolon before next section)
        table_end = content.find("COMMENT = '", table_start)
        if table_end != -1:
            # Find the semicolon after COMMENT
            table_end = content.find(";", table_end)
            table_ddl = content[table_start:table_end+1].strip()
            statements.append(("TABLE", table_ddl))
    
    # Find CREATE PROCEDURE statement
    proc_start = content.find("CREATE OR REPLACE PROCEDURE")
    if proc_start != -1:
        # The procedure ends with '; at the end of the JS block
        # Find the pattern that ends the JS: ';
        proc_search_start = proc_start
        while True:
            proc_end = content.find("';", proc_search_start)
            if proc_end == -1:
                break
            # Check if this is inside the procedure (not in a string)
            test_segment = content[proc_start:proc_end+2]
            if "LANGUAGE JAVASCRIPT" in test_segment:
                proc_ddl = content[proc_start:proc_end+2].strip()
                statements.append(("PROCEDURE", proc_ddl))
                break
            proc_search_start = proc_end + 1
    
    # Execute statements
    for stmt_type, stmt in statements:
        print(f"\n🔧 Executing {stmt_type}...")
        print(f"   Preview: {stmt[:100]}...")
        try:
            cur.execute(stmt)
            print(f"   ✓ {stmt_type} created successfully")
        except Exception as e:
            print(f"   ✗ Error: {e}")
            if stmt_type == "TABLE":
                raise  # Table is critical

def run_stress_test(cur, proc_name: str, table_name: str):
    """Run stress tests with varying lookback days."""
    results = []
    
    print(f"\n{'='*80}")
    print(f"📊 STRESS TEST: {proc_name}")
    print(f"   Days to test: {TEST_DAYS}")
    print(f"{'='*80}\n")
    
    for days in TEST_DAYS:
        try:
            # Truncate table for clean measurement
            cur.execute(f"TRUNCATE TABLE DEV_API_REF.FUSE.{table_name}")
            
            # Run procedure
            start_time = time.time()
            cur.execute(f"CALL DEV_API_REF.FUSE.{proc_name}('{days}')")
            result = cur.fetchone()[0]
            duration = time.time() - start_time
            
            # Get row count
            cur.execute(f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}")
            row_count = cur.fetchone()[0]
            
            entry = {
                "timestamp": datetime.now().isoformat(),
                "table": table_name,
                "days": days,
                "duration_seconds": round(duration, 2),
                "rows": row_count,
                "result": result[:100] if result else "OK"
            }
            results.append(entry)
            
            print(f"   Days={days:2d} | Duration={duration:7.2f}s | Rows={row_count:,} | {result[:50] if result else 'OK'}")
            
        except Exception as e:
            print(f"   Days={days:2d} | ERROR: {str(e)[:80]}")
            results.append({
                "timestamp": datetime.now().isoformat(),
                "table": table_name,
                "days": days,
                "error": str(e)[:200]
            })
    
    return results

def main():
    print("="*80)
    print("🚀 LH_BUCKET_CT DEPLOYMENT & STRESS TEST")
    print(f"   Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*80)
    
    all_results = {"LH_BUCKET": [], "LH_LOADING_CYCLE": []}
    
    with connect() as conn:
        cur = conn.cursor()
        
        # Set context
        print("\n⚙️  Setting Snowflake context...")
        cur.execute("USE ROLE FREEPORT_DE_DEV")
        cur.execute("USE WAREHOUSE WH_API_INTEGRATION")
        cur.execute("USE DATABASE DEV_API_REF")
        cur.execute("USE SCHEMA FUSE")
        print("   ✓ Context set: FREEPORT_DE_DEV / WH_API_INTEGRATION / DEV_API_REF.FUSE")
        
        # ========================================
        # PHASE 1: Deploy LH_BUCKET_CT
        # ========================================
        print("\n" + "="*80)
        print("📦 PHASE 1: DEPLOY LH_BUCKET_CT")
        print("="*80)
        
        try:
            execute_ddl_from_file(
                cur, 
                r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\LH_BUCKET\refactor_ddl.sql"
            )
        except Exception as e:
            print(f"\n⚠️  Deployment error (may already exist): {e}")
        
        # ========================================
        # PHASE 2: Stress Test LH_BUCKET_CT
        # ========================================
        print("\n" + "="*80)
        print("🧪 PHASE 2: STRESS TEST LH_BUCKET_CT")
        print("="*80)
        
        try:
            all_results["LH_BUCKET"] = run_stress_test(cur, "LH_BUCKET_CT_P", "LH_BUCKET_CT")
        except Exception as e:
            print(f"\n❌ Stress test failed: {e}")
        
        # ========================================
        # PHASE 3: Deploy LH_LOADING_CYCLE_CT
        # ========================================
        print("\n" + "="*80)
        print("📦 PHASE 3: DEPLOY LH_LOADING_CYCLE_CT")
        print("="*80)
        
        try:
            execute_ddl_from_file(
                cur,
                r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\LH_LOADING_CYCLE\refactor_ddl.sql"
            )
        except Exception as e:
            print(f"\n⚠️  Deployment error (may already exist): {e}")
        
        # ========================================
        # PHASE 4: Stress Test LH_LOADING_CYCLE_CT
        # ========================================
        print("\n" + "="*80)
        print("🧪 PHASE 4: STRESS TEST LH_LOADING_CYCLE_CT")
        print("="*80)
        
        try:
            all_results["LH_LOADING_CYCLE"] = run_stress_test(cur, "LH_LOADING_CYCLE_CT_P", "LH_LOADING_CYCLE_CT")
        except Exception as e:
            print(f"\n❌ Stress test failed: {e}")
    
    # ========================================
    # SAVE RESULTS
    # ========================================
    output_file = r"C:\Users\Lenovo\dataqbs\FP\SQLRefactoring\Tickets\stress_test_results.json"
    with open(output_file, "w") as f:
        json.dump(all_results, f, indent=2)
    
    print("\n" + "="*80)
    print(f"✅ COMPLETE - Results saved to: {output_file}")
    print("="*80)
    
    # Print summary
    print("\n📈 SUMMARY:")
    for table, results in all_results.items():
        if results:
            print(f"\n   {table}:")
            for r in results:
                if "error" not in r:
                    print(f"      {r['days']:2d} days → {r['duration_seconds']:7.2f}s | {r['rows']:,} rows")

if __name__ == "__main__":
    main()
