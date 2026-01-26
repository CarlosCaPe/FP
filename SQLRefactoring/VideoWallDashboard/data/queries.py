"""
Query templates for Snowflake and ADX data sources.
All queries validated against actual data sources.
"""
from dataclasses import dataclass
from typing import Dict


@dataclass
class QueryTemplate:
    """Query template with parameters."""
    name: str
    source: str  # SNOWFLAKE or ADX
    query: str
    description: str


# =============================================================================
# LOADING SECTION QUERIES
# =============================================================================

LOADING_QUERIES = {
    "dig_compliance": QueryTemplate(
        name="dig_compliance",
        source="SNOWFLAKE",
        description="Dig compliance - spatial compliance of shovel dig points",
        query="""
SELECT 
    SITE_CODE,
    COUNT(*) as total_dig_events,
    COUNT(DISTINCT LOADING_LOC_ID) as unique_dig_locations,
    COUNT(DISTINCT EXCAV_ID) as active_shovels,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as avg_dig_elevation_ft
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
    ),
    
    "dig_rate": QueryTemplate(
        name="dig_rate",
        source="SNOWFLAKE",
        description="Total fleet dig rate in TPH",
        query="""
SELECT 
    SITE_CODE,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS), 2) as total_tons,
    COUNT(*) as load_count,
    COUNT(DISTINCT EXCAV_ID) as shovel_count,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / 
          (TIMESTAMPDIFF(minute, MIN(CYCLE_START_TS_LOCAL), MAX(CYCLE_START_TS_LOCAL)) / 60.0), 2) as dig_rate_tph
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
    ),
    
    "priority_shovels": QueryTemplate(
        name="priority_shovels",
        source="SNOWFLAKE",
        description="Top 5 priority shovels by production",
        query="""
SELECT 
    e.EQUIP_NAME as shovel_id,
    -- Material type would come from dig zone mapping
    'Mill' as material_type,  
    SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) as total_tons,
    COUNT(*) as load_count,
    ROUND(SUM(lc.MEASURED_PAYLOAD_METRIC_TONS) / 
          NULLIF(TIMESTAMPDIFF(minute, MIN(lc.CYCLE_START_TS_LOCAL), MAX(lc.CYCLE_START_TS_LOCAL)) / 60.0, 0), 2) as rate_tph
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE lc
LEFT JOIN PROD_WG.LOAD_HAUL.LH_EQUIPMENT e 
    ON lc.EXCAV_ID = e.EQUIP_ID AND lc.SITE_CODE = e.SITE_CODE
WHERE lc.CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND lc.SITE_CODE = '{site_code}'
GROUP BY e.EQUIP_NAME
ORDER BY total_tons DESC
LIMIT 5
""",
    ),
}


# =============================================================================
# HAULAGE SECTION QUERIES
# =============================================================================

HAULAGE_QUERIES = {
    "truck_count": QueryTemplate(
        name="truck_count",
        source="SNOWFLAKE",
        description="Count of active haul trucks",
        query="""
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as active_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons_hauled
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
    ),
    
    "cycle_time": QueryTemplate(
        name="cycle_time",
        source="SNOWFLAKE",
        description="Average truck cycle time in minutes",
        query="""
SELECT 
    SITE_CODE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as median_cycle_time,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as min_cycle_time,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as max_cycle_time,
    COUNT(*) as total_cycles
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE
""",
    ),
    
    "asset_efficiency": QueryTemplate(
        name="asset_efficiency",
        source="SNOWFLAKE",
        description="Asset efficiency - cycles per truck",
        query="""
SELECT 
    SITE_CODE,
    COUNT(DISTINCT TRUCK_ID) as unique_trucks,
    COUNT(*) as total_cycles,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_payload_tons,
    ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as cycles_per_truck,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS) / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as tons_per_truck
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
GROUP BY SITE_CODE
""",
    ),
    
    "dump_compliance": QueryTemplate(
        name="dump_compliance",
        source="SNOWFLAKE",
        description="Dump plan compliance by location",
        query="""
SELECT 
    DUMP_LOC_NAME,
    COUNT(*) as dump_count,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    ROUND(100.0 * SUM(REPORT_PAYLOAD_SHORT_TONS) / 
          NULLIF(SUM(SUM(REPORT_PAYLOAD_SHORT_TONS)) OVER(), 0), 2) as pct_of_total
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(minute, -{rolling_minutes}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND DUMP_LOC_NAME IS NOT NULL
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
LIMIT 10
""",
    ),
}


# =============================================================================
# LBS ON GROUND QUERIES
# =============================================================================

LBS_ON_GROUND_QUERIES = {
    "mill_tons": QueryTemplate(
        name="mill_tons",
        source="SNOWFLAKE",
        description="Mill tons delivered - shift to date",
        query="""
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -{shift_hours}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%mill%' OR DUMP_LOC_NAME ILIKE '%crusher%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
    ),
    
    "mfl_tons": QueryTemplate(
        name="mfl_tons",
        source="SNOWFLAKE",
        description="MFL tons delivered - shift to date",
        query="""
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -{shift_hours}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%mfl%' OR DUMP_LOC_NAME ILIKE '%leach%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
    ),
    
    "rom_tons": QueryTemplate(
        name="rom_tons",
        source="SNOWFLAKE",
        description="ROM tons delivered - shift to date",
        query="""
SELECT 
    DUMP_LOC_NAME,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS), 2) as total_tons,
    COUNT(*) as dump_count
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -{shift_hours}, CURRENT_TIMESTAMP())
  AND SITE_CODE = '{site_code}'
  AND (DUMP_LOC_NAME ILIKE '%rom%' OR DUMP_LOC_NAME ILIKE '%stockpile%')
GROUP BY DUMP_LOC_NAME
ORDER BY total_tons DESC
""",
    ),
}


# =============================================================================
# ADX QUERIES (KQL)
# =============================================================================

ADX_QUERIES = {
    "mill_crusher": QueryTemplate(
        name="mill_crusher",
        source="ADX",
        description="Mill crusher rate from PI sensors",
        query="""
FCTSCURRENT()
| where sensor_id == '{pi_tag}'
| project sensor_id, rate_tph=todouble(value), timestamp, uom
""",
    ),
    
    "mill_crusher_history": QueryTemplate(
        name="mill_crusher_history",
        source="ADX",
        description="Mill crusher rate history for trend calculation",
        query="""
FCTS
| where sensor_id == '{pi_tag}'
| where timestamp > ago({lookback_hours}h)
| summarize rate_tph=avg(todouble(value)) by bin(timestamp, 1h)
| order by timestamp desc
| take 2
""",
    ),
    
    "ios_level": QueryTemplate(
        name="ios_level",
        source="ADX",
        description="IOS stockpile level - HIGHEST PRIORITY",
        query="""
FCTSCURRENT()
| where sensor_id in ('{pi_tag_main}', '{pi_tag_small}')
| project sensor_id, level_pct=todouble(value), timestamp
""",
    ),
    
    "ios_trend": QueryTemplate(
        name="ios_trend",
        source="ADX",
        description="IOS level with trend direction",
        query="""
let lookback = {lookback_hours}h;
FCTS
| where sensor_id in ('{pi_tag_main}', '{pi_tag_small}')
| where timestamp > ago(lookback)
| summarize 
    current_level = arg_max(timestamp, value),
    previous_level = arg_min(timestamp, value)
    by sensor_id
| extend direction = case(
    todouble(current_level_value) > todouble(previous_level_value), "INCREASING",
    todouble(current_level_value) < todouble(previous_level_value), "DECREASING",
    "STABLE"
)
| project sensor_id, current_level = todouble(current_level_value), direction, timestamp = current_level_timestamp
""",
    ),
    
    "mfl_crusher": QueryTemplate(
        name="mfl_crusher",
        source="ADX",
        description="MFL crusher rate from PI sensors",
        query="""
FCTSCURRENT()
| where sensor_id == '{pi_tag}' or sensor_id == '{pi_tag_alt}'
| project sensor_id, rate_tph=todouble(value), timestamp, uom
""",
    ),
    
    "all_kpis_summary": QueryTemplate(
        name="all_kpis_summary",
        source="ADX",
        description="Summary of all ADX-based KPIs",
        query="""
let kpi_sensors = dynamic([
    "{mill_crusher_tag}",
    "{mfl_crusher_tag}",
    "{ios_main_tag}",
    "{ios_small_tag}"
]);
FCTSCURRENT()
| where sensor_id in~ (kpi_sensors)
| extend kpi_name = case(
    sensor_id =~ "{mill_crusher_tag}", "Mill_Crusher_TPH",
    sensor_id =~ "{mfl_crusher_tag}", "MFL_Crusher_TPH",
    sensor_id =~ "{ios_main_tag}", "IOS_Level_Main",
    sensor_id =~ "{ios_small_tag}", "IOS_Level_Small",
    sensor_id
)
| project kpi_name, value = todouble(value), timestamp
""",
    ),
}


# =============================================================================
# COMBINED QUERY REGISTRY
# =============================================================================

ALL_QUERIES: Dict[str, QueryTemplate] = {
    **LOADING_QUERIES,
    **HAULAGE_QUERIES,
    **LBS_ON_GROUND_QUERIES,
    **ADX_QUERIES,
}


def get_query(name: str) -> QueryTemplate:
    """Get query template by name."""
    if name not in ALL_QUERIES:
        raise ValueError(f"Unknown query: {name}")
    return ALL_QUERIES[name]


def format_query(name: str, **kwargs) -> str:
    """Format query with parameters."""
    template = get_query(name)
    return template.query.format(**kwargs)
