"""
COMPLETE MULTI-SITE VALIDATION - All 16 Outcomes, All 7 Sites
Fixed warehouse issue - uses available warehouse
Generates comprehensive sample data for the global semantic model
"""
import os
import json
from datetime import datetime
from typing import Dict, List, Any

# =============================================================================
# CONFIGURATION
# =============================================================================
SITES = ["MOR", "BAG", "SAM", "CMX", "SIE", "NMO", "CVE"]

SITE_NAMES = {
    "MOR": "Morenci",
    "BAG": "Bagdad", 
    "SAM": "Miami",
    "CMX": "Climax",
    "SIE": "Sierrita",
    "NMO": "NewMexico",
    "CVE": "CerroVerde"
}

ADX_DATABASES = {
    "MOR": "Morenci",
    "BAG": "Bagdad",
    "SAM": "Miami", 
    "CMX": "Climax",
    "SIE": "Sierrita",
    "NMO": "NewMexico",
    "CVE": "CerroVerde"
}

# =============================================================================
# SNOWFLAKE QUERIES - Parameterized by site
# =============================================================================
SNOWFLAKE_OUTCOMES = {
    "01_dig_compliance": {
        "name": "Dig compliance (%)",
        "section": "Loading",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(*) as total_dig_events,
    COUNT(DISTINCT LOADING_LOC_ID) as unique_dig_locations,
    COUNT(DISTINCT EXCAV_ID) as active_shovels,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as avg_dig_elevation_ft
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE
"""
    },
    "02_dig_rate": {
        "name": "Dig rate (TPOH)",
        "section": "Loading",
        "query": """
SELECT 
    SITE_CODE,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS), 2) as total_tons_24hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT EXCAV_ID) as shovel_count,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / NULLIF(COUNT(DISTINCT EXCAV_ID), 0), 2) as avg_tons_per_shovel
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE
"""
    },
    "03_priority_shovels": {
        "name": "Priority shovels",
        "section": "Loading",
        "query": """
SELECT 
    e.EQUIP_NAME as shovel_name,
    lc.SITE_CODE,
    SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count,
    ROUND(AVG(lc.MEASURED_PAYLOAD_METRIC_TONS), 2) as avg_payload_tons
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE lc
LEFT JOIN PROD_WG.LOAD_HAUL.LH_EQUIPMENT e 
    ON lc.EXCAV_ID = e.EQUIP_ID AND lc.SITE_CODE = e.SITE_CODE
WHERE lc.CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND lc.SITE_CODE = '{site}'
GROUP BY e.EQUIP_NAME, lc.SITE_CODE
ORDER BY total_tons DESC
LIMIT 5
"""
    },
    "04_truck_count": {
        "name": "Number of trucks (qty)",
        "section": "Haulage",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons_hauled
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE
"""
    },
    "05_cycle_time": {
        "name": "Cycle Time (min)",
        "section": "Haulage",
        "query": """
SELECT 
    SITE_CODE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as min_cycle_time,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as max_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT TRUCK_ID) as truck_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE
"""
    },
    "06_asset_efficiency": {
        "name": "Asset Efficiency",
        "section": "Haulage",
        "query": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_payload_tons,
    ROUND(AVG(REPORT_PAYLOAD_SHORT_TONS), 2) as avg_payload_per_cycle,
    ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as cycles_per_truck
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE
"""
    },
    "07_dump_compliance": {
        "name": "Dump plan compliance (%)",
        "section": "Haulage",
        "query": """
SELECT 
    SITE_CODE,
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY SITE_CODE, DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 5
"""
    },
    "08_mill_tons": {
        "name": "Mill - tons delivered",
        "section": "Lbs on Ground - Mill",
        "query": """
SELECT 
    SITE_CODE,
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY SITE_CODE, DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
    "12_mfl_tons": {
        "name": "MFL - tons delivered",
        "section": "Lbs on Ground - MFL",
        "query": """
SELECT 
    SITE_CODE,
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY SITE_CODE, DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
    "16_rom_tons": {
        "name": "ROM - tons delivered",
        "section": "Lbs on Ground - ROM",
        "query": """
SELECT 
    SITE_CODE,
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY SITE_CODE, DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
}

# =============================================================================
# ADX QUERIES - Per site database
# =============================================================================
ADX_OUTCOMES = {
    "09_mill_crusher": {
        "name": "Mill - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'CR' and (sensor_id contains 'WI' or sensor_id contains 'TPH')
| where todouble(value) > 100
| project sensor_id, value=todouble(value), timestamp, uom, quality
| order by value desc
| take 5
"""
    },
    "10_mill_rate": {
        "name": "Mill - Mill Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'MILL'
| where todouble(value) > 50
| project sensor_id, rate_tph=todouble(value), timestamp
| order by rate_tph desc
| take 5
"""
    },
    "11_mill_strategy": {
        "name": "Mill - Strategy compliance",
        "section": "Lbs on Ground - Mill",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'CC' or sensor_id contains 'IOS'
| where todouble(value) > 0 and todouble(value) < 100
| project sensor_id, level_pct=todouble(value), timestamp, quality
| order by level_pct desc
| take 5
"""
    },
    "13_mfl_crusher": {
        "name": "MFL - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'CR' and sensor_id contains 'WI'
| where todouble(value) > 100
| project sensor_id, value=todouble(value), timestamp, uom
| order by value desc
| take 3
"""
    },
    "14_mfl_fos": {
        "name": "MFL - FOS Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'FOS' or sensor_id contains 'LEACH'
| where todouble(value) > 50
| project sensor_id, rate_tph=todouble(value), timestamp
| order by rate_tph desc
| take 5
"""
    },
    "15_mfl_strategy": {
        "name": "MFL - Strategy compliance",
        "section": "Lbs on Ground - MFL",
        "query": """
FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'CR'
| where todouble(value) > 0
| project sensor_id, value=todouble(value), timestamp, quality
| order by value desc
| take 5
"""
    },
}


def connect_snowflake():
    """Connect to Snowflake with working warehouse"""
    import snowflake.connector
    
    conn = snowflake.connector.connect(
        account='FCX-NA',
        authenticator='externalbrowser',
        user='ccarrill2@fmi.com'
    )
    cursor = conn.cursor()
    # Use a warehouse that works
    cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
    cursor.close()
    return conn


def connect_adx():
    """Connect to ADX"""
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
    return KustoClient(kcsb)


def run_snowflake_query(conn, query: str) -> List[Dict]:
    """Execute Snowflake query"""
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
        cursor.close()
        return [{col: str(val) if val is not None else None for col, val in zip(columns, row)} for row in rows]
    except Exception as e:
        return [{"error": str(e)}]


def run_adx_query(client, database: str, query: str) -> List[Dict]:
    """Execute ADX query"""
    try:
        response = client.execute(database, query)
        primary = response.primary_results[0]
        columns = [col.column_name for col in primary.columns]
        return [{col: str(row[i]) if row[i] is not None else None for i, col in enumerate(columns)} for row in primary.rows]
    except Exception as e:
        return [{"error": str(e)}]


def main():
    print("=" * 80)
    print("COMPLETE MULTI-SITE VALIDATION")
    print("All 16 Outcomes × All 7 Sites")
    print("=" * 80)
    
    # Connect
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = connect_snowflake()
    print("✅ Snowflake connected (using WH_BATCH_DE_NONPROD)")
    
    print("🔐 Connecting to ADX...")
    adx_client = connect_adx()
    print("✅ ADX connected")
    
    # Results
    all_results = {
        "validation_timestamp": datetime.now().isoformat(),
        "sites": {}
    }
    
    # Process each site
    for site in SITES:
        print(f"\n{'='*80}")
        print(f"📍 SITE: {SITE_NAMES[site]} ({site})")
        print("="*80)
        
        site_results = {
            "name": SITE_NAMES[site],
            "snowflake": {"success": 0, "total": 0, "outcomes": {}},
            "adx": {"success": 0, "total": 0, "outcomes": {}, "database": ADX_DATABASES[site]}
        }
        
        # SNOWFLAKE
        print(f"\n📊 Snowflake Outcomes:")
        for outcome_id, outcome in SNOWFLAKE_OUTCOMES.items():
            site_results["snowflake"]["total"] += 1
            query = outcome["query"].format(site=site)
            results = run_snowflake_query(sf_conn, query)
            has_data = len(results) > 0 and "error" not in results[0]
            
            if has_data:
                site_results["snowflake"]["success"] += 1
                status = "✅"
            else:
                status = "⚠️"
            
            site_results["snowflake"]["outcomes"][outcome_id] = {
                "name": outcome["name"],
                "status": "SUCCESS" if has_data else "NO_DATA",
                "row_count": len(results) if has_data else 0,
                "sample_data": results[:3] if has_data else []
            }
            
            # Print summary
            if has_data and results:
                sample = results[0]
                key_value = next((v for k, v in sample.items() if 'TONS' in k.upper() or 'COUNT' in k.upper() or 'TRUCKS' in k.upper()), f"{len(results)} rows")
                print(f"   {status} {outcome['name']}: {key_value}")
            else:
                print(f"   {status} {outcome['name']}: no data")
        
        # ADX
        print(f"\n📊 ADX Outcomes (database: {ADX_DATABASES[site]}):")
        for outcome_id, outcome in ADX_OUTCOMES.items():
            site_results["adx"]["total"] += 1
            results = run_adx_query(adx_client, ADX_DATABASES[site], outcome["query"])
            has_data = len(results) > 0 and "error" not in results[0]
            
            if has_data:
                site_results["adx"]["success"] += 1
                status = "✅"
            else:
                status = "⚠️"
            
            site_results["adx"]["outcomes"][outcome_id] = {
                "name": outcome["name"],
                "status": "SUCCESS" if has_data else "NO_DATA",
                "row_count": len(results) if has_data else 0,
                "sample_data": results[:3] if has_data else []
            }
            
            if has_data and results:
                sensor = results[0].get('sensor_id', 'N/A')[:40]
                print(f"   {status} {outcome['name']}: {sensor}...")
            else:
                print(f"   {status} {outcome['name']}: no data")
        
        # Site summary
        sf_pct = (site_results["snowflake"]["success"] / site_results["snowflake"]["total"] * 100)
        adx_pct = (site_results["adx"]["success"] / site_results["adx"]["total"] * 100)
        print(f"\n   📈 {site} Summary: SF {site_results['snowflake']['success']}/{site_results['snowflake']['total']} ({sf_pct:.0f}%) | ADX {site_results['adx']['success']}/{site_results['adx']['total']} ({adx_pct:.0f}%)")
        
        all_results["sites"][site] = site_results
    
    sf_conn.close()
    
    # OVERALL SUMMARY
    print("\n" + "="*80)
    print("OVERALL VALIDATION SUMMARY")
    print("="*80)
    
    total_sf_success = sum(s["snowflake"]["success"] for s in all_results["sites"].values())
    total_sf = sum(s["snowflake"]["total"] for s in all_results["sites"].values())
    total_adx_success = sum(s["adx"]["success"] for s in all_results["sites"].values())
    total_adx = sum(s["adx"]["total"] for s in all_results["sites"].values())
    
    print(f"\nSnowflake: {total_sf_success}/{total_sf} ({total_sf_success/total_sf*100:.1f}%)")
    print(f"ADX: {total_adx_success}/{total_adx} ({total_adx_success/total_adx*100:.1f}%)")
    print(f"Total: {total_sf_success + total_adx_success}/{total_sf + total_adx}")
    
    print("\nBy Site:")
    for site, data in all_results["sites"].items():
        sf = f"{data['snowflake']['success']}/{data['snowflake']['total']}"
        adx = f"{data['adx']['success']}/{data['adx']['total']}"
        print(f"  {site} ({data['name']}): SF {sf} | ADX {adx}")
    
    # Save
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"reports/complete_validation_{timestamp}.json"
    os.makedirs("reports", exist_ok=True)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_results, f, indent=2, default=str)
    
    print(f"\n📄 Results saved to: {output_file}")
    print("="*80)
    
    return all_results, output_file


if __name__ == "__main__":
    main()
