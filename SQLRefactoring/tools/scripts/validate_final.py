"""
=============================================================================
FINAL SNOWFLAKE + ADX VALIDATION - All KPIs with Correct Column Names
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
    import snowflake.connector
    return snowflake.connector.connect(
        account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
        user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
        authenticator='externalbrowser',
        role=os.getenv('CONN_LIB_SNOWFLAKE_ROLE'),
        warehouse=os.getenv('CONN_LIB_SNOWFLAKE_WAREHOUSE'),
        database=os.getenv('CONN_LIB_SNOWFLAKE_DATABASE'),
    )

def run_sf_query(conn, query: str, limit: int = 5) -> dict:
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
# ADX CONNECTION
# =============================================================================
def get_adx_client():
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER_URL, credential)
    return KustoClient(kcsb)

def run_adx_query(client, database: str, query: str) -> dict:
    try:
        response = client.execute(database, query)
        columns = [col.column_name for col in response.primary_results[0].columns]
        rows = list(response.primary_results[0])
        return {
            "status": "SUCCESS",
            "row_count": len(rows),
            "columns": columns,
            "sample_data": [dict(zip(columns, [str(v) for v in row])) for row in rows[:5]]
        }
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

# =============================================================================
# ALL KPIS - CORRECTED QUERIES
# =============================================================================
ALL_KPIS = {
    # =========================================================================
    # LOADING - SNOWFLAKE (Using EXCAV_ID with JOIN to get names)
    # =========================================================================
    "loading_dig_rate": {
        "section": "Loading",
        "metric": "Dig Rate (Tons per Hour)",
        "source": "SNOWFLAKE",
        "description": "Total tons loaded by shovel fleet in last hour",
        "query": """
SELECT 
    SITE_CODE,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_tons_1hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT EXCAV_ID) as shovel_count,
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
        "metric": "Priority Shovels (Top 5 by EXCAV_ID)",
        "source": "SNOWFLAKE",
        "description": "Top 5 excavators by total tons",
        "query": """
SELECT 
    e.EQUIP_NAME as shovel_name,
    lc.EXCAV_ID,
    SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count,
    ROUND(AVG(lc.MEASURED_PAYLOAD_METRIC_TONS), 2) as avg_payload
FROM prod_wg.load_haul.lh_loading_cycle lc
LEFT JOIN prod_wg.load_haul.lh_equipment e ON lc.EXCAV_ID = e.EQUIP_ID AND lc.SITE_CODE = e.SITE_CODE
WHERE lc.CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND lc.SITE_CODE = 'MOR'
GROUP BY e.EQUIP_NAME, lc.EXCAV_ID
ORDER BY total_tons DESC
LIMIT 5;
"""
    },
    
    "loading_summary_hourly": {
        "section": "Loading",
        "metric": "Loading Summary - Last Hour",
        "source": "SNOWFLAKE",
        "description": "Summary of all loading activity",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(*) as total_loads,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_metric_tons,
    ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS), 2) as avg_payload,
    COUNT(DISTINCT EXCAV_ID) as active_excavators,
    COUNT(DISTINCT TRUCK_ID) as trucks_loaded
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # HAULAGE - SNOWFLAKE (Using TRUCK_ID with JOIN to get names)
    # =========================================================================
    "haulage_truck_count": {
        "section": "Haulage",
        "metric": "Active Truck Count",
        "source": "SNOWFLAKE",
        "description": "Number of unique trucks with cycles in last hour",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
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
        "source": "SNOWFLAKE",
        "description": "Average round trip time across truck fleet",
        "query": """
SELECT 
    SITE_CODE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as min_cycle_time,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as max_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT TRUCK_ID) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE;
"""
    },
    
    "haulage_top_trucks": {
        "section": "Haulage",
        "metric": "Top 5 Trucks by Tons Hauled",
        "source": "SNOWFLAKE",
        "description": "Top 5 trucks by total tons",
        "query": """
SELECT 
    e.EQUIP_NAME as truck_name,
    hc.TRUCK_ID,
    SUM(hc.REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as cycle_count,
    ROUND(AVG(hc.TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_mins
FROM prod_wg.load_haul.lh_haul_cycle hc
LEFT JOIN prod_wg.load_haul.lh_equipment e ON hc.TRUCK_ID = e.EQUIP_ID AND hc.SITE_CODE = e.SITE_CODE
WHERE hc.CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND hc.SITE_CODE = 'MOR'
GROUP BY e.EQUIP_NAME, hc.TRUCK_ID
ORDER BY total_tons DESC
LIMIT 5;
"""
    },
    
    "haulage_dump_locations": {
        "section": "Haulage",
        "metric": "Dump Location Distribution",
        "source": "SNOWFLAKE",
        "description": "Material dumped by destination in last 12 hours",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks
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
    # MILL / MFL / ROM DELIVERIES - SNOWFLAKE
    # =========================================================================
    "mill_tons_delivered": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill Tons Delivered",
        "source": "SNOWFLAKE",
        "description": "Total tons delivered to Mill/Crusher destinations",
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
    
    "mfl_tons_delivered": {
        "section": "Lbs on Ground - MFL",
        "metric": "MFL Tons Delivered",
        "source": "SNOWFLAKE",
        "description": "Total tons delivered to MFL destinations",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    "production_by_category": {
        "section": "Summary",
        "metric": "Production by Destination Category",
        "source": "SNOWFLAKE",
        "description": "Aggregate tons by destination category in last 12 hours",
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
    COUNT(DISTINCT TRUCK_ID) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY destination_type
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # ADX - MILL CRUSHER RATE (PI Tags) - Using correct column names
    # sensor_id, value, timestamp (not Name, Value, Timestamp)
    # =========================================================================
    "mill_crusher_rate_current": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill Crusher Rate - Current (TPOH)",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Current mill crusher throughput from PI tag",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR03_WI00317_PV'
| project sensor_id, value, timestamp
"""
    },
    
    "mill_crusher_rate_avg": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill Crusher Rate - Rolling Avg (TPOH)",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "8-hour average mill crusher throughput",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR03_WI00317_PV'
| project sensor_id, current_value=todouble(value), last_update=timestamp
"""
    },
    
    "mill_crusher_rate_trend": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill Crusher Rate - Hourly Trend",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Current mill crusher value with trend indicator",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR03_WI00317_PV'
| project sensor_id, value=todouble(value), timestamp, data_source
"""
    },
    
    "mill_ios_current": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill IOS Level - Current (%)",
        "source": "ADX",
        "database": "Morenci",
        "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
        "description": "Current IOS levels - Main and Small",
        "query": """
FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project sensor_id, value=todouble(value), timestamp
"""
    },
    
    "mill_ios_with_direction": {
        "section": "Lbs on Ground - Mill",
        "metric": "Mill IOS Level with Metadata",
        "source": "ADX",
        "database": "Morenci",
        "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
        "description": "IOS levels with data quality",
        "query": """
FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project sensor_id, value=todouble(value), timestamp, quality, data_source
"""
    },
    
    # =========================================================================
    # ADX - MFL CRUSHER RATE (PI Tags)
    # =========================================================================
    "mfl_crusher_rate_current": {
        "section": "Lbs on Ground - MFL",
        "metric": "MFL Crusher Rate - Current (TPOH)",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "Current MFL crusher throughput from PI tag",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR02_WI01203_PV'
| project sensor_id, value=todouble(value), timestamp
"""
    },
    
    "mfl_crusher_rate_avg": {
        "section": "Lbs on Ground - MFL",
        "metric": "MFL Crusher Rate - with Metadata",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "Current MFL crusher value with metadata",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR02_WI01203_PV'
| project sensor_id, value=todouble(value), timestamp, uom, quality, data_source
"""
    },
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
def run_validation():
    results = {
        "validation_timestamp": datetime.now().isoformat(),
        "summary": {
            "total_kpis": 0,
            "snowflake_success": 0,
            "snowflake_failed": 0,
            "adx_success": 0,
            "adx_failed": 0
        },
        "kpis": {}
    }
    
    print("=" * 80)
    print("COMPLETE KPI VALIDATION - Snowflake & ADX")
    print("=" * 80)
    
    # Connect Snowflake
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = None
    try:
        sf_conn = get_snowflake_connection()
        print("✅ Snowflake connected")
    except Exception as e:
        print(f"❌ Snowflake failed: {e}")
    
    # Connect ADX
    print("\n🔐 Connecting to ADX...")
    adx_client = None
    try:
        adx_client = get_adx_client()
        print("✅ ADX connected")
    except Exception as e:
        print(f"❌ ADX failed: {e}")
    
    # Process each KPI
    for kpi_id, kpi_config in ALL_KPIS.items():
        results["summary"]["total_kpis"] += 1
        source = kpi_config["source"]
        
        print(f"\n📊 [{kpi_config['section']}] {kpi_config['metric']}")
        
        kpi_result = {
            "section": kpi_config["section"],
            "metric": kpi_config["metric"],
            "source": source,
            "description": kpi_config.get("description", ""),
            "query": kpi_config["query"].strip()
        }
        
        if "pi_tag" in kpi_config:
            kpi_result["pi_tag"] = kpi_config["pi_tag"]
        if "pi_tags" in kpi_config:
            kpi_result["pi_tags"] = kpi_config["pi_tags"]
        if "database" in kpi_config:
            kpi_result["database"] = kpi_config["database"]
        
        # Execute
        if source == "SNOWFLAKE" and sf_conn:
            result = run_sf_query(sf_conn, kpi_config["query"])
            kpi_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["snowflake_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 {result['sample_data'][0]}")
            else:
                results["summary"]["snowflake_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown')}")
                
        elif source == "ADX" and adx_client:
            db = kpi_config.get("database", "Morenci")
            result = run_adx_query(adx_client, db, kpi_config["query"])
            kpi_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["adx_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 {result['sample_data'][0]}")
            else:
                results["summary"]["adx_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown')}")
        else:
            kpi_result["validation"] = {"status": "SKIPPED", "reason": "No connection"}
            print(f"   ⏭️ SKIPPED - No connection")
        
        results["kpis"][kpi_id] = kpi_result
    
    if sf_conn:
        sf_conn.close()
    
    # Save
    output_path = Path(__file__).parent.parent.parent / "reports" / f"final_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, default=str, ensure_ascii=False)
    
    # Summary
    print(f"\n\n{'='*80}")
    print("VALIDATION SUMMARY")
    print(f"{'='*80}")
    print(f"Total KPIs: {results['summary']['total_kpis']}")
    sf_total = results['summary']['snowflake_success'] + results['summary']['snowflake_failed']
    adx_total = results['summary']['adx_success'] + results['summary']['adx_failed']
    print(f"Snowflake: {results['summary']['snowflake_success']}/{sf_total} success")
    print(f"ADX: {results['summary']['adx_success']}/{adx_total} success")
    print(f"\n📄 Results: {output_path}")
    print(f"{'='*80}")
    
    return results

if __name__ == "__main__":
    run_validation()
