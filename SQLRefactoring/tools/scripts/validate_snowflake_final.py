"""
=============================================================================
SNOWFLAKE VALIDATION - Corrected Queries
=============================================================================
Uses correct column names: SITE_CODE, SHOVEL_NAME, TRUCK_NAME
=============================================================================
"""

import os
import json
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# =============================================================================
# SNOWFLAKE CONNECTION
# =============================================================================
def get_snowflake_connection():
    """Create Snowflake connection with externalbrowser."""
    import snowflake.connector
    
    conn = snowflake.connector.connect(
        account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
        user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
        authenticator=os.getenv('CONN_LIB_SNOWFLAKE_AUTHENTICATOR', 'externalbrowser'),
        role=os.getenv('CONN_LIB_SNOWFLAKE_ROLE'),
        warehouse=os.getenv('CONN_LIB_SNOWFLAKE_WAREHOUSE'),
        database=os.getenv('CONN_LIB_SNOWFLAKE_DATABASE'),
    )
    return conn

def run_query(conn, query: str, limit: int = 5) -> dict:
    """Execute query and return results."""
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description] if cursor.description else []
        rows = cursor.fetchmany(limit)
        row_count = cursor.rowcount
        cursor.close()
        return {
            "status": "SUCCESS",
            "row_count": row_count if row_count else len(rows),
            "columns": columns,
            "sample_data": [dict(zip(columns, [str(v) if v is not None else None for v in row])) for row in rows]
        }
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

# =============================================================================
# CORRECTED SNOWFLAKE QUERIES - Using correct column names
# =============================================================================
SNOWFLAKE_KPIS = {
    # =========================================================================
    # SCHEMA DISCOVERY FIRST - Get actual column names
    # =========================================================================
    "schema_loading_cycle": {
        "section": "Schema Discovery",
        "metric": "LH_LOADING_CYCLE Schema",
        "query": """
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_LOADING_CYCLE'
ORDER BY ordinal_position;
"""
    },
    
    "schema_haul_cycle": {
        "section": "Schema Discovery",
        "metric": "LH_HAUL_CYCLE Schema",
        "query": """
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_HAUL_CYCLE'
ORDER BY ordinal_position;
"""
    },

    # =========================================================================
    # LOADING KPIS - Corrected with SITE_CODE and SHOVEL_NAME
    # =========================================================================
    "loading_dig_compliance": {
        "section": "Loading",
        "metric": "Dig Compliance Count",
        "description": "Total loading events in last hour at Morenci",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(*) as total_dig_events,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    "loading_dig_rate": {
        "section": "Loading",
        "metric": "Dig Rate (Tons per Hour)",
        "description": "Total tons loaded by shovel fleet in last hour",
        "query": """
SELECT 
    SITE_CODE,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_tons_1hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT SHOVEL_NAME) as shovel_count,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    "loading_priority_shovels": {
        "section": "Loading",
        "metric": "Priority Shovels (Top 5)",
        "description": "Top 5 shovels by total tons in last hour",
        "query": """
SELECT 
    SHOVEL_NAME as shovel_id,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / NULLIF(COUNT(*), 0), 2) as avg_payload
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SHOVEL_NAME
ORDER BY total_tons DESC
LIMIT 5;
"""
    },
    
    # =========================================================================
    # HAULAGE KPIS - Corrected with SITE_CODE and TRUCK_NAME
    # =========================================================================
    "haulage_truck_count": {
        "section": "Haulage",
        "metric": "Active Truck Count",
        "description": "Number of unique trucks with cycles in last hour",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_NAME) as active_trucks,
    COUNT(*) as total_cycles,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    "haulage_cycle_time": {
        "section": "Haulage",
        "metric": "Average Cycle Time (min)",
        "description": "Average round trip time across truck fleet",
        "query": """
SELECT 
    SITE_CODE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as min_cycle_time,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as max_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT TRUCK_NAME) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE;
"""
    },
    
    "haulage_dump_locations": {
        "section": "Haulage",
        "metric": "Dump Location Distribution",
        "description": "Material dumped by destination in last 12 hours",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 15;
"""
    },
    
    # =========================================================================
    # MILL DELIVERIES - Tons to Mill
    # =========================================================================
    "mill_tons_delivered": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill Tons Delivered",
        "description": "Total tons delivered to Mill/Crusher in last 12 hours",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%cr2%' OR DUMP_LOC_NAME ILIKE '%cr3%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # MFL DELIVERIES - Tons to MFL
    # =========================================================================
    "mfl_tons_delivered": {
        "section": "Lbs on Ground - MFL",
        "metric": "MFL Tons Delivered",
        "description": "Total tons delivered to MFL in last 12 hours",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%morenci%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # ROM DELIVERIES - Tons to ROM
    # =========================================================================
    "rom_tons_delivered": {
        "section": "Lbs on Ground - ROM",
        "metric": "ROM Tons Delivered",
        "description": "Total tons delivered to ROM stockpile in last 12 hours",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # AGGREGATE SUMMARY
    # =========================================================================
    "summary_by_destination_type": {
        "section": "Summary",
        "metric": "Production by Destination Type",
        "description": "Aggregate tons by destination category",
        "query": """
SELECT 
    CASE 
        WHEN DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%cr2%' OR DUMP_LOC_NAME ILIKE '%cr3%' OR DUMP_LOC_NAME ILIKE '%crusher%' THEN 'MILL'
        WHEN DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%' THEN 'MFL'
        WHEN DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%' THEN 'ROM'
        WHEN DUMP_LOC_NAME ILIKE '%waste%' OR DUMP_LOC_NAME ILIKE '%dump%' THEN 'WASTE'
        ELSE 'OTHER'
    END as destination_type,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_NAME) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY destination_type
ORDER BY total_tons DESC;
"""
    },
    
    "loading_summary_by_shovel": {
        "section": "Summary",
        "metric": "Loading Summary by Shovel",
        "description": "All shovels with their production in last 12 hours",
        "query": """
SELECT 
    SHOVEL_NAME,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_metric_tons,
    COUNT(*) as load_count,
    ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS), 2) as avg_payload,
    MIN(CYCLE_START_TS_LOCAL) as first_load,
    MAX(CYCLE_START_TS_LOCAL) as last_load
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SHOVEL_NAME
ORDER BY total_metric_tons DESC
LIMIT 20;
"""
    },
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
def run_validation():
    """Run Snowflake query validation."""
    results = {
        "validation_timestamp": datetime.now().isoformat(),
        "source": "Snowflake",
        "connection": {
            "account": os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
            "database": os.getenv('CONN_LIB_SNOWFLAKE_DATABASE'),
            "warehouse": os.getenv('CONN_LIB_SNOWFLAKE_WAREHOUSE'),
            "authenticator": "externalbrowser"
        },
        "summary": {
            "total_kpis": 0,
            "success": 0,
            "failed": 0
        },
        "kpis": {}
    }
    
    print("=" * 80)
    print("SNOWFLAKE KPI VALIDATION - Corrected Column Names")
    print("=" * 80)
    
    # Connect to Snowflake
    print("\n🔐 Connecting to Snowflake (browser auth)...")
    try:
        conn = get_snowflake_connection()
        print("✅ Snowflake connected successfully!")
    except Exception as e:
        print(f"❌ Snowflake connection failed: {e}")
        return results
    
    # Process each KPI
    for kpi_id, kpi_config in SNOWFLAKE_KPIS.items():
        results["summary"]["total_kpis"] += 1
        
        print(f"\n📊 [{kpi_config['section']}] {kpi_config['metric']}")
        
        kpi_result = {
            "section": kpi_config["section"],
            "metric": kpi_config["metric"],
            "description": kpi_config.get("description", ""),
            "query": kpi_config["query"].strip()
        }
        
        # Execute query
        result = run_query(conn, kpi_config["query"])
        kpi_result["validation"] = result
        
        if result["status"] == "SUCCESS":
            results["summary"]["success"] += 1
            print(f"   ✅ SUCCESS - {result['row_count']} rows")
            if result.get("sample_data"):
                for i, row in enumerate(result["sample_data"][:3]):
                    print(f"   📋 Row {i+1}: {row}")
        else:
            results["summary"]["failed"] += 1
            print(f"   ❌ FAILED - {result.get('error', 'Unknown error')}")
        
        results["kpis"][kpi_id] = kpi_result
    
    # Close connection
    conn.close()
    
    # Save results
    output_path = Path(__file__).parent.parent.parent / "reports" / f"snowflake_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, default=str, ensure_ascii=False)
    
    # Print summary
    print(f"\n\n{'='*80}")
    print("VALIDATION SUMMARY")
    print(f"{'='*80}")
    print(f"Total KPIs: {results['summary']['total_kpis']}")
    print(f"Success: {results['summary']['success']}")
    print(f"Failed: {results['summary']['failed']}")
    success_rate = (results['summary']['success'] / results['summary']['total_kpis'] * 100) if results['summary']['total_kpis'] > 0 else 0
    print(f"Success Rate: {success_rate:.1f}%")
    print(f"\n📄 Results saved to: {output_path}")
    print(f"{'='*80}")
    
    return results

if __name__ == "__main__":
    run_validation()
