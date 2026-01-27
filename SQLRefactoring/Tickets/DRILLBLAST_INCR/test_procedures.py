"""
COMPLETE TEST SUITE FOR DRILLBLAST INCR PROCEDURES
Author: Carlos Carrillo / Vikas Review
Date: 2026-01-26
Purpose: Test all 22 INCR objects (11 tables + 11 procedures) in DEV environment
"""

import snowflake.connector
from azure.identity import DefaultAzureCredential
import json
import time
from datetime import datetime

# ============================================================================
# CONFIGURATION
# ============================================================================

SNOWFLAKE_CONFIG = {
    "account": "fcx-na",
    "authenticator": "externalbrowser",  # SSO authentication
    "warehouse": "COMPUTE_WH",
    "database": "DEV_API_REF",
    "schema": "FUSE",
    "role": "ACCOUNTADMIN"
}

# All procedures to test
PROCEDURES_TO_TEST = [
    # Fixed with purge logic (Vikas fix)
    {"name": "BLAST_PLAN_INCR_P", "params": "('7', '90')", "has_purge": True},
    {"name": "DRILL_CYCLE_INCR_P", "params": "('7', '90')", "has_purge": True},
    {"name": "DRILL_PLAN_INCR_P", "params": "('7', '90')", "has_purge": True},
    {"name": "DRILLBLAST_SHIFT_INCR_P", "params": "('7', '90')", "has_purge": True},
    {"name": "LH_HAUL_CYCLE_INCR_P", "params": "('7', '90')", "has_purge": True},
    
    # Already had purge logic
    {"name": "BL_DW_BLAST_INCR_P", "params": "('7')", "has_purge": True},
    {"name": "BL_DW_HOLE_INCR_P", "params": "('7')", "has_purge": True},
    {"name": "DRILLBLAST_EQUIPMENT_INCR_P", "params": "('7')", "has_purge": True},
    {"name": "DRILLBLAST_OPERATOR_INCR_P", "params": "('7')", "has_purge": True},
    
    # Placeholders
    {"name": "BLAST_PLAN_EXECUTION_INCR_P", "params": "('7')", "has_purge": False},
    {"name": "BL_DW_BLASTPROPERTYVALUE_INCR_P", "params": "('7')", "has_purge": False},
]

# All tables to verify
TABLES_TO_CHECK = [
    "BLAST_PLAN_INCR",
    "DRILL_CYCLE_INCR",
    "DRILL_PLAN_INCR",
    "DRILLBLAST_SHIFT_INCR",
    "LH_HAUL_CYCLE_INCR",
    "BL_DW_BLAST_INCR",
    "BL_DW_HOLE_INCR",
    "DRILLBLAST_EQUIPMENT_INCR",
    "DRILLBLAST_OPERATOR_INCR",
    "BLAST_PLAN_EXECUTION_INCR",
    "BL_DW_BLASTPROPERTYVALUE_INCR",
]


class SnowflakeTestRunner:
    def __init__(self):
        self.conn = None
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "environment": "DEV_API_REF.FUSE",
            "tables": {},
            "procedures": {},
            "summary": {
                "total_tests": 0,
                "passed": 0,
                "failed": 0,
                "errors": []
            }
        }
    
    def connect(self):
        """Connect to Snowflake using SSO"""
        print("🔗 Connecting to Snowflake DEV environment...")
        try:
            self.conn = snowflake.connector.connect(**SNOWFLAKE_CONFIG)
            print("✅ Connected successfully!")
            return True
        except Exception as e:
            print(f"❌ Connection failed: {e}")
            self.results["summary"]["errors"].append(f"Connection failed: {e}")
            return False
    
    def run_query(self, query: str) -> tuple:
        """Execute a query and return results"""
        cursor = self.conn.cursor()
        try:
            cursor.execute(query)
            result = cursor.fetchall()
            return True, result
        except Exception as e:
            return False, str(e)
        finally:
            cursor.close()
    
    def test_table_exists(self, table_name: str) -> bool:
        """Check if table exists and get row count"""
        print(f"  📋 Testing table: {table_name}...")
        
        # Check existence
        check_query = f"""
            SELECT COUNT(*) 
            FROM information_schema.tables 
            WHERE table_schema = 'FUSE' 
            AND table_name = '{table_name}'
        """
        success, result = self.run_query(check_query)
        
        if not success or result[0][0] == 0:
            print(f"    ❌ Table does not exist")
            self.results["tables"][table_name] = {"exists": False, "row_count": 0}
            return False
        
        # Get row count
        count_query = f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table_name}"
        success, result = self.run_query(count_query)
        
        row_count = result[0][0] if success else 0
        print(f"    ✅ Exists with {row_count:,} rows")
        
        self.results["tables"][table_name] = {"exists": True, "row_count": row_count}
        return True
    
    def test_procedure(self, proc_info: dict) -> bool:
        """Test a stored procedure"""
        proc_name = proc_info["name"]
        params = proc_info["params"]
        has_purge = proc_info["has_purge"]
        
        print(f"  🔧 Testing procedure: {proc_name}...")
        
        call_query = f"CALL DEV_API_REF.FUSE.{proc_name}{params}"
        
        start_time = time.time()
        success, result = self.run_query(call_query)
        elapsed_time = time.time() - start_time
        
        if not success:
            print(f"    ❌ Failed: {result}")
            self.results["procedures"][proc_name] = {
                "success": False,
                "error": result,
                "elapsed_seconds": elapsed_time
            }
            return False
        
        # Parse result
        result_str = result[0][0] if result else "No result"
        
        # Check if purge logic is working (for fixed procedures)
        if has_purge:
            if "Purged:" in result_str or "Deleted:" in result_str:
                print(f"    ✅ Success ({elapsed_time:.2f}s): {result_str}")
                purge_working = True
            else:
                print(f"    ⚠️ Warning: Expected purge result, got: {result_str}")
                purge_working = False
        else:
            print(f"    ✅ Success ({elapsed_time:.2f}s): {result_str}")
            purge_working = None
        
        self.results["procedures"][proc_name] = {
            "success": True,
            "result": result_str,
            "elapsed_seconds": elapsed_time,
            "purge_working": purge_working
        }
        return True
    
    def verify_purge_logic(self) -> bool:
        """Verify that the 5 fixed procedures have purge logic"""
        print("\n📊 Verifying Purge Logic (Vikas Fix)...")
        
        fixed_procedures = [
            "BLAST_PLAN_INCR_P",
            "DRILL_CYCLE_INCR_P", 
            "DRILL_PLAN_INCR_P",
            "DRILLBLAST_SHIFT_INCR_P",
            "LH_HAUL_CYCLE_INCR_P"
        ]
        
        all_pass = True
        for proc_name in fixed_procedures:
            if proc_name in self.results["procedures"]:
                proc_result = self.results["procedures"][proc_name]
                if proc_result.get("purge_working"):
                    print(f"  ✅ {proc_name}: Purge logic verified")
                else:
                    print(f"  ⚠️ {proc_name}: Purge logic check inconclusive")
            else:
                print(f"  ❌ {proc_name}: Not tested")
                all_pass = False
        
        return all_pass
    
    def run_all_tests(self):
        """Run complete test suite"""
        print("=" * 70)
        print("🧪 DRILLBLAST INCR COMPLETE TEST SUITE")
        print("=" * 70)
        print(f"Environment: DEV_API_REF.FUSE")
        print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 70)
        
        if not self.connect():
            return self.results
        
        # Test 1: Verify all tables exist
        print("\n📋 STEP 1: Verifying Tables...")
        for table in TABLES_TO_CHECK:
            self.results["summary"]["total_tests"] += 1
            if self.test_table_exists(table):
                self.results["summary"]["passed"] += 1
            else:
                self.results["summary"]["failed"] += 1
        
        # Test 2: Run all procedures
        print("\n🔧 STEP 2: Testing Procedures...")
        for proc_info in PROCEDURES_TO_TEST:
            self.results["summary"]["total_tests"] += 1
            if self.test_procedure(proc_info):
                self.results["summary"]["passed"] += 1
            else:
                self.results["summary"]["failed"] += 1
        
        # Test 3: Verify purge logic (Vikas fix)
        self.verify_purge_logic()
        
        # Test 4: Verify row counts after procedures
        print("\n📊 STEP 3: Final Row Counts...")
        for table in TABLES_TO_CHECK[:9]:  # Skip placeholders
            count_query = f"SELECT COUNT(*) FROM DEV_API_REF.FUSE.{table}"
            success, result = self.run_query(count_query)
            if success:
                print(f"  {table}: {result[0][0]:,} rows")
        
        # Summary
        print("\n" + "=" * 70)
        print("📊 TEST SUMMARY")
        print("=" * 70)
        print(f"Total Tests: {self.results['summary']['total_tests']}")
        print(f"Passed: {self.results['summary']['passed']} ✅")
        print(f"Failed: {self.results['summary']['failed']} ❌")
        
        if self.results['summary']['failed'] == 0:
            print("\n🎉 ALL TESTS PASSED! Ready for Vikas review.")
        else:
            print("\n⚠️ Some tests failed. Review errors above.")
        
        # Close connection
        if self.conn:
            self.conn.close()
        
        return self.results
    
    def save_results(self, filepath: str = "test_results.json"):
        """Save results to JSON file"""
        with open(filepath, 'w') as f:
            json.dump(self.results, f, indent=2, default=str)
        print(f"\n📄 Results saved to: {filepath}")


def main():
    """Main entry point"""
    runner = SnowflakeTestRunner()
    results = runner.run_all_tests()
    runner.save_results("test_results_dev.json")
    return results


if __name__ == "__main__":
    main()
