"""
GENERATE COMPLETE SEMANTIC MODEL v2
Full semantic model with all required metadata
"""
import json
from datetime import datetime
from typing import Dict, List, Any

# =============================================================================
# COMPLETE OUTCOME DEFINITIONS with metadata
# =============================================================================
OUTCOMES_METADATA = {
    "01_dig_compliance": {
        "name": "Dig compliance (%)",
        "section": "Loading",
        "source": "SNOWFLAKE",
        "description": "Spatial compliance of shovel dig points relative to designated dig zones. Measures how well operators follow the dig plan.",
        "unit": "%",
        "sensible_range": {"min": 0, "max": 100, "typical": "85-95%"},
        "business_impact": "High compliance = better ore grade control and mine plan adherence"
    },
    "02_dig_rate": {
        "name": "Dig rate (TPOH)",
        "section": "Loading",
        "source": "SNOWFLAKE",
        "description": "Total tons per operating hour loaded by the entire shovel fleet. Key productivity metric for loading operations.",
        "unit": "TPH",
        "sensible_range": {"min": 0, "max": 99000, "typical": "15,000-50,000 TPH"},
        "business_impact": "Higher dig rate = more material moved = higher production"
    },
    "03_priority_shovels": {
        "name": "Priority shovels",
        "section": "Loading", 
        "source": "SNOWFLAKE",
        "description": "Top 5 shovels ranked by production (tons loaded). Identifies best performing equipment.",
        "unit": "tons",
        "sensible_range": {"min": 0, "max": 10000, "typical": "2,000-5,000 tons/shift per shovel"},
        "business_impact": "Focus resources on high-producing shovels"
    },
    "04_truck_count": {
        "name": "Number of trucks (qty)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Count of active haul trucks that completed at least one cycle. Mechanically available fleet size.",
        "unit": "count",
        "sensible_range": {"min": 20, "max": 150, "typical": "80-130 trucks"},
        "business_impact": "More trucks = higher haulage capacity"
    },
    "05_cycle_time": {
        "name": "Cycle Time (min)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Average round trip time for haul trucks from load to dump and back. Key efficiency metric.",
        "unit": "minutes",
        "sensible_range": {"min": 15, "max": 120, "typical": "35-60 min"},
        "business_impact": "Lower cycle time = more cycles per shift = higher productivity"
    },
    "06_asset_efficiency": {
        "name": "Asset Efficiency",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Truck utilization measured by cycles per truck and payload efficiency.",
        "unit": "cycles/truck",
        "sensible_range": {"min": 5, "max": 20, "typical": "8-12 cycles/truck/shift"},
        "business_impact": "Higher efficiency = better ROI on equipment"
    },
    "07_dump_compliance": {
        "name": "Dump plan compliance (%)",
        "section": "Haulage",
        "source": "SNOWFLAKE",
        "description": "Percentage of material dumped at correct designated locations per the mine plan.",
        "unit": "%",
        "sensible_range": {"min": 0, "max": 100, "typical": "90-98%"},
        "business_impact": "High compliance = correct ore/waste separation"
    },
    "08_mill_tons": {
        "name": "Mill - tons delivered",
        "section": "Lbs on Ground - Mill",
        "source": "SNOWFLAKE",
        "description": "Total tons of material dumped at Mill/Crusher locations. Feed to concentrator.",
        "unit": "tons",
        "sensible_range": {"min": 0, "max": 200000, "typical": "80,000-120,000 tons/shift"},
        "business_impact": "Mill feed volume directly impacts copper production"
    },
    "09_mill_crusher": {
        "name": "Mill - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "description": "Real-time crusher throughput from PI sensors. Primary crusher feeding the mill.",
        "unit": "TPH",
        "sensible_range": {"min": 0, "max": 12000, "typical": "7,000-9,000 TPH"},
        "business_impact": "Crusher bottleneck limits mill throughput"
    },
    "10_mill_rate": {
        "name": "Mill - Mill Rate (TPOH)",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "description": "Throughput rate of the milling circuit (SAG + Ball mills).",
        "unit": "TPH",
        "sensible_range": {"min": 0, "max": 12000, "typical": "7,000-9,000 TPH"},
        "business_impact": "Mill rate determines concentrate production capacity"
    },
    "11_mill_strategy": {
        "name": "Mill - Strategy compliance (IOS Level)",
        "section": "Lbs on Ground - Mill",
        "source": "ADX",
        "description": "In-Ore Stockpile (IOS) level and direction. Critical buffer between mine and mill.",
        "unit": "%",
        "sensible_range": {"min": 0, "max": 100, "typical": "25-75%"},
        "business_impact": "IOS level indicates mine-mill balance. Too low = mill starved, too high = capacity issue"
    },
    "12_mfl_tons": {
        "name": "MFL - tons delivered",
        "section": "Lbs on Ground - MFL",
        "source": "SNOWFLAKE",
        "description": "Total tons dumped at MFL (Mill Feed Leach) or leach pad locations.",
        "unit": "tons",
        "sensible_range": {"min": 0, "max": 100000, "typical": "40,000-70,000 tons/shift"},
        "business_impact": "Leach feed volume for SX-EW copper production"
    },
    "13_mfl_crusher": {
        "name": "MFL - Crusher Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "description": "Throughput rate at MFL crusher from PI sensors.",
        "unit": "TPH",
        "sensible_range": {"min": 0, "max": 8000, "typical": "3,000-5,000 TPH"},
        "business_impact": "MFL crusher capacity limits leach feed"
    },
    "14_mfl_fos": {
        "name": "MFL - FOS Rate (TPOH)",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "description": "FOS (Ferric Oxidation System) or FCP rate at MFL operations.",
        "unit": "TPH",
        "sensible_range": {"min": 0, "max": 6000, "typical": "3,000-5,000 TPH"},
        "business_impact": "FOS rate affects leach recovery"
    },
    "15_mfl_strategy": {
        "name": "MFL - Strategy compliance",
        "section": "Lbs on Ground - MFL",
        "source": "ADX",
        "description": "MFL stockpile levels and operational compliance metrics.",
        "unit": "%",
        "sensible_range": {"min": 0, "max": 100, "typical": "50-80%"},
        "business_impact": "Strategy compliance ensures optimal leach operations"
    },
    "16_rom_tons": {
        "name": "ROM - tons delivered",
        "section": "Lbs on Ground - ROM",
        "source": "SNOWFLAKE",
        "description": "Total tons dumped at ROM (Run of Mine) stockpile locations.",
        "unit": "tons",
        "sensible_range": {"min": 0, "max": 400000, "typical": "150,000-300,000 tons/shift"},
        "business_impact": "ROM stockpile is strategic buffer for operations"
    },
}

# =============================================================================
# SITE CONFIGURATIONS
# =============================================================================
SITES = {
    "MOR": {
        "name": "Morenci",
        "adx_database": "Morenci",
        "location": "Arizona, USA",
        "type": "Open Pit Copper",
        "has_load_haul": True,
        "pi_tags": {
            "mill_crusher": "MOR-CR03_WI00317_PV",
            "mfl_crusher": "MOR-CR02_WI01203_PV",
            "ios_main": "MOR-CC06_LI00601_PV",
            "ios_small": "MOR-CC10_LI0102_PV"
        }
    },
    "BAG": {
        "name": "Bagdad",
        "adx_database": "Bagdad",
        "location": "Arizona, USA",
        "type": "Open Pit Copper",
        "has_load_haul": True,
        "pi_tags": {
            "crusher": "BAG-GL4CrusherMotorMotorLoad",
            "level": "BAG-MD_BAG_CC_Crusher2_TonsPerHourTarget"
        }
    },
    "SAM": {
        "name": "Miami",
        "adx_database": "Miami",
        "location": "Arizona, USA",
        "type": "Underground/Processing",
        "has_load_haul": False,
        "note": "No surface Load/Haul operations - processing facility only",
        "pi_tags": {}
    },
    "CMX": {
        "name": "Climax",
        "adx_database": "Climax",
        "location": "Colorado, USA",
        "type": "Molybdenum Mine",
        "has_load_haul": False,
        "note": "Molybdenum operation - different fleet system",
        "pi_tags": {
            "level": "CMX-FTHME09.CLX09_1_0.LIT_82005.PVEU"
        }
    },
    "SIE": {
        "name": "Sierrita",
        "adx_database": "Sierrita",
        "location": "Arizona, USA",
        "type": "Open Pit Copper",
        "has_load_haul": True,
        "pi_tags": {
            "flow": "SIE-cr6.WI_2_Flow.Well_W_WI_2"
        }
    },
    "NMO": {
        "name": "NewMexico",
        "adx_database": "NewMexico",
        "location": "New Mexico, USA",
        "type": "Open Pit Copper",
        "has_load_haul": False,
        "note": "Different dispatch system - not in Snowflake LOAD_HAUL",
        "pi_tags": {
            "crusher": "NMO-Primary Crusher Total Run Time",
            "sag": "NMO-SAG2_MTD_TOT"
        }
    },
    "CVE": {
        "name": "CerroVerde",
        "adx_database": "CerroVerde",
        "location": "Arequipa, Peru",
        "type": "Open Pit Copper",
        "has_load_haul": False,
        "note": "Peru operation - separate data systems",
        "pi_tags": {
            "level": "CVE-C1_38_LIC_2833.PV"
        }
    },
}

# =============================================================================
# SNOWFLAKE QUERIES
# =============================================================================
SNOWFLAKE_QUERIES = {
    "01_dig_compliance": """
SELECT 
    SITE_CODE,
    COUNT(*) as total_dig_events,
    COUNT(DISTINCT LOADING_LOC_ID) as unique_dig_locations,
    COUNT(DISTINCT EXCAV_ID) as active_shovels,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as avg_dig_elevation_ft
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "02_dig_rate": """
SELECT 
    SITE_CODE,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS), 2) as total_tons_24hr,
    COUNT(*) as load_count,
    COUNT(DISTINCT EXCAV_ID) as shovel_count
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "03_priority_shovels": """
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
LIMIT 5""",

    "04_truck_count": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons_hauled
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "05_cycle_time": """
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
GROUP BY SITE_CODE""",

    "06_asset_efficiency": """
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_payload_tons,
    ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as cycles_per_truck
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "07_dump_compliance": """
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
LIMIT 5""",

    "08_mill_tons": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC""",

    "12_mfl_tons": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC""",

    "16_rom_tons": """
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site}'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC""",
}

# =============================================================================
# ADX QUERIES BY SITE
# =============================================================================
ADX_QUERIES = {
    "09_mill_crusher": {
        "MOR": "FCTSCURRENT() | where sensor_id == 'MOR-CR03_WI00317_PV' | project sensor_id, rate_tph=todouble(value), timestamp, uom",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'Crusher' and sensor_id contains 'Motor' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'CR' or sensor_id contains 'WI' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'Crusher' | project sensor_id, value=todouble(value), timestamp | order by value desc | take 3",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 100 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
    },
    "10_mill_rate": {
        "MOR": "FCTSCURRENT() | where sensor_id contains 'CR03' and sensor_id contains 'WI' | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'SAG' or sensor_id contains 'MILL' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'MILL' or sensor_id contains 'CR' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
    },
    "11_mill_strategy": {
        "MOR": "FCTSCURRENT() | where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV') | project sensor_id, level_pct=todouble(value), timestamp",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'CC' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'LIT' | where todouble(value) > 0 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'LIMS' | where todouble(value) > 0 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'LIC' or sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
    },
    "13_mfl_crusher": {
        "MOR": "FCTSCURRENT() | where sensor_id == 'MOR-CR02_WI01203_PV' or sensor_id == 'MOR-CR02_WI01201_PV' | project sensor_id, rate_tph=todouble(value), timestamp, uom",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'CR02' or sensor_id contains 'MFL' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'Crusher' | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'CR' and todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
    },
    "14_mfl_fos": {
        "MOR": "FCTSCURRENT() | where sensor_id contains 'FOS' or sensor_id contains 'LEACH' or sensor_id contains 'CR02' | where todouble(value) > 50 | project sensor_id, rate_tph=todouble(value), timestamp | order by rate_tph desc | take 3",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'FOS' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'FOS' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'FOS' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'FOS' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'Raff' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'Leach' or sensor_id contains 'FOS' | where todouble(value) > 0 | project sensor_id, rate_tph=todouble(value), timestamp | take 3",
    },
    "15_mfl_strategy": {
        "MOR": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'MFL' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | order by level_pct desc | take 5",
        "BAG": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "SAM": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "CMX": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "SIE": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "NMO": "FCTSCURRENT() | where sensor_id contains 'LI' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
        "CVE": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'LIC' | where todouble(value) > 0 and todouble(value) < 100 | project sensor_id, level_pct=todouble(value), timestamp | take 5",
    },
}


def connect_snowflake():
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
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
    return KustoClient(kcsb)


def run_sf_query(conn, query):
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
        cursor.close()
        return [{col: (float(val) if isinstance(val, (int, float)) else str(val) if val else None) 
                for col, val in zip(columns, row)} for row in rows[:3]]
    except Exception as e:
        return [{"error": str(e)}]


def run_adx_query(client, database, query):
    try:
        response = client.execute(database, query)
        primary = response.primary_results[0]
        columns = [col.column_name for col in primary.columns]
        return [{col: (float(row[i]) if isinstance(row[i], (int, float)) else str(row[i]) if row[i] else None) 
                for i, col in enumerate(columns)} for row in list(primary.rows)[:3]]
    except Exception as e:
        return [{"error": str(e)}]


def generate_yaml(data, path):
    """Generate complete YAML file"""
    ts = data["generated_at"]
    
    content = f'''# =============================================================================
# ADX UNIFIED SEMANTIC MODEL - COMPLETE
# =============================================================================
# THE SINGLE SOURCE OF TRUTH for all FCTS mining operations
# 
# Structure:
#   - 7 Sites (each independent)
#   - 16 Business Outcomes per site
#   - Real validated sample data
#   - Full metadata (descriptions, units, ranges)
#
# Generated: {ts[:10]}
# Cluster: https://fctsnaproddatexp02.westus2.kusto.windows.net
# =============================================================================

version: "4.0"
name: ADX_FCTS_UNIFIED_COMPLETE
generated_at: "{ts}"

# =============================================================================
# DATA SOURCE CONNECTIONS
# =============================================================================
connections:
  snowflake:
    account: FCX-NA
    warehouse: WH_BATCH_DE_NONPROD
    database: PROD_WG
    schema: LOAD_HAUL
    authentication: externalbrowser
    tables:
      - LH_LOADING_CYCLE  # Shovel loading events
      - LH_HAUL_CYCLE     # Truck haul cycles
      - LH_EQUIPMENT      # Equipment master data
    
  adx:
    cluster: https://fctsnaproddatexp02.westus2.kusto.windows.net
    authentication: InteractiveBrowserCredential
    functions:
      - FCTSCURRENT()  # Latest value per sensor
      - FCTS()         # Historical time series

# =============================================================================
# OUTCOME DEFINITIONS (The 16 Business Metrics)
# =============================================================================
outcome_definitions:
'''
    for oid, meta in OUTCOMES_METADATA.items():
        content += f'''
  {oid}:
    name: "{meta['name']}"
    section: "{meta['section']}"
    source: {meta['source']}
    description: "{meta['description']}"
    unit: "{meta['unit']}"
    sensible_range:
      min: {meta['sensible_range']['min']}
      max: {meta['sensible_range']['max']}
      typical: "{meta['sensible_range']['typical']}"
    business_impact: "{meta['business_impact']}"
'''

    content += '''
# =============================================================================
# SITES - EACH SITE IS INDEPENDENT
# =============================================================================
'''

    for site_code, site_data in data["sites"].items():
        site_config = SITES[site_code]
        content += f'''
# =============================================================================
# SITE: {site_config["name"]} ({site_code})
# Location: {site_config["location"]}
# Type: {site_config["type"]}
# =============================================================================
{site_code}:
  name: "{site_config["name"]}"
  adx_database: {site_config["adx_database"]}
  location: "{site_config["location"]}"
  type: "{site_config["type"]}"
  has_load_haul_data: {str(site_config["has_load_haul"]).lower()}
'''
        if site_config.get("note"):
            content += f'  note: "{site_config["note"]}"\n'
        
        if site_config.get("pi_tags"):
            content += f'  discovered_pi_tags:\n'
            for tag_name, tag_id in site_config["pi_tags"].items():
                content += f'    {tag_name}: "{tag_id}"\n'
        
        content += f'''  
  validation_summary:
    snowflake: "{site_data["validation"]["snowflake"]}"
    adx: "{site_data["validation"]["adx"]}"
    total: "{site_data["validation"]["total"]}"
    validated_at: "{ts}"
  
  outcomes:
'''
        for outcome_id, outcome in site_data["outcomes"].items():
            meta = OUTCOMES_METADATA.get(outcome_id, {})
            content += f'''
    {outcome_id}:
      name: "{outcome.get('name', meta.get('name', outcome_id))}"
      section: "{outcome.get('section', meta.get('section', 'Unknown'))}"
      source: {outcome.get('source', 'UNKNOWN')}
      status: {outcome.get('status', 'UNKNOWN')}
      unit: "{meta.get('unit', '')}"
'''
            if outcome.get("database"):
                content += f'      database: {outcome["database"]}\n'
            if outcome.get("discovered_sensor"):
                content += f'      discovered_sensor: "{outcome["discovered_sensor"]}"\n'
            if outcome.get("validated_at"):
                content += f'      validated_at: "{outcome["validated_at"]}"\n'
            
            content += f'      query: |\n'
            for line in outcome.get("query", "").strip().split('\n'):
                content += f'        {line}\n'
            
            if outcome.get("sample_data") and "error" not in str(outcome["sample_data"]):
                content += f'      sample_data:\n'
                for i, sample in enumerate(outcome["sample_data"][:2]):
                    content += f'        - # sample {i+1}\n'
                    for k, v in sample.items():
                        if v is not None:
                            val = str(v)[:60] + "..." if len(str(v)) > 60 else v
                            content += f'          {k}: {json.dumps(val)}\n'

    # Cross-site queries
    content += '''
# =============================================================================
# CROSS-SITE COMPARISON QUERIES
# =============================================================================
cross_site_queries:

  all_sites_dig_rate:
    name: "Dig Rate Comparison - All Sites"
    source: SNOWFLAKE
    description: "Compare dig rates across all active sites"
    query: |
      SELECT 
          SITE_CODE,
          ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS), 2) as total_tons,
          COUNT(*) as load_count,
          COUNT(DISTINCT EXCAV_ID) as shovel_count
      FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
      WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
      GROUP BY SITE_CODE
      ORDER BY total_tons DESC

  all_sites_cycle_time:
    name: "Cycle Time Comparison - All Sites"
    source: SNOWFLAKE
    description: "Compare average cycle times across sites"
    query: |
      SELECT 
          SITE_CODE,
          ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_mins,
          COUNT(*) as cycles,
          COUNT(DISTINCT TRUCK_ID) as trucks
      FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
      WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
        AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
        AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
      GROUP BY SITE_CODE
      ORDER BY avg_cycle_mins

  all_sites_crusher_rates:
    name: "Crusher Rates - All Sites (ADX)"
    source: ADX
    description: "Compare crusher rates across sites using ADX union"
    query: |
      union
        database('Morenci').FCTSCURRENT() | extend site='MOR',
        database('Bagdad').FCTSCURRENT() | extend site='BAG',
        database('Sierrita').FCTSCURRENT() | extend site='SIE',
        database('Climax').FCTSCURRENT() | extend site='CMX',
        database('CerroVerde').FCTSCURRENT() | extend site='CVE',
        database('NewMexico').FCTSCURRENT() | extend site='NMO',
        database('Miami').FCTSCURRENT() | extend site='SAM'
      | where sensor_id contains 'CR' and sensor_id contains 'WI'
      | where todouble(value) > 100
      | summarize max_rate=max(todouble(value)) by site
      | order by max_rate desc

# =============================================================================
# COLUMN MAPPINGS REFERENCE
# =============================================================================
column_mappings:
  snowflake:
    loading_cycle:
      table: LH_LOADING_CYCLE
      site_filter: "SITE_CODE = '{site}'"
      key_columns:
        - EXCAV_ID           # Shovel equipment ID
        - LOADING_LOC_ID     # Dig location
        - MEASURED_PAYLOAD_METRIC_TONS  # Actual payload
        - CYCLE_START_TS_LOCAL          # Timestamp
        - LOADING_CYCLE_DIG_ELEV_AVG_FEET  # Dig elevation
    
    haul_cycle:
      table: LH_HAUL_CYCLE
      site_filter: "SITE_CODE = '{site}'"
      key_columns:
        - TRUCK_ID                        # Truck equipment ID
        - DUMP_LOC_NAME                   # Dump destination
        - REPORT_PAYLOAD_SHORT_TONS       # Payload
        - TOTAL_CYCLE_DURATION_CALENDAR_MINS  # Cycle time
        - CYCLE_START_TS_LOCAL            # Timestamp
    
    equipment:
      table: LH_EQUIPMENT
      join_key: "EQUIP_ID = EXCAV_ID or EQUIP_ID = TRUCK_ID"
      
  adx:
    current_values:
      function: FCTSCURRENT()
      key_columns:
        - sensor_id   # PI Point name
        - value       # Reading (string - use todouble())
        - timestamp   # Reading time
        - uom         # Unit of measure
        - quality     # Data quality (0 = good)
    
    historical:
      function: FCTS()
      additional: Same columns with full history

# =============================================================================
# USAGE EXAMPLES
# =============================================================================
usage_examples:

  python_snowflake:
    description: "Query Snowflake for a specific site"
    code: |
      import snowflake.connector
      
      conn = snowflake.connector.connect(
          account='FCX-NA',
          authenticator='externalbrowser',
          user='your_user@fmi.com'
      )
      cursor = conn.cursor()
      cursor.execute("USE WAREHOUSE WH_BATCH_DE_NONPROD")
      
      # Get dig rate for Morenci
      cursor.execute("""
          SELECT SITE_CODE, SUM(MEASURED_PAYLOAD_METRIC_TONS) as tons
          FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
          WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
            AND SITE_CODE = 'MOR'
          GROUP BY SITE_CODE
      """)
      print(cursor.fetchall())

  python_adx:
    description: "Query ADX for crusher rate"
    code: |
      from azure.identity import InteractiveBrowserCredential
      from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
      
      cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
      credential = InteractiveBrowserCredential()
      kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
      client = KustoClient(kcsb)
      
      # Get Mill Crusher rate for Morenci
      result = client.execute("Morenci", 
          "FCTSCURRENT() | where sensor_id == 'MOR-CR03_WI00317_PV'")
      for row in result.primary_results[0]:
          print(row)

# =============================================================================
# VALIDATION SUMMARY
# =============================================================================
validation_summary:
  generated_at: "{ts}"
  total_outcomes: 16
  total_sites: 7
  total_queries: 112
  
  by_site:
'''
    for site_code, site_data in data["sites"].items():
        content += f'    {site_code}: "{site_data["validation"]["total"]}"\n'
    
    content += '''
# =============================================================================
# END OF SEMANTIC MODEL
# =============================================================================
'''
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


def main():
    print("=" * 80)
    print("GENERATING COMPLETE SEMANTIC MODEL v2")
    print("=" * 80)
    
    print("\n🔐 Connecting to Snowflake...")
    sf_conn = connect_snowflake()
    print("✅ Snowflake connected")
    
    print("🔐 Connecting to ADX...")
    adx_client = connect_adx()
    print("✅ ADX connected")
    
    model_data = {
        "generated_at": datetime.now().isoformat(),
        "sites": {}
    }
    
    for site_code, site_config in SITES.items():
        print(f"\n{'='*60}")
        print(f"📍 {site_config['name']} ({site_code})")
        print("="*60)
        
        site_result = {
            "outcomes": {},
            "validation": {"snowflake": "0/10", "adx": "0/6", "total": "0/16"}
        }
        
        sf_success = 0
        adx_success = 0
        
        # Snowflake
        print("  Snowflake:")
        for oid, query_template in SNOWFLAKE_QUERIES.items():
            query = query_template.format(site=site_code)
            results = run_sf_query(sf_conn, query)
            has_data = len(results) > 0 and "error" not in results[0]
            if has_data:
                sf_success += 1
            meta = OUTCOMES_METADATA.get(oid, {})
            site_result["outcomes"][oid] = {
                "name": meta.get("name", oid),
                "section": meta.get("section", "Unknown"),
                "source": "SNOWFLAKE",
                "status": "SUCCESS" if has_data else "NO_DATA",
                "validated_at": datetime.now().isoformat() if has_data else None,
                "query": query.strip(),
                "sample_data": results if has_data else []
            }
            status = "✅" if has_data else "⚠️"
            print(f"    {status} {meta.get('name', oid)}")
        
        # ADX
        print("  ADX:")
        for oid, site_queries in ADX_QUERIES.items():
            query = site_queries.get(site_code, "")
            database = site_config["adx_database"]
            results = run_adx_query(adx_client, database, query) if query else []
            has_data = len(results) > 0 and "error" not in results[0]
            if has_data:
                adx_success += 1
            meta = OUTCOMES_METADATA.get(oid, {})
            discovered = results[0].get("sensor_id") if has_data and results else None
            site_result["outcomes"][oid] = {
                "name": meta.get("name", oid),
                "section": meta.get("section", "Unknown"),
                "source": "ADX",
                "database": database,
                "status": "SUCCESS" if has_data else "NO_DATA",
                "discovered_sensor": discovered,
                "validated_at": datetime.now().isoformat() if has_data else None,
                "query": query.strip(),
                "sample_data": results if has_data else []
            }
            status = "✅" if has_data else "⚠️"
            sensor_info = discovered[:35] + "..." if discovered and len(discovered) > 35 else discovered or "no data"
            print(f"    {status} {meta.get('name', oid)}: {sensor_info}")
        
        site_result["validation"] = {
            "snowflake": f"{sf_success}/10",
            "adx": f"{adx_success}/6",
            "total": f"{sf_success + adx_success}/16"
        }
        print(f"  Summary: SF {sf_success}/10 | ADX {adx_success}/6 | Total {sf_success + adx_success}/16")
        
        model_data["sites"][site_code] = site_result
    
    sf_conn.close()
    
    # Generate YAML
    yaml_path = "adx_semantic_models/ADX_UNIFIED.semantic.yaml"
    generate_yaml(model_data, yaml_path)
    print(f"\n✅ Model saved: {yaml_path}")
    
    # Save JSON backup
    json_path = "reports/semantic_model_complete.json"
    with open(json_path, 'w') as f:
        json.dump(model_data, f, indent=2, default=str)
    print(f"✅ JSON backup: {json_path}")


if __name__ == "__main__":
    main()
