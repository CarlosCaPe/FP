"""
=============================================================================
COMPLETE QUERY VALIDATION - ALL KPIs in Snowflake & ADX
=============================================================================
Validates EVERY query and generates complete semantic model with proof
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
    """Create Snowflake connection."""
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

def run_snowflake_query(conn, query: str, limit: int = 5) -> dict:
    """Execute Snowflake query and return results."""
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
            "sample_data": [dict(zip(columns, [str(v) for v in row])) for row in rows]
        }
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

# =============================================================================
# ADX CONNECTION
# =============================================================================
def get_adx_client():
    """Create ADX client."""
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER_URL, credential)
    return KustoClient(kcsb)

def run_adx_query(client, database: str, query: str) -> dict:
    """Execute ADX query and return results."""
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
# ALL KPI DEFINITIONS WITH QUERIES
# =============================================================================
COMPLETE_KPIS = {
    # =========================================================================
    # LOADING - SNOWFLAKE
    # =========================================================================
    "loading_dig_compliance": {
        "section": "Production Performance",
        "value_chain": "Loading",
        "metric": "Dig Compliance (%)",
        "source": "SNOWFLAKE",
        "description": "Spatial compliance of shovel dig points relative to dig zones",
        "sensible_range": "0-100%",
        "query": """
SELECT 
    site_name,
    COUNT(*) as total_dig_events,
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY site_name;
"""
    },
    
    "loading_dig_rate": {
        "section": "Production Performance",
        "value_chain": "Loading",
        "metric": "Dig Rate (TPH)",
        "source": "SNOWFLAKE",
        "description": "Total tons loaded by entire shovel fleet each hour",
        "sensible_range": "up to 99,000",
        "query": """
SELECT 
    site_name,
    SUM(measured_payload_metric_tons) as total_tons_1hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT equipment_name) as shovel_count,
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY site_name;
"""
    },
    
    "loading_priority_shovels": {
        "section": "Production Performance",
        "value_chain": "Loading",
        "metric": "Priority Shovels",
        "source": "SNOWFLAKE",
        "description": "Top 5 shovels by dig rate",
        "sensible_range": "Rate: up to 5,000 TPH per shovel",
        "query": """
SELECT 
    equipment_name as shovel_id,
    SUM(measured_payload_metric_tons) as total_tons,
    COUNT(*) as load_count,
    ROUND(SUM(measured_payload_metric_tons) / NULLIF(COUNT(*), 0), 2) as avg_payload
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY equipment_name
ORDER BY total_tons DESC
LIMIT 5;
"""
    },
    
    # =========================================================================
    # HAULAGE - SNOWFLAKE
    # =========================================================================
    "haulage_truck_count": {
        "section": "Production Performance",
        "value_chain": "Haulage",
        "metric": "Number of Trucks (qty)",
        "source": "SNOWFLAKE",
        "description": "Number of mechanically available trucks",
        "sensible_range": "100-130",
        "query": """
SELECT 
    site_name,
    COUNT(DISTINCT truck_name) as active_trucks,
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY site_name;
"""
    },
    
    "haulage_cycle_time": {
        "section": "Production Performance",
        "value_chain": "Haulage",
        "metric": "Cycle Time (min)",
        "source": "SNOWFLAKE",
        "description": "Average round trip time across truck fleet",
        "sensible_range": "35-45 min",
        "query": """
SELECT 
    site_name,
    ROUND(AVG(total_cycle_duration_calendar_mins), 2) as avg_cycle_time_mins,
    ROUND(MIN(total_cycle_duration_calendar_mins), 2) as min_cycle_time,
    ROUND(MAX(total_cycle_duration_calendar_mins), 2) as max_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT truck_name) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND total_cycle_duration_calendar_mins > 0
  AND total_cycle_duration_calendar_mins < 180
GROUP BY site_name;
"""
    },
    
    "haulage_dump_locations": {
        "section": "Production Performance",
        "value_chain": "Haulage",
        "metric": "Dump Plan Compliance",
        "source": "SNOWFLAKE",
        "description": "Material dumped by destination",
        "sensible_range": "0-100%",
        "query": """
SELECT 
    dump_loc_name,
    COUNT(*) as dump_count,
    SUM(report_payload_short_tons) as total_tons
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND dump_loc_name IS NOT NULL
GROUP BY dump_loc_name
ORDER BY total_tons DESC
LIMIT 15;
"""
    },
    
    # =========================================================================
    # LBS ON GROUND - MILL - SNOWFLAKE
    # =========================================================================
    "mill_tons_delivered": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - Tons Delivered",
        "source": "SNOWFLAKE",
        "description": "Total tons delivered to Mill",
        "sensible_range": "~108kt per shift",
        "query": """
SELECT 
    dump_loc_name,
    SUM(report_payload_short_tons) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND (dump_loc_name ILIKE '%mill%' OR dump_loc_name ILIKE '%cr2%' OR dump_loc_name ILIKE '%cr3%' OR dump_loc_name ILIKE '%crusher%')
GROUP BY dump_loc_name
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # LBS ON GROUND - MILL - ADX
    # =========================================================================
    "mill_crusher_rate_current": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - Crusher Rate (TPH) - Current",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Mill crusher processing rate - current value",
        "sensible_range": "up to 9,000 TPH",
        "query": """
database("Morenci").FCTSCURRENT()
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| project sensor_id, current_value = toreal(value), uom, timestamp
"""
    },
    
    "mill_crusher_rate_avg": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - Crusher Rate (TPH) - Rolling Avg",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Mill crusher rate - 60 min rolling average",
        "sensible_range": "up to 9,000 TPH",
        "query": """
database("Morenci").FCTS()
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| where timestamp > ago(60m)
| extend value_num = toreal(value)
| summarize 
    avg_rate = round(avg(value_num), 2),
    min_rate = round(min(value_num), 2),
    max_rate = round(max(value_num), 2),
    reading_count = count()
"""
    },
    
    "mill_crusher_rate_hourly": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - Crusher Rate (TPH) - Hourly Trend",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR03_WI00317_PV",
        "description": "Mill crusher rate - hourly trend",
        "sensible_range": "up to 9,000 TPH",
        "query": """
database("Morenci").FCTS()
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| where timestamp > ago(12h)
| extend value_num = toreal(value)
| summarize avg_rate = round(avg(value_num), 2) by bin(timestamp, 1h)
| order by timestamp desc
"""
    },
    
    "mill_ios_current": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - IOS Level - Current",
        "source": "ADX",
        "database": "Morenci",
        "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
        "description": "Mill IOS stockpile levels - current",
        "sensible_range": "0-100%",
        "query": """
database("Morenci").FCTSCURRENT()
| where sensor_id in~ ("MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV")
| extend 
    ios_name = case(
        sensor_id =~ "MOR-CC06_LI00601_PV", "Main IOS",
        sensor_id =~ "MOR-CC10_LI0102_PV", "Small IOS",
        "Unknown")
| project ios_name, sensor_id, current_level = toreal(value), uom, timestamp
| order by ios_name
"""
    },
    
    "mill_ios_with_direction": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - Mill",
        "metric": "Mill - IOS Level with Direction",
        "source": "ADX",
        "database": "Morenci",
        "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
        "description": "Mill IOS level with direction of change",
        "sensible_range": "0-100%",
        "query": """
let lookback = 1h;
database("Morenci").FCTS()
| where sensor_id in~ ("MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV")
| where timestamp > ago(lookback)
| extend value_num = toreal(value)
| order by sensor_id, timestamp asc
| serialize
| extend prev_value = prev(value_num, 1), prev_sensor = prev(sensor_id, 1)
| where sensor_id == prev_sensor
| summarize arg_max(timestamp, value_num, prev_value) by sensor_id
| extend 
    current_level = value_num,
    direction = case(
        value_num > prev_value, "INCREASING",
        value_num < prev_value, "DECREASING",
        "STABLE"),
    ios_name = case(
        sensor_id =~ "MOR-CC06_LI00601_PV", "Main IOS",
        sensor_id =~ "MOR-CC10_LI0102_PV", "Small IOS",
        "Unknown")
| project ios_name, sensor_id, current_level, direction, timestamp
"""
    },
    
    # =========================================================================
    # LBS ON GROUND - MFL - SNOWFLAKE
    # =========================================================================
    "mfl_tons_delivered": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - MFL",
        "metric": "MFL - Tons Delivered",
        "source": "SNOWFLAKE",
        "description": "Total tons delivered to MFL",
        "sensible_range": "~60kt per shift",
        "query": """
SELECT 
    dump_loc_name,
    SUM(report_payload_short_tons) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND dump_loc_name ILIKE '%mfl%'
GROUP BY dump_loc_name
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # LBS ON GROUND - MFL - ADX
    # =========================================================================
    "mfl_crusher_rate_current": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - MFL",
        "metric": "MFL - Crusher Rate (TPOH) - Current",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "MFL crushed leach processing rate",
        "sensible_range": "up to 5,000 TPH",
        "query": """
database("Morenci").FCTSCURRENT()
| where sensor_id =~ "MOR-CR02_WI01203_PV"
| project sensor_id, current_value = toreal(value), uom, timestamp
"""
    },
    
    "mfl_crusher_rate_avg": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - MFL",
        "metric": "MFL - Crusher Rate (TPOH) - Rolling Avg",
        "source": "ADX",
        "database": "Morenci",
        "pi_tag": "MOR-CR02_WI01203_PV",
        "description": "MFL crusher rate - 60 min rolling average",
        "sensible_range": "up to 5,000 TPH",
        "query": """
database("Morenci").FCTS()
| where sensor_id =~ "MOR-CR02_WI01203_PV"
| where timestamp > ago(60m)
| extend value_num = toreal(value)
| summarize 
    avg_rate = round(avg(value_num), 2),
    min_rate = round(min(value_num), 2),
    max_rate = round(max(value_num), 2),
    reading_count = count()
"""
    },
    
    # =========================================================================
    # LBS ON GROUND - ROM - SNOWFLAKE
    # =========================================================================
    "rom_tons_delivered": {
        "section": "Production Performance",
        "value_chain": "Lbs on Ground - ROM",
        "metric": "ROM - Tons Delivered",
        "source": "SNOWFLAKE",
        "description": "Total tons delivered to ROM stockpile",
        "sensible_range": "~250kt per shift",
        "query": """
SELECT 
    dump_loc_name,
    SUM(report_payload_short_tons) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND dump_loc_name ILIKE '%rom%'
GROUP BY dump_loc_name
ORDER BY total_tons DESC;
"""
    },
    
    # =========================================================================
    # SCHEMA DISCOVERY QUERIES
    # =========================================================================
    "schema_loading_cycle_columns": {
        "section": "Schema Discovery",
        "value_chain": "Loading",
        "metric": "LH_LOADING_CYCLE Columns",
        "source": "SNOWFLAKE",
        "description": "Available columns in loading cycle table",
        "query": """
SELECT column_name, data_type, is_nullable
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_LOADING_CYCLE'
ORDER BY ordinal_position
LIMIT 30;
"""
    },
    
    "schema_haul_cycle_columns": {
        "section": "Schema Discovery",
        "value_chain": "Haulage",
        "metric": "LH_HAUL_CYCLE Columns",
        "source": "SNOWFLAKE",
        "description": "Available columns in haul cycle table",
        "query": """
SELECT column_name, data_type, is_nullable
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_HAUL_CYCLE'
ORDER BY ordinal_position
LIMIT 30;
"""
    },
    
    "schema_equipment_status_columns": {
        "section": "Schema Discovery",
        "value_chain": "Haulage",
        "metric": "LH_EQUIPMENT_STATUS_EVENT Columns",
        "source": "SNOWFLAKE",
        "description": "Available columns in equipment status table",
        "query": """
SELECT column_name, data_type, is_nullable
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_EQUIPMENT_STATUS_EVENT'
ORDER BY ordinal_position
LIMIT 30;
"""
    },
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
def run_complete_validation():
    """Run ALL query validations."""
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
    
    # Connect to Snowflake
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = None
    try:
        sf_conn = get_snowflake_connection()
        print("✅ Snowflake connected")
    except Exception as e:
        print(f"❌ Snowflake connection failed: {e}")
    
    # Connect to ADX
    print("\n🔐 Connecting to ADX...")
    adx_client = None
    try:
        adx_client = get_adx_client()
        print("✅ ADX connected")
    except Exception as e:
        print(f"❌ ADX connection failed: {e}")
    
    # Process each KPI
    for kpi_id, kpi_config in COMPLETE_KPIS.items():
        results["summary"]["total_kpis"] += 1
        source = kpi_config["source"]
        
        print(f"\n📊 {kpi_config['metric']}")
        print(f"   Section: {kpi_config['section']} > {kpi_config['value_chain']}")
        print(f"   Source: {source}")
        
        kpi_result = {
            "section": kpi_config["section"],
            "value_chain": kpi_config["value_chain"],
            "metric": kpi_config["metric"],
            "source": source,
            "description": kpi_config["description"],
            "sensible_range": kpi_config.get("sensible_range", "N/A"),
            "query": kpi_config["query"].strip()
        }
        
        if "pi_tag" in kpi_config:
            kpi_result["pi_tag"] = kpi_config["pi_tag"]
        if "pi_tags" in kpi_config:
            kpi_result["pi_tags"] = kpi_config["pi_tags"]
        
        # Execute query
        if source == "SNOWFLAKE" and sf_conn:
            result = run_snowflake_query(sf_conn, kpi_config["query"])
            kpi_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["snowflake_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 Sample: {result['sample_data'][0] if result['sample_data'] else 'No data'}")
            else:
                results["summary"]["snowflake_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown error')}")
                
        elif source == "ADX" and adx_client:
            db = kpi_config.get("database", "Morenci")
            result = run_adx_query(adx_client, db, kpi_config["query"])
            kpi_result["database"] = db
            kpi_result["validation"] = result
            if result["status"] == "SUCCESS":
                results["summary"]["adx_success"] += 1
                print(f"   ✅ SUCCESS - {result['row_count']} rows")
                if result.get("sample_data"):
                    print(f"   📋 Sample: {result['sample_data'][0] if result['sample_data'] else 'No data'}")
            else:
                results["summary"]["adx_failed"] += 1
                print(f"   ❌ FAILED - {result.get('error', 'Unknown error')}")
        else:
            kpi_result["validation"] = {"status": "SKIPPED", "reason": "No connection"}
            print(f"   ⏭️ SKIPPED - No connection")
        
        results["kpis"][kpi_id] = kpi_result
    
    # Close connections
    if sf_conn:
        sf_conn.close()
    
    # Save results
    output_path = Path(__file__).parent.parent.parent / "reports" / f"complete_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, default=str, ensure_ascii=False)
    
    # Print summary
    print(f"\n\n{'='*80}")
    print("VALIDATION SUMMARY")
    print(f"{'='*80}")
    print(f"Total KPIs: {results['summary']['total_kpis']}")
    print(f"Snowflake: {results['summary']['snowflake_success']} success, {results['summary']['snowflake_failed']} failed")
    print(f"ADX: {results['summary']['adx_success']} success, {results['summary']['adx_failed']} failed")
    print(f"\n📄 Results saved to: {output_path}")
    print(f"{'='*80}")
    
    return results

if __name__ == "__main__":
    run_complete_validation()
