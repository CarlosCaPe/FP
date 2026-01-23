"""
=============================================================================
COMPLETE VALIDATION - All 16 Required Outcomes
=============================================================================
Validates ALL outcomes from the business requirements list
=============================================================================
"""

import os
import json
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

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

def get_adx_client():
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER_URL, credential)
    return KustoClient(kcsb)

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
# ALL 16 REQUIRED OUTCOMES
# =============================================================================
ALL_OUTCOMES = {
    # =========================================================================
    # 1. Dig compliance (%)
    # =========================================================================
    "dig_compliance": {
        "outcome_id": 1,
        "name": "Dig compliance (%)",
        "section": "Loading",
        "source": "SNOWFLAKE",
        "description": "Spatial compliance of shovel dig points relative to dig zones. Measures how well operators follow dig plans.",
        "sensible_range": "0-100%",
        "note": "True compliance requires dig polygon data. This query provides dig location metrics as proxy.",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(*) as total_dig_events,
    COUNT(DISTINCT LOADING_LOC_ID) as unique_dig_locations,
    COUNT(DISTINCT EXCAV_ID) as active_shovels,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as avg_dig_elevation_ft,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # 2. Dig rate (TPOH)
    # =========================================================================
    "dig_rate": {
        "outcome_id": 2,
        "name": "Dig rate (TPOH)",
        "section": "Loading",
        "source": "SNOWFLAKE",
        "description": "Total tons loaded by entire shovel fleet each hour",
        "sensible_range": "up to 99,000 TPH",
        "query": """
SELECT 
    SITE_CODE,
    SUM(MEASURED_PAYLOAD_METRIC_TONS) as total_tons_1hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT EXCAV_ID) as shovel_count,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / NULLIF(COUNT(DISTINCT EXCAV_ID), 0), 2) as avg_tons_per_shovel,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # 3. Priority shovels
    # =========================================================================
    "priority_shovels": {
        "outcome_id": 3,
        "name": "Priority shovels",
        "section": "Loading",
        "source": "SNOWFLAKE",
        "description": "Top 5 shovels ranked by dig rate/production",
        "sensible_range": "Rate: up to 5,000 TPH per shovel",
        "query": """
SELECT 
    e.EQUIP_NAME as shovel_name,
    lc.EXCAV_ID,
    SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count,
    ROUND(AVG(lc.MEASURED_PAYLOAD_METRIC_TONS), 2) as avg_payload_tons
FROM prod_wg.load_haul.lh_loading_cycle lc
LEFT JOIN prod_wg.load_haul.lh_equipment e 
    ON lc.EXCAV_ID = e.EQUIP_ID AND lc.SITE_CODE = e.SITE_CODE
WHERE lc.CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND lc.SITE_CODE = 'MOR'
GROUP BY e.EQUIP_NAME, lc.EXCAV_ID
ORDER BY total_tons DESC
LIMIT 5;
"""
    },
    
    # =========================================================================
    # 4. Number of trucks (qty)
    # =========================================================================
    "truck_count": {
        "outcome_id": 4,
        "name": "Number of trucks (qty)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Number of mechanically available trucks",
        "sensible_range": "100-130 trucks",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
    COUNT(*) as total_cycles,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons_hauled,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # 5. Cycle Time (min)
    # =========================================================================
    "cycle_time": {
        "outcome_id": 5,
        "name": "Cycle Time (min)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Average round trip time across truck fleet",
        "sensible_range": "35-45 min",
        "query": """
SELECT 
    SITE_CODE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as min_cycle_time,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as max_cycle_time,
    ROUND(STDDEV(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as stddev_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT TRUCK_ID) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # 6. Asset Efficiency
    # =========================================================================
    "asset_efficiency": {
        "outcome_id": 6,
        "name": "Asset Efficiency",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Truck utilization and efficiency metrics",
        "sensible_range": "80-95%",
        "note": "Calculated as payload efficiency and cycle productivity",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    COUNT(*) as total_cycles,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_payload_tons,
    ROUND(AVG(REPORT_PAYLOAD_SHORT_TONS), 2) as avg_payload_per_cycle,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS) / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as tons_per_truck,
    ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as cycles_per_truck
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
GROUP BY SITE_CODE;
"""
    },
    
    # =========================================================================
    # 7. Dump plan compliance (%)
    # =========================================================================
    "dump_plan_compliance": {
        "outcome_id": 7,
        "name": "Dump plan compliance (%)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Material dumped at correct destinations vs plan",
        "sensible_range": "0-100%",
        "note": "Shows distribution of dumps by location; compliance requires comparison to plan",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS) * 100.0 / SUM(SUM(REPORT_PAYLOAD_SHORT_TONS)) OVER (), 2) as pct_of_total,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 10;
"""
    },
    
    # =========================================================================
    # 8. Mill - tons delivered
    # =========================================================================
    "mill_tons_delivered": {
        "outcome_id": 8,
        "name": "Mill - tons delivered",
        "section": "Lbs on Ground - Mill",
        "source": "SNOWFLAKE",
        "description": "Total tons of material dumped at Mill location",
        "sensible_range": "~108kt per shift",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%cr2%' OR DUMP_LOC_NAME ILIKE '%cr3%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # 9. Mill - Crusher Rate (TPOH)
    # =========================================================================
    "mill_crusher_rate": {
        "outcome_id": 9,
        "name": "Mill - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Current rate at Mill crusher from PI tag",
        "sensible_range": "up to 9,000 TPH",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR03_WI00317_PV'
| project sensor_id, value=todouble(value), timestamp, uom, quality, data_source
"""
    },
    
    # =========================================================================
    # 10. Mill - Mill Rate (TPOH)
    # =========================================================================
    "mill_mill_rate": {
        "outcome_id": 10,
        "name": "Mill - Mill Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Throughput rate at Mill. Using same crusher tag until Mill-specific tag identified.",
        "sensible_range": "7,000-9,000 TPH",
        "note": "Requires analysis to identify correct Mill Rate PI tag vs Crusher Rate",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR03_WI00317_PV'
| project sensor_id, rate_tph=todouble(value), timestamp, data_source
| extend metric_type = 'Mill Rate (using Crusher tag)'
"""
    },
    
    # =========================================================================
    # 11. Mill - Strategy compliance
    # =========================================================================
    "mill_strategy_compliance": {
        "outcome_id": 11,
        "name": "Mill - Strategy compliance",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "database": "Morenci",
        "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
        "description": "IOS stockpile levels and direction indicators for Mill strategy",
        "sensible_range": "250,000-500,000 tons stockpile",
        "note": "Uses IOS level sensors as strategy compliance proxy",
        "query": """
FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project sensor_id, 
          ios_level_pct=todouble(value), 
          timestamp, 
          quality,
          data_source
| extend stockpile_type = iff(sensor_id contains 'CC06', 'Main IOS', 'Small IOS')
"""
    },
    
    # =========================================================================
    # 12. MFL - tons delivered
    # =========================================================================
    "mfl_tons_delivered": {
        "outcome_id": 12,
        "name": "MFL - tons delivered",
        "section": "Lbs on Ground - MFL",
        "source": "SNOWFLAKE",
        "description": "Total tons of material dumped at MFL location",
        "sensible_range": "~60kt per shift",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # 13. MFL - Crusher Rate (TPOH)
    # =========================================================================
    "mfl_crusher_rate": {
        "outcome_id": 13,
        "name": "MFL - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "Current rate at MFL crusher from PI tag",
        "sensible_range": "up to 5,000 TPH",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR02_WI01203_PV'
| project sensor_id, value=todouble(value), timestamp, uom, quality, data_source
"""
    },
    
    # =========================================================================
    # 14. MFL - FOS Rate (TPOH)
    # =========================================================================
    "mfl_fos_rate": {
        "outcome_id": 14,
        "name": "MFL - FOS Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "FOS/FCP Rate at MFL. Using MFL Crusher tag until FOS-specific tag identified.",
        "sensible_range": "4,000-5,000 TPH",
        "note": "Requires analysis to identify correct FOS Rate PI tag vs Crusher Rate",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR02_WI01203_PV'
| project sensor_id, rate_tph=todouble(value), timestamp, data_source
| extend metric_type = 'FOS Rate (using MFL Crusher tag)'
"""
    },
    
    # =========================================================================
    # 15. MFL - Strategy compliance
    # =========================================================================
    "mfl_strategy_compliance": {
        "outcome_id": 15,
        "name": "MFL - Strategy compliance",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "MFL operational metrics as strategy compliance indicator",
        "sensible_range": "50,000-180,000 tons capacity",
        "note": "Requires IOS-specific tags for MFL. Using crusher rate as proxy.",
        "query": """
FCTSCURRENT()
| where sensor_id == 'MOR-CR02_WI01203_PV'
| project sensor_id, 
          crusher_rate_tph=todouble(value), 
          timestamp, 
          quality,
          data_source
"""
    },
    
    # =========================================================================
    # 16. ROM - tons delivered
    # =========================================================================
    "rom_tons_delivered": {
        "outcome_id": 16,
        "name": "ROM - tons delivered",
        "section": "Lbs on Ground - ROM",
        "source": "SNOWFLAKE",
        "description": "Total tons of material dumped at ROM stockpile location",
        "sensible_range": "~250kt per shift",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = 'MOR'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC;
"""
    },
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
def run_validation():
    results = {
        "validation_timestamp": datetime.now().isoformat(),
        "required_outcomes": 16,
        "summary": {
            "total": 0,
            "snowflake_success": 0,
            "snowflake_failed": 0,
            "adx_success": 0,
            "adx_failed": 0
        },
        "outcomes": {}
    }
    
    print("=" * 80)
    print("COMPLETE VALIDATION - All 16 Required Outcomes")
    print("=" * 80)
    
    # Connect
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = None
    try:
        sf_conn = get_snowflake_connection()
        print("✅ Snowflake connected")
    except Exception as e:
        print(f"❌ Snowflake failed: {e}")
    
    print("\n🔐 Connecting to ADX...")
    adx_client = None
    try:
        adx_client = get_adx_client()
        print("✅ ADX connected")
    except Exception as e:
        print(f"❌ ADX failed: {e}")
    
    # Validate each outcome
    for outcome_id, config in ALL_OUTCOMES.items():
        results["summary"]["total"] += 1
        source = config["source"]
        
        print(f"\n📊 [{config['outcome_id']:02d}] {config['name']}")
        print(f"   Section: {config['section']} | Source: {source}")
        
        outcome_result = {
            "outcome_id": config["outcome_id"],
            "name": config["name"],
            "section": config["section"],
            "source": source,
            "description": config["description"],
            "sensible_range": config.get("sensible_range", "N/A"),
            "query": config["query"].strip()
        }
        
        if "pi_tag" in config:
            outcome_result["pi_tag"] = config["pi_tag"]
        if "pi_tags" in config:
            outcome_result["pi_tags"] = config["pi_tags"]
        if "note" in config:
            outcome_result["note"] = config["note"]
        
        # Execute
        if source == "SNOWFLAKE" and sf_conn:
            result = run_sf_query(sf_conn, config["query"])
            outcome_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["snowflake_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 {result['sample_data'][0]}")
            else:
                results["summary"]["snowflake_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown')}")
                
        elif source == "ADX" and adx_client:
            db = config.get("database", "Morenci")
            result = run_adx_query(adx_client, db, config["query"])
            outcome_result["database"] = db
            outcome_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["adx_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 {result['sample_data'][0]}")
            else:
                results["summary"]["adx_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown')}")
        else:
            outcome_result["validation"] = {"status": "SKIPPED", "reason": "No connection"}
            print(f"   ⏭️ SKIPPED - No connection")
        
        results["outcomes"][outcome_id] = outcome_result
    
    if sf_conn:
        sf_conn.close()
    
    # Save
    output_path = Path(__file__).parent.parent.parent / "reports" / f"outcomes_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, default=str, ensure_ascii=False)
    
    # Summary
    sf_total = results["summary"]["snowflake_success"] + results["summary"]["snowflake_failed"]
    adx_total = results["summary"]["adx_success"] + results["summary"]["adx_failed"]
    
    print(f"\n\n{'='*80}")
    print("VALIDATION SUMMARY - All 16 Required Outcomes")
    print(f"{'='*80}")
    print(f"Total Outcomes: {results['summary']['total']}")
    print(f"Snowflake: {results['summary']['snowflake_success']}/{sf_total} success")
    print(f"ADX: {results['summary']['adx_success']}/{adx_total} success")
    total_success = results['summary']['snowflake_success'] + results['summary']['adx_success']
    print(f"Overall: {total_success}/{results['summary']['total']} ({total_success/results['summary']['total']*100:.1f}%)")
    print(f"\n📄 Results: {output_path}")
    print(f"{'='*80}")
    
    return results

if __name__ == "__main__":
    run_validation()
