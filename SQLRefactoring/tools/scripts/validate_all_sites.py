"""
MULTI-SITE VALIDATION - All 16 Outcomes Across ALL Sites
Validates queries against Snowflake and ADX for every available site
Generates comprehensive sample data for semantic model enrichment
"""
import os
import sys
import json
from datetime import datetime
from typing import Dict, List, Any

# Add tools to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# =============================================================================
# SITE CONFIGURATION
# =============================================================================
SITES = {
    "MOR": {"name": "Morenci", "adx_db": "Morenci", "snowflake": True, "adx": True},
    "BAG": {"name": "Bagdad", "adx_db": "Bagdad", "snowflake": True, "adx": True},
    "SAM": {"name": "Miami", "adx_db": "Miami", "snowflake": True, "adx": True},
    "CMX": {"name": "Climax", "adx_db": "Climax", "snowflake": True, "adx": True},
    "SIE": {"name": "Sierrita", "adx_db": "Sierrita", "snowflake": True, "adx": True},
    "NMO": {"name": "NewMexico", "adx_db": "NewMexico", "snowflake": True, "adx": True},
    "CVE": {"name": "CerroVerde", "adx_db": "CerroVerde", "snowflake": True, "adx": True},
}

# =============================================================================
# PI TAG PATTERNS BY SITE
# =============================================================================
# Format: {site_code: {tag_type: tag_pattern}}
PI_TAG_PATTERNS = {
    "MOR": {
        "mill_crusher": "MOR-CR03_WI00317_PV",
        "mfl_crusher": "MOR-CR02_WI01203_PV",
        "ios_main": "MOR-CC06_LI00601_PV",
        "ios_small": "MOR-CC10_LI0102_PV",
    },
    "BAG": {
        "mill_crusher": "BAG-CR%_WI%_PV",  # Pattern - will discover
        "mfl_crusher": "BAG-CR%_WI%_PV",
        "ios_main": "BAG-CC%_LI%_PV",
        "ios_small": "BAG-CC%_LI%_PV",
    },
    "SAM": {
        "mill_crusher": "SAM-CR%_WI%_PV",
        "mfl_crusher": "SAM-CR%_WI%_PV",
        "ios_main": "SAM-CC%_LI%_PV",
        "ios_small": "SAM-CC%_LI%_PV",
    },
    "CMX": {
        "mill_crusher": "CMX-CR%_WI%_PV",
        "mfl_crusher": "CMX-CR%_WI%_PV",
        "ios_main": "CMX-CC%_LI%_PV",
        "ios_small": "CMX-CC%_LI%_PV",
    },
    "SIE": {
        "mill_crusher": "SIE-CR%_WI%_PV",
        "mfl_crusher": "SIE-CR%_WI%_PV",
        "ios_main": "SIE-CC%_LI%_PV",
        "ios_small": "SIE-CC%_LI%_PV",
    },
    "NMO": {
        "mill_crusher": "NMO-CR%_WI%_PV",
        "mfl_crusher": "NMO-CR%_WI%_PV",
        "ios_main": "NMO-CC%_LI%_PV",
        "ios_small": "NMO-CC%_LI%_PV",
    },
    "CVE": {
        "mill_crusher": "CVE-CR%_WI%_PV",
        "mfl_crusher": "CVE-CR%_WI%_PV",
        "ios_main": "CVE-CC%_LI%_PV",
        "ios_small": "CVE-CC%_LI%_PV",
    },
}

# =============================================================================
# OUTCOME TEMPLATES (Parameterized by site)
# =============================================================================
def get_snowflake_outcomes(site_code: str) -> Dict[str, Dict]:
    """Generate Snowflake outcome queries for a specific site"""
    return {
        "01_dig_compliance": {
            "name": "Dig compliance (%)",
            "section": "Loading",
            "query": f"""
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
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
        },
        "02_dig_rate": {
            "name": "Dig rate (TPOH)",
            "section": "Loading",
            "query": f"""
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
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
        },
        "03_priority_shovels": {
            "name": "Priority shovels",
            "section": "Loading",
            "query": f"""
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
  AND lc.SITE_CODE = '{site_code}'
GROUP BY e.EQUIP_NAME, lc.EXCAV_ID
ORDER BY total_tons DESC
LIMIT 5
""",
        },
        "04_truck_count": {
            "name": "Number of trucks (qty)",
            "section": "Haulage",
            "query": f"""
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
    COUNT(*) as total_cycles,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons_hauled,
    MIN(CYCLE_START_TS_LOCAL) as period_start,
    MAX(CYCLE_START_TS_LOCAL) as period_end
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
        },
        "05_cycle_time": {
            "name": "Cycle Time (min)",
            "section": "Haulage",
            "query": f"""
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
  AND SITE_CODE = '{site_code}'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE
""",
        },
        "06_asset_efficiency": {
            "name": "Asset Efficiency",
            "section": "Haulage",
            "query": f"""
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
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
        },
        "07_dump_compliance": {
            "name": "Dump plan compliance (%)",
            "section": "Haulage",
            "query": f"""
SELECT 
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS) * 100.0 / SUM(SUM(REPORT_PAYLOAD_SHORT_TONS)) OVER (), 2) as pct_of_total,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 10
""",
        },
        "08_mill_tons": {
            "name": "Mill - tons delivered",
            "section": "Lbs on Ground - Mill",
            "query": f"""
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%cr2%' OR DUMP_LOC_NAME ILIKE '%cr3%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
        },
        "12_mfl_tons": {
            "name": "MFL - tons delivered",
            "section": "Lbs on Ground - MFL",
            "query": f"""
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
        },
        "16_rom_tons": {
            "name": "ROM - tons delivered",
            "section": "Lbs on Ground - ROM",
            "query": f"""
SELECT 
    DUMP_LOC_NAME,
    SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons,
    COUNT(*) as dump_count,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    MIN(CYCLE_START_TS_LOCAL) as first_dump,
    MAX(CYCLE_START_TS_LOCAL) as last_dump
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
        },
    }


def get_adx_outcomes(site_code: str, adx_db: str) -> Dict[str, Dict]:
    """Generate ADX outcome queries for a specific site - DISCOVERY MODE"""
    return {
        "09_mill_crusher": {
            "name": "Mill - Crusher Rate (TPOH)",
            "section": "Lbs on Ground - Mill",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'CR' and sensor_id contains 'WI'
| where todouble(value) > 100
| project sensor_id, value=todouble(value), timestamp, uom, quality, data_source
| order by value desc
| take 10
""",
        },
        "10_mill_rate": {
            "name": "Mill - Mill Rate (TPOH)",
            "section": "Lbs on Ground - Mill",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'CR' and sensor_id contains 'WI'
| where todouble(value) > 100
| project sensor_id, rate_tph=todouble(value), timestamp, data_source
| order by rate_tph desc
| take 5
""",
        },
        "11_mill_strategy": {
            "name": "Mill - Strategy compliance",
            "section": "Lbs on Ground - Mill",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'CC'
| where todouble(value) > 0 and todouble(value) < 100
| project sensor_id, level_pct=todouble(value), timestamp, quality, data_source
| order by level_pct desc
| take 10
""",
        },
        "13_mfl_crusher": {
            "name": "MFL - Crusher Rate (TPOH)",
            "section": "Lbs on Ground - MFL",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'CR' and sensor_id contains 'WI'
| where todouble(value) > 100
| project sensor_id, value=todouble(value), timestamp, uom, quality, data_source
| order by value desc
| take 5
""",
        },
        "14_mfl_fos": {
            "name": "MFL - FOS Rate (TPOH)",
            "section": "Lbs on Ground - MFL",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'FOS'
| where todouble(value) > 100
| project sensor_id, rate_tph=todouble(value), timestamp, data_source
| order by rate_tph desc
| take 5
""",
        },
        "15_mfl_strategy": {
            "name": "MFL - Strategy compliance",
            "section": "Lbs on Ground - MFL",
            "query": f"""
FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'LI'
| where todouble(value) > 0
| project sensor_id, value=todouble(value), timestamp, quality, data_source
| order by value desc
| take 5
""",
        },
    }


def get_adx_sensor_discovery_query(adx_db: str) -> str:
    """Query to discover available sensors in a site's ADX database"""
    return """
FCTSCURRENT()
| summarize 
    sensor_count = count(),
    sample_sensors = make_list(sensor_id, 20)
| project sensor_count, sample_sensors
"""


# =============================================================================
# CONNECTIONS
# =============================================================================

def connect_snowflake():
    """Connect to Snowflake"""
    import snowflake.connector
    
    conn = snowflake.connector.connect(
        account='FCX-NA',
        authenticator='externalbrowser',
        user='ccarrill2@fmi.com',
        warehouse='WH_PROD_WG_DATENG',
        database='PROD_WG',
        schema='LOAD_HAUL'
    )
    return conn


def connect_adx():
    """Connect to ADX"""
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
    client = KustoClient(kcsb)
    return client


def run_snowflake_query(conn, query: str) -> List[Dict]:
    """Execute Snowflake query and return results"""
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
        cursor.close()
        
        results = []
        for row in rows:
            results.append({col: str(val) if val is not None else None for col, val in zip(columns, row)})
        return results
    except Exception as e:
        return [{"error": str(e)}]


def run_adx_query(client, database: str, query: str) -> List[Dict]:
    """Execute ADX query and return results"""
    try:
        response = client.execute(database, query)
        primary = response.primary_results[0]
        columns = [col.column_name for col in primary.columns]
        
        results = []
        for row in primary.rows:
            results.append({col: str(row[i]) if row[i] is not None else None for i, col in enumerate(columns)})
        return results
    except Exception as e:
        return [{"error": str(e)}]


# =============================================================================
# MAIN VALIDATION
# =============================================================================

def validate_all_sites():
    """Run validation across ALL sites"""
    print("=" * 80)
    print("MULTI-SITE VALIDATION - All 16 Outcomes Across ALL Sites")
    print("=" * 80)
    print(f"Sites to validate: {', '.join(SITES.keys())}")
    print()
    
    # Connect to data sources
    print("🔐 Connecting to Snowflake...")
    sf_conn = connect_snowflake()
    print("✅ Snowflake connected")
    
    print("🔐 Connecting to ADX...")
    adx_client = connect_adx()
    print("✅ ADX connected")
    
    # Results structure
    all_results = {
        "validation_timestamp": datetime.now().isoformat(),
        "sites": {}
    }
    
    # Process each site
    for site_code, site_config in SITES.items():
        print()
        print("=" * 80)
        print(f"📍 SITE: {site_config['name']} ({site_code})")
        print("=" * 80)
        
        site_results = {
            "name": site_config['name'],
            "snowflake_outcomes": {},
            "adx_outcomes": {},
            "adx_sensors_discovered": [],
            "summary": {"snowflake_success": 0, "snowflake_total": 0, "adx_success": 0, "adx_total": 0}
        }
        
        # ===== SNOWFLAKE OUTCOMES =====
        print(f"\n📊 Snowflake Outcomes for {site_code}:")
        snowflake_outcomes = get_snowflake_outcomes(site_code)
        
        for outcome_id, outcome in snowflake_outcomes.items():
            site_results["summary"]["snowflake_total"] += 1
            try:
                results = run_snowflake_query(sf_conn, outcome["query"])
                has_data = len(results) > 0 and "error" not in results[0]
                
                if has_data:
                    site_results["summary"]["snowflake_success"] += 1
                    status = "✅"
                else:
                    status = "⚠️"
                
                site_results["snowflake_outcomes"][outcome_id] = {
                    "name": outcome["name"],
                    "section": outcome["section"],
                    "status": "SUCCESS" if has_data else "NO_DATA",
                    "row_count": len(results) if has_data else 0,
                    "sample_data": results[:3] if has_data else [],
                    "query": outcome["query"].strip()
                }
                
                print(f"   {status} [{outcome_id}] {outcome['name']}: {len(results)} rows")
                
            except Exception as e:
                site_results["snowflake_outcomes"][outcome_id] = {
                    "name": outcome["name"],
                    "status": "ERROR",
                    "error": str(e)
                }
                print(f"   ❌ [{outcome_id}] {outcome['name']}: ERROR - {str(e)[:50]}")
        
        # ===== ADX OUTCOMES =====
        print(f"\n📊 ADX Outcomes for {site_code} (database: {site_config['adx_db']}):")
        
        # First, discover sensors
        try:
            discovery_results = run_adx_query(adx_client, site_config['adx_db'], get_adx_sensor_discovery_query(site_config['adx_db']))
            if discovery_results and "error" not in discovery_results[0]:
                site_results["adx_sensors_discovered"] = discovery_results[0].get("sample_sensors", [])
                sensor_count = discovery_results[0].get("sensor_count", 0)
                print(f"   🔍 Discovered {sensor_count} sensors in {site_config['adx_db']}")
        except Exception as e:
            print(f"   ⚠️ Sensor discovery failed: {str(e)[:50]}")
        
        adx_outcomes = get_adx_outcomes(site_code, site_config['adx_db'])
        
        for outcome_id, outcome in adx_outcomes.items():
            site_results["summary"]["adx_total"] += 1
            try:
                results = run_adx_query(adx_client, site_config['adx_db'], outcome["query"])
                has_data = len(results) > 0 and "error" not in results[0]
                
                if has_data:
                    site_results["summary"]["adx_success"] += 1
                    status = "✅"
                else:
                    status = "⚠️"
                
                site_results["adx_outcomes"][outcome_id] = {
                    "name": outcome["name"],
                    "section": outcome["section"],
                    "status": "SUCCESS" if has_data else "NO_DATA",
                    "row_count": len(results) if has_data else 0,
                    "sample_data": results[:5] if has_data else [],
                    "query": outcome["query"].strip()
                }
                
                print(f"   {status} [{outcome_id}] {outcome['name']}: {len(results)} rows")
                if has_data and results:
                    first_row = results[0]
                    if 'sensor_id' in first_row:
                        print(f"      → Sample sensor: {first_row.get('sensor_id', 'N/A')}")
                
            except Exception as e:
                site_results["adx_outcomes"][outcome_id] = {
                    "name": outcome["name"],
                    "status": "ERROR",
                    "error": str(e)
                }
                print(f"   ❌ [{outcome_id}] {outcome['name']}: ERROR - {str(e)[:50]}")
        
        # Site summary
        sf_rate = (site_results["summary"]["snowflake_success"] / site_results["summary"]["snowflake_total"] * 100) if site_results["summary"]["snowflake_total"] > 0 else 0
        adx_rate = (site_results["summary"]["adx_success"] / site_results["summary"]["adx_total"] * 100) if site_results["summary"]["adx_total"] > 0 else 0
        
        print(f"\n   📈 {site_code} Summary: Snowflake {site_results['summary']['snowflake_success']}/{site_results['summary']['snowflake_total']} ({sf_rate:.0f}%) | ADX {site_results['summary']['adx_success']}/{site_results['summary']['adx_total']} ({adx_rate:.0f}%)")
        
        all_results["sites"][site_code] = site_results
    
    # Close connections
    sf_conn.close()
    
    # ===== OVERALL SUMMARY =====
    print()
    print("=" * 80)
    print("OVERALL VALIDATION SUMMARY")
    print("=" * 80)
    
    total_sf_success = sum(s["summary"]["snowflake_success"] for s in all_results["sites"].values())
    total_sf = sum(s["summary"]["snowflake_total"] for s in all_results["sites"].values())
    total_adx_success = sum(s["summary"]["adx_success"] for s in all_results["sites"].values())
    total_adx = sum(s["summary"]["adx_total"] for s in all_results["sites"].values())
    
    print(f"Sites Validated: {len(all_results['sites'])}")
    print(f"Snowflake: {total_sf_success}/{total_sf} outcomes with data")
    print(f"ADX: {total_adx_success}/{total_adx} outcomes with data")
    print()
    
    for site_code, site_data in all_results["sites"].items():
        sf_s = site_data["summary"]["snowflake_success"]
        sf_t = site_data["summary"]["snowflake_total"]
        adx_s = site_data["summary"]["adx_success"]
        adx_t = site_data["summary"]["adx_total"]
        print(f"  {site_code}: SF {sf_s}/{sf_t} | ADX {adx_s}/{adx_t}")
    
    # Save results
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"reports/all_sites_validation_{timestamp}.json"
    os.makedirs("reports", exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_results, f, indent=2, default=str)
    
    print()
    print(f"📄 Full results saved to: {output_file}")
    print("=" * 80)
    
    return all_results, output_file


if __name__ == "__main__":
    validate_all_sites()
