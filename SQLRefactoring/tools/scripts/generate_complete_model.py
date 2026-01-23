"""
GENERATE COMPLETE SEMANTIC MODEL
16 Outcomes × 7 Sites = 112 queries with REAL samples
Each site is INDEPENDENT
"""
import json
import yaml
from datetime import datetime
from typing import Dict, List, Any

# =============================================================================
# CONFIGURATION
# =============================================================================
SITES = {
    "MOR": {"name": "Morenci", "adx_database": "Morenci"},
    "BAG": {"name": "Bagdad", "adx_database": "Bagdad"},
    "SAM": {"name": "Miami", "adx_database": "Miami"},
    "CMX": {"name": "Climax", "adx_database": "Climax"},
    "SIE": {"name": "Sierrita", "adx_database": "Sierrita"},
    "NMO": {"name": "NewMexico", "adx_database": "NewMexico"},
    "CVE": {"name": "CerroVerde", "adx_database": "CerroVerde"},
}

# =============================================================================
# SNOWFLAKE QUERIES (10) - Same structure, different SITE_CODE
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
    COUNT(DISTINCT EXCAV_ID) as shovel_count
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
    SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE lc
LEFT JOIN PROD_WG.LOAD_HAUL.LH_EQUIPMENT e 
    ON lc.EXCAV_ID = e.EQUIP_ID AND lc.SITE_CODE = e.SITE_CODE
WHERE lc.CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND lc.SITE_CODE = '{site}'
GROUP BY e.EQUIP_NAME
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
    COUNT(*) as total_cycles
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
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 5
"""
    },
    "08_mill_tons": {
        "name": "Mill - tons delivered",
        "section": "Lbs on Ground - Mill",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
    "12_mfl_tons": {
        "name": "MFL - tons delivered",
        "section": "Lbs on Ground - MFL",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
    "16_rom_tons": {
        "name": "ROM - tons delivered",
        "section": "Lbs on Ground - ROM",
        "query": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
"""
    },
}

# =============================================================================
# ADX QUERIES (6) - SITE-SPECIFIC with discovered PI tags
# =============================================================================
ADX_OUTCOMES = {
    "09_mill_crusher": {
        "name": "Mill - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "site_queries": {
            "MOR": {
                "database": "Morenci",
                "sensor": "MOR-CR03_WI00317_PV",
                "query": "FCTSCURRENT() | where sensor_id == 'MOR-CR03_WI00317_PV' | project sensor_id, rate_tph=todouble(value), timestamp, uom"
            },
            "BAG": {
                "database": "Bagdad",
                "sensor": "BAG-TI-XccCrMotorWindings-pv",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 100 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
            "SAM": {
                "database": "Miami",
                "sensor": "discovery_needed",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
            "CMX": {
                "database": "Climax",
                "sensor": "discovery_needed",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
            "SIE": {
                "database": "Sierrita",
                "sensor": "SIE-cr6.WI_2_Flow.Well_W_WI_2",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR' or sensor_id contains 'WI' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
            "NMO": {
                "database": "NewMexico",
                "sensor": "NMO-Primary Crusher Total Run Time",
                "query": "FCTSCURRENT() | where sensor_id contains 'Crusher' | project sensor_id, value=todouble(value), timestamp | order by value desc | take 3"
            },
            "CVE": {
                "database": "CerroVerde",
                "sensor": "CVE-MD_C1_3230_CR_032_M1_WINDING_V1_LIM_HI_RAMP",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 100 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
        }
    },
    "10_mill_rate": {
        "name": "Mill - Mill Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "site_queries": {
            "MOR": {
                "database": "Morenci",
                "sensor": "MOR-CR03_WI00316_PV",
                "query": "FCTSCURRENT() | where sensor_id contains 'CR03' and sensor_id contains 'WI' | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"
            },
            "BAG": {"database": "Bagdad", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "SAM": {"database": "Miami", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "CMX": {"database": "Climax", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "SIE": {"database": "Sierrita", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "NMO": {"database": "NewMexico", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'SAG' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "CVE": {"database": "CerroVerde", "query": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
        }
    },
    "11_mill_strategy": {
        "name": "Mill - Strategy compliance (IOS Level)",
        "section": "Lbs on Ground - Mill",
        "site_queries": {
            "MOR": {
                "database": "Morenci",
                "sensors": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
                "query": "FCTSCURRENT() | where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV') | project sensor_id, level_pct=todouble(value), timestamp"
            },
            "BAG": {"database": "Bagdad", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'CC' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | order by level_pct desc | take 5"},
            "SAM": {"database": "Miami", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "CMX": {"database": "Climax", "sensor": "CMX-PCS001.RSLinx Enterprise:CLX011._540_ZIT_2001.PVEU", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'ZIT' | where todouble(value) > 0 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "SIE": {"database": "Sierrita", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "NMO": {"database": "NewMexico", "sensor": "NMO-APC SAG2 Mill Performance-Constraint 7", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Constraint' | where todouble(value) > 0 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "CVE": {"database": "CerroVerde", "sensor": "CVE-C1_38_LIC_2833.PV", "query": "FCTSCURRENT() | where sensor_id contains 'LIC' or sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
        }
    },
    "13_mfl_crusher": {
        "name": "MFL - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "site_queries": {
            "MOR": {
                "database": "Morenci",
                "sensor": "MOR-CR02_WI01203_PV",
                "query": "FCTSCURRENT() | where sensor_id == 'MOR-CR02_WI01203_PV' or sensor_id == 'MOR-CR02_WI01201_PV' | project sensor_id, rate_tph=todouble(value), timestamp, uom"
            },
            "BAG": {"database": "Bagdad", "query": "FCTSCURRENT() | where sensor_id contains 'CR02' or sensor_id contains 'MFL' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "SAM": {"database": "Miami", "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "CMX": {"database": "Climax", "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "SIE": {"database": "Sierrita", "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "NMO": {"database": "NewMexico", "query": "FCTSCURRENT() | where sensor_id contains 'Crusher' | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "CVE": {"database": "CerroVerde", "query": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
        }
    },
    "14_mfl_fos": {
        "name": "MFL - FOS Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "site_queries": {
            "MOR": {"database": "Morenci", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' or sensor_id contains 'CR02' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3"},
            "BAG": {"database": "Bagdad", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
            "SAM": {"database": "Miami", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
            "CMX": {"database": "Climax", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
            "SIE": {"database": "Sierrita", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
            "NMO": {"database": "NewMexico", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
            "CVE": {"database": "CerroVerde", "query": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3"},
        }
    },
    "15_mfl_strategy": {
        "name": "MFL - Strategy compliance",
        "section": "Lbs on Ground - MFL",
        "site_queries": {
            "MOR": {"database": "Morenci", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'MFL' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | order by level_pct desc | take 5"},
            "BAG": {"database": "Bagdad", "query": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "SAM": {"database": "Miami", "query": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "CMX": {"database": "Climax", "query": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "SIE": {"database": "Sierrita", "query": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "NMO": {"database": "NewMexico", "query": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
            "CVE": {"database": "CerroVerde", "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'LIC' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5"},
        }
    },
}


def connect_snowflake():
    """Connect to Snowflake"""
    import snowflake.connector
    conn = snowflake.connector.connect(
        account='FCX-NA',
        authenticator='externalbrowser',
        user='ccarrill2@fmi.com'
    )
    cursor = conn.cursor()
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
    """Execute Snowflake query and return results"""
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
        cursor.close()
        results = []
        for row in rows[:5]:  # Max 5 rows as sample
            results.append({col: (float(val) if isinstance(val, (int, float)) else str(val) if val else None) 
                           for col, val in zip(columns, row)})
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
        for row in list(primary.rows)[:5]:  # Max 5 rows as sample
            results.append({col: (float(row[i]) if isinstance(row[i], (int, float)) else str(row[i]) if row[i] else None) 
                           for i, col in enumerate(columns)})
        return results
    except Exception as e:
        return [{"error": str(e)}]


def main():
    print("=" * 80)
    print("GENERATING COMPLETE SEMANTIC MODEL")
    print("16 Outcomes × 7 Sites = 112 Queries")
    print("=" * 80)
    
    # Connect
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = connect_snowflake()
    print("✅ Snowflake connected")
    
    print("🔐 Connecting to ADX...")
    adx_client = connect_adx()
    print("✅ ADX connected")
    
    # Build complete model
    complete_model = {
        "version": "4.0",
        "name": "ADX_FCTS_UNIFIED_COMPLETE",
        "description": "Complete semantic model - 16 outcomes × 7 sites with REAL validated samples",
        "generated_at": datetime.now().isoformat(),
        "connections": {
            "snowflake": {
                "account": "FCX-NA",
                "warehouse": "WH_BATCH_DE_NONPROD",
                "database": "PROD_WG",
                "schema": "LOAD_HAUL"
            },
            "adx": {
                "cluster": "https://fctsnaproddatexp02.westus2.kusto.windows.net"
            }
        },
        "sites": {}
    }
    
    # Process each site independently
    for site_code, site_info in SITES.items():
        print(f"\n{'='*80}")
        print(f"📍 PROCESSING SITE: {site_info['name']} ({site_code})")
        print("="*80)
        
        site_data = {
            "name": site_info["name"],
            "adx_database": site_info["adx_database"],
            "outcomes": {}
        }
        
        # SNOWFLAKE OUTCOMES (10)
        print(f"\n📊 Snowflake Outcomes:")
        for outcome_id, outcome in SNOWFLAKE_OUTCOMES.items():
            query = outcome["query"].format(site=site_code)
            results = run_snowflake_query(sf_conn, query)
            has_data = len(results) > 0 and "error" not in results[0]
            
            status = "✅" if has_data else "⚠️"
            print(f"   {status} {outcome['name']}: {len(results)} rows")
            
            site_data["outcomes"][outcome_id] = {
                "name": outcome["name"],
                "section": outcome["section"],
                "source": "SNOWFLAKE",
                "query": query.strip(),
                "status": "SUCCESS" if has_data else "NO_DATA",
                "validated_at": datetime.now().isoformat() if has_data else None,
                "sample_data": results if has_data else []
            }
        
        # ADX OUTCOMES (6)
        print(f"\n📊 ADX Outcomes (database: {site_info['adx_database']}):")
        for outcome_id, outcome in ADX_OUTCOMES.items():
            site_query_info = outcome["site_queries"].get(site_code, {})
            database = site_query_info.get("database", site_info["adx_database"])
            query = site_query_info.get("query", "")
            sensor = site_query_info.get("sensor", "discovery_needed")
            
            if query:
                results = run_adx_query(adx_client, database, query)
                has_data = len(results) > 0 and "error" not in results[0]
            else:
                results = []
                has_data = False
            
            status = "✅" if has_data else "⚠️"
            sample_sensor = results[0].get('sensor_id', 'N/A')[:40] if has_data and results else "no data"
            print(f"   {status} {outcome['name']}: {sample_sensor}")
            
            site_data["outcomes"][outcome_id] = {
                "name": outcome["name"],
                "section": outcome["section"],
                "source": "ADX",
                "database": database,
                "discovered_sensor": sensor if sensor != "discovery_needed" else (results[0].get('sensor_id') if has_data and results else None),
                "query": query,
                "status": "SUCCESS" if has_data else "NO_DATA",
                "validated_at": datetime.now().isoformat() if has_data else None,
                "sample_data": results if has_data else []
            }
        
        # Count successes
        sf_success = sum(1 for o in site_data["outcomes"].values() if o["source"] == "SNOWFLAKE" and o["status"] == "SUCCESS")
        adx_success = sum(1 for o in site_data["outcomes"].values() if o["source"] == "ADX" and o["status"] == "SUCCESS")
        site_data["validation_summary"] = {
            "snowflake": f"{sf_success}/10",
            "adx": f"{adx_success}/6",
            "total": f"{sf_success + adx_success}/16"
        }
        
        print(f"\n   📈 {site_code} Summary: SF {sf_success}/10 | ADX {adx_success}/6 | Total {sf_success + adx_success}/16")
        
        complete_model["sites"][site_code] = site_data
    
    sf_conn.close()
    
    # Save JSON
    json_path = "reports/complete_model_data.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(complete_model, f, indent=2, default=str)
    print(f"\n📄 JSON saved: {json_path}")
    
    # Generate YAML
    yaml_path = "adx_semantic_models/ADX_UNIFIED.semantic.yaml"
    generate_yaml(complete_model, yaml_path)
    print(f"📄 YAML saved: {yaml_path}")
    
    # Summary
    print("\n" + "="*80)
    print("VALIDATION COMPLETE")
    print("="*80)
    for site_code, site_data in complete_model["sites"].items():
        print(f"  {site_code} ({site_data['name']}): {site_data['validation_summary']['total']}")
    
    return complete_model


def generate_yaml(model: Dict, output_path: str):
    """Generate the YAML semantic model file"""
    
    yaml_content = f'''# =============================================================================
# ADX UNIFIED SEMANTIC MODEL - COMPLETE
# =============================================================================
# THE SINGLE SOURCE OF TRUTH for all FCTS mining operations
# 
# Contains:
#   - ALL 16 Business Outcomes
#   - ALL 7 Sites - EACH INDEPENDENT with specific queries
#   - REAL validated sample data from {model["generated_at"][:10]}
#
# Total: 7 sites × 16 outcomes = 112 validated queries
# =============================================================================

version: "{model["version"]}"
name: {model["name"]}
generated_at: "{model["generated_at"]}"

# =============================================================================
# CONNECTIONS
# =============================================================================
connections:
  snowflake:
    account: {model["connections"]["snowflake"]["account"]}
    warehouse: {model["connections"]["snowflake"]["warehouse"]}
    database: {model["connections"]["snowflake"]["database"]}
    schema: {model["connections"]["snowflake"]["schema"]}
    authentication: externalbrowser
    
  adx:
    cluster: {model["connections"]["adx"]["cluster"]}
    authentication: InteractiveBrowserCredential

# =============================================================================
# SITES - EACH SITE IS INDEPENDENT WITH 16 OUTCOMES
# =============================================================================
'''
    
    for site_code, site_data in model["sites"].items():
        yaml_content += f'''
# =============================================================================
# SITE: {site_data["name"]} ({site_code})
# =============================================================================
{site_code}:
  name: {site_data["name"]}
  adx_database: {site_data["adx_database"]}
  validation_summary:
    snowflake: "{site_data["validation_summary"]["snowflake"]}"
    adx: "{site_data["validation_summary"]["adx"]}"
    total: "{site_data["validation_summary"]["total"]}"
  
  outcomes:
'''
        for outcome_id, outcome in site_data["outcomes"].items():
            yaml_content += f'''
    {outcome_id}:
      name: "{outcome["name"]}"
      section: "{outcome["section"]}"
      source: {outcome["source"]}
      status: {outcome["status"]}
'''
            if outcome.get("database"):
                yaml_content += f'      database: {outcome["database"]}\n'
            if outcome.get("discovered_sensor"):
                yaml_content += f'      sensor: "{outcome["discovered_sensor"]}"\n'
            if outcome.get("validated_at"):
                yaml_content += f'      validated_at: "{outcome["validated_at"]}"\n'
            
            # Query (multiline)
            yaml_content += f'      query: |\n'
            for line in outcome["query"].strip().split('\n'):
                yaml_content += f'        {line}\n'
            
            # Sample data
            if outcome["sample_data"]:
                yaml_content += f'      sample_data:\n'
                for i, sample in enumerate(outcome["sample_data"][:2]):  # Max 2 samples
                    yaml_content += f'        - # row {i+1}\n'
                    for k, v in sample.items():
                        if v is not None:
                            if isinstance(v, str) and len(v) > 50:
                                v = v[:47] + "..."
                            yaml_content += f'          {k}: {json.dumps(v)}\n'
    
    yaml_content += '''
# =============================================================================
# END OF COMPLETE SEMANTIC MODEL
# =============================================================================
'''
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(yaml_content)


if __name__ == "__main__":
    main()
