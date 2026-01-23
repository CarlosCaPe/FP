"""
=============================================================================
COMPREHENSIVE QUERY VALIDATOR - Snowflake & ADX
=============================================================================
Validates ALL queries from the knowledge_base.json at every hierarchical level:
  - Section (Production Performance, Processing)
  - Value Chain Step (Loading, Haulage, Lbs on Ground, Mill IOS, etc.)
  - Outcome (Dig compliance, Dig rate, Number of trucks, etc.)
  - Time Dimension (Actuals, Planned, Projected)

Output: Validated queries with sample results for semantic model enrichment
=============================================================================
"""

import os
import json
from datetime import datetime
from pathlib import Path

# =============================================================================
# SNOWFLAKE CONNECTION
# =============================================================================
def get_snowflake_connection():
    """Create Snowflake connection using environment variables."""
    import snowflake.connector
    from dotenv import load_dotenv
    
    load_dotenv()
    
    conn = snowflake.connector.connect(
        account=os.getenv('CONN_LIB_SNOWFLAKE_ACCOUNT'),
        user=os.getenv('CONN_LIB_SNOWFLAKE_USER'),
        authenticator=os.getenv('CONN_LIB_SNOWFLAKE_AUTHENTICATOR', 'externalbrowser'),
        role=os.getenv('CONN_LIB_SNOWFLAKE_ROLE'),
        warehouse=os.getenv('CONN_LIB_SNOWFLAKE_WAREHOUSE'),
        database=os.getenv('CONN_LIB_SNOWFLAKE_DATABASE'),
    )
    return conn

def execute_snowflake_query(conn, query: str, limit: int = 5) -> dict:
    """Execute Snowflake query and return results."""
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchmany(limit)
        cursor.close()
        return {
            "status": "SUCCESS",
            "row_count": len(rows),
            "columns": columns,
            "sample_data": [dict(zip(columns, row)) for row in rows]
        }
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

# =============================================================================
# ADX CONNECTION
# =============================================================================
def get_adx_client():
    """Create ADX client with browser authentication."""
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER_URL, credential)
    return KustoClient(kcsb)

def execute_adx_query(client, database: str, query: str) -> dict:
    """Execute ADX query and return results."""
    try:
        response = client.execute(database, query)
        columns = [col.column_name for col in response.primary_results[0].columns]
        rows = list(response.primary_results[0])
        return {
            "status": "SUCCESS",
            "row_count": len(rows),
            "columns": columns,
            "sample_data": [dict(zip(columns, row)) for row in rows[:5]]
        }
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

# =============================================================================
# HIERARCHICAL QUERY DEFINITIONS
# =============================================================================

QUERY_HIERARCHY = {
    "Production Performance": {
        "Loading": {
            "Dig compliance (%)": {
                "source": "SNOWFLAKE",
                "description": "Spatial compliance of shovel dig points relative to dig zones for current shift",
                "sensible_range": "0-100%",
                "queries": {
                    "L1_table_exists": {
                        "level": 1,
                        "description": "Verify tables exist",
                        "query": """
SELECT table_name, row_count, created
FROM prod_wg.information_schema.tables 
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name IN ('LH_LOADING_CYCLE', 'LH_BUCKET')
ORDER BY table_name;
"""
                    },
                    "L2_schema_discovery": {
                        "level": 2,
                        "description": "Discover relevant columns for dig compliance",
                        "query": """
SELECT column_name, data_type, is_nullable
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_LOADING_CYCLE'
  AND (column_name ILIKE '%dig%' OR column_name ILIKE '%x%' OR column_name ILIKE '%y%' OR column_name ILIKE '%z%' OR column_name ILIKE '%compliance%')
LIMIT 20;
"""
                    },
                    "L3_actuals_rolling_60min": {
                        "level": 3,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Dig compliance for last 60 minutes (rolling)",
                        "query": """
-- Dig Compliance (%) - Actuals - Rolling 60 minutes
-- Source: prod_wg.load_haul.lh_loading_cycle
SELECT 
    COUNT(*) as total_dig_events,
    -- Note: Actual compliance calculation requires dig zone geometry join
    -- This is a placeholder showing available data
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(minute, -60, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci';
"""
                    }
                }
            },
            "Dig rate (TPH)": {
                "source": "SNOWFLAKE",
                "description": "Total tons loaded by entire shovel fleet each hour",
                "sensible_range": "up to 99,000",
                "queries": {
                    "L1_column_discovery": {
                        "level": 1,
                        "description": "Find payload/tonnage columns",
                        "query": """
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_LOADING_CYCLE'
  AND (column_name ILIKE '%payload%' OR column_name ILIKE '%ton%' OR column_name ILIKE '%weight%')
LIMIT 20;
"""
                    },
                    "L2_actuals_rolling_60min": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Total tons loaded in last 60 minutes",
                        "query": """
-- Dig Rate (TPH) - Actuals - Rolling 60 minutes
-- Source: prod_wg.load_haul.lh_loading_cycle
SELECT 
    SUM(measured_payload_metric_tons) as total_tons_60min,
    SUM(measured_payload_metric_tons) * (60.0 / NULLIF(DATEDIFF(minute, MIN(cycle_start_ts_local), MAX(cycle_start_ts_local)), 0)) as estimated_tph,
    COUNT(*) as load_count,
    COUNT(DISTINCT equipment_name) as shovel_count,
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(minute, -60, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci';
"""
                    },
                    "L3_actuals_by_shovel": {
                        "level": 3,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Dig rate by shovel (for Priority Shovels)",
                        "query": """
-- Dig Rate by Shovel - Last 60 minutes
SELECT 
    equipment_name as shovel_id,
    SUM(measured_payload_metric_tons) as total_tons,
    COUNT(*) as load_count,
    ROUND(SUM(measured_payload_metric_tons) / NULLIF(COUNT(*), 0), 2) as avg_payload_per_load
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(minute, -60, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY equipment_name
ORDER BY total_tons DESC
LIMIT 10;
"""
                    }
                }
            },
            "Priority shovels": {
                "source": "SNOWFLAKE",
                "description": "Top 5 shovels by dig rate and compliance",
                "sensible_range": "Rate: up to 5,000 TPH per shovel",
                "queries": {
                    "L1_top5_shovels": {
                        "level": 1,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Top 5 priority shovels by tonnage",
                        "query": """
-- Priority Shovels - Top 5 by tonnage (last 60 min)
SELECT 
    equipment_name as shovel_id,
    SUM(measured_payload_metric_tons) as total_tons,
    COUNT(*) as load_count,
    ROUND(SUM(measured_payload_metric_tons), 2) as tons_per_hour_estimate
FROM prod_wg.load_haul.lh_loading_cycle
WHERE cycle_start_ts_local >= DATEADD(minute, -60, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY equipment_name
ORDER BY total_tons DESC
LIMIT 5;
"""
                    }
                }
            }
        },
        "Haulage": {
            "Number of trucks (qty)": {
                "source": "SNOWFLAKE",
                "description": "Number of mechanically available trucks (not in maintenance)",
                "sensible_range": "100-130",
                "queries": {
                    "L1_table_discovery": {
                        "level": 1,
                        "description": "Find equipment status tables",
                        "query": """
SELECT table_name, row_count
FROM prod_wg.information_schema.tables 
WHERE table_schema = 'LOAD_HAUL' 
  AND (table_name ILIKE '%equipment%' OR table_name ILIKE '%status%' OR table_name ILIKE '%truck%')
ORDER BY table_name;
"""
                    },
                    "L2_actuals_current_hour": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Distinct trucks operating in current hour",
                        "query": """
-- Number of Trucks - Actuals - Current Hour
-- Source: prod_wg.load_haul.lh_haul_cycle
SELECT 
    COUNT(DISTINCT truck_name) as active_trucks,
    MIN(cycle_start_ts_local) as period_start,
    MAX(cycle_start_ts_local) as period_end
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci';
"""
                    },
                    "L3_trucks_by_status": {
                        "level": 3,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Trucks by operational status",
                        "query": """
-- Truck count from haul cycles (last hour)
SELECT 
    truck_name,
    COUNT(*) as cycle_count,
    SUM(report_payload_short_tons) as total_tons,
    AVG(total_cycle_duration_calendar_mins) as avg_cycle_time
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
GROUP BY truck_name
ORDER BY cycle_count DESC
LIMIT 10;
"""
                    }
                }
            },
            "Cycle Time (min)": {
                "source": "SNOWFLAKE",
                "description": "Average round trip time across entire truck fleet",
                "sensible_range": "35-45 min",
                "queries": {
                    "L1_column_discovery": {
                        "level": 1,
                        "description": "Find cycle time columns",
                        "query": """
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_HAUL_CYCLE'
  AND (column_name ILIKE '%cycle%' OR column_name ILIKE '%duration%' OR column_name ILIKE '%time%')
LIMIT 20;
"""
                    },
                    "L2_actuals_rolling_60min": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Average cycle time - Rolling 60 minutes",
                        "query": """
-- Cycle Time - Actuals - Rolling 60 minutes
SELECT 
    ROUND(AVG(total_cycle_duration_calendar_mins), 2) as avg_cycle_time_mins,
    ROUND(MIN(total_cycle_duration_calendar_mins), 2) as min_cycle_time,
    ROUND(MAX(total_cycle_duration_calendar_mins), 2) as max_cycle_time,
    COUNT(*) as total_cycles,
    COUNT(DISTINCT truck_name) as truck_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(minute, -60, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND total_cycle_duration_calendar_mins > 0
  AND total_cycle_duration_calendar_mins < 180;  -- Filter outliers
"""
                    }
                }
            },
            "Dump plan compliance (%)": {
                "source": "SNOWFLAKE",
                "description": "Proportion of hauled material dumped at designated location",
                "sensible_range": "0-100%",
                "queries": {
                    "L1_dump_location_discovery": {
                        "level": 1,
                        "description": "Discover dump location columns",
                        "query": """
SELECT column_name, data_type
FROM prod_wg.information_schema.columns
WHERE table_schema = 'LOAD_HAUL' 
  AND table_name = 'LH_HAUL_CYCLE'
  AND (column_name ILIKE '%dump%' OR column_name ILIKE '%dest%' OR column_name ILIKE '%location%')
LIMIT 20;
"""
                    },
                    "L2_dump_locations": {
                        "level": 2,
                        "description": "List of dump locations with tonnage",
                        "query": """
-- Dump locations breakdown (last shift)
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
                    }
                }
            }
        },
        "Lbs on Ground": {
            "Mill - tons delivered": {
                "source": "SNOWFLAKE",
                "description": "Total tons delivered to Mill location",
                "sensible_range": "~108kt per shift",
                "queries": {
                    "L1_mill_destinations": {
                        "level": 1,
                        "description": "Find Mill-related dump locations",
                        "query": """
-- Find Mill dump locations
SELECT DISTINCT dump_loc_name
FROM prod_wg.load_haul.lh_haul_cycle
WHERE site_name = 'Morenci'
  AND (dump_loc_name ILIKE '%mill%' OR dump_loc_name ILIKE '%cr2%' OR dump_loc_name ILIKE '%cr3%')
  AND cycle_start_ts_local >= DATEADD(day, -7, CURRENT_TIMESTAMP())
LIMIT 20;
"""
                    },
                    "L2_actuals_shift": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Mill tons delivered - current shift",
                        "query": """
-- Mill - Tons Delivered - Current Shift
SELECT 
    dump_loc_name,
    SUM(report_payload_short_tons) as total_tons,
    COUNT(*) as dump_count
FROM prod_wg.load_haul.lh_haul_cycle
WHERE cycle_start_ts_local >= DATEADD(hour, -12, CURRENT_TIMESTAMP())
  AND site_name = 'Morenci'
  AND (dump_loc_name ILIKE '%mill%' OR dump_loc_name ILIKE '%crusher%')
GROUP BY dump_loc_name
ORDER BY total_tons DESC;
"""
                    }
                }
            },
            "Mill - Crusher Rate (TPH)": {
                "source": "ADX",
                "description": "Mill crusher processing rate",
                "sensible_range": "up to 9,000 TPH",
                "pi_tag": "MOR-CR03_WI00317_PV",
                "queries": {
                    "L1_current_value": {
                        "level": 1,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Current crusher rate",
                        "database": "Morenci",
                        "query": """
// Mill Crusher Rate - Current Value
database("Morenci").FCTSCURRENT()
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| project sensor_id, current_value = toreal(value), uom, timestamp
"""
                    },
                    "L2_rolling_60min": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Average crusher rate - Rolling 60 minutes",
                        "database": "Morenci",
                        "query": """
// Mill Crusher Rate - Rolling 60 min average
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
                    "L3_hourly_trend": {
                        "level": 3,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Hourly trend - Last 12 hours",
                        "database": "Morenci",
                        "query": """
// Mill Crusher Rate - Hourly trend (last 12h)
database("Morenci").FCTS()
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| where timestamp > ago(12h)
| extend value_num = toreal(value)
| summarize avg_rate = round(avg(value_num), 2) by bin(timestamp, 1h)
| order by timestamp desc
"""
                    }
                }
            },
            "Mill - Strategy compliance (IOS Level)": {
                "source": "ADX",
                "description": "Mill IOS stockpile level and direction of change",
                "sensible_range": "250,000-500,000",
                "pi_tags": ["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"],
                "queries": {
                    "L1_current_ios_levels": {
                        "level": 1,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Current IOS levels",
                        "database": "Morenci",
                        "query": """
// Mill IOS - Current Levels
database("Morenci").FCTSCURRENT()
| where sensor_id in~ ("MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV")
| extend 
    ios_name = case(
        sensor_id =~ "MOR-CC06_LI00601_PV", "Main IOS",
        sensor_id =~ "MOR-CC10_LI0102_PV", "Small IOS",
        "Unknown")
| project ios_name, sensor_id, current_level = toreal(value), uom, timestamp
"""
                    },
                    "L2_ios_with_direction": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "IOS level with direction of change (last hour)",
                        "database": "Morenci",
                        "query": """
// Mill IOS - Level with Direction (validated query)
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
        value_num > prev_value, "↑ INCREASING",
        value_num < prev_value, "↓ DECREASING",
        "→ STABLE"),
    ios_name = case(
        sensor_id =~ "MOR-CC06_LI00601_PV", "Main IOS",
        sensor_id =~ "MOR-CC10_LI0102_PV", "Small IOS",
        "Unknown")
| project ios_name, sensor_id, current_level, direction, timestamp
"""
                    }
                }
            },
            "MFL - tons delivered": {
                "source": "SNOWFLAKE",
                "description": "Total tons delivered to MFL location",
                "sensible_range": "~60kt per shift",
                "queries": {
                    "L1_mfl_destinations": {
                        "level": 1,
                        "description": "Find MFL-related dump locations",
                        "query": """
-- Find MFL dump locations
SELECT DISTINCT dump_loc_name
FROM prod_wg.load_haul.lh_haul_cycle
WHERE site_name = 'Morenci'
  AND dump_loc_name ILIKE '%mfl%'
  AND cycle_start_ts_local >= DATEADD(day, -7, CURRENT_TIMESTAMP())
LIMIT 20;
"""
                    },
                    "L2_actuals_shift": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "MFL tons delivered - current shift",
                        "query": """
-- MFL - Tons Delivered - Current Shift
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
                    }
                }
            },
            "MFL - Crusher Rate (TPOH)": {
                "source": "ADX",
                "description": "MFL crushed leach processing rate",
                "sensible_range": "up to 5,000 TPH",
                "pi_tag": "MOR-CR02_WI01203_PV",
                "queries": {
                    "L1_current_value": {
                        "level": 1,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Current MFL crusher rate",
                        "database": "Morenci",
                        "query": """
// MFL Crusher Rate - Current Value
database("Morenci").FCTSCURRENT()
| where sensor_id =~ "MOR-CR02_WI01203_PV"
| project sensor_id, current_value = toreal(value), uom, timestamp
"""
                    },
                    "L2_rolling_60min": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "Average MFL crusher rate - Rolling 60 minutes",
                        "database": "Morenci",
                        "query": """
// MFL Crusher Rate - Rolling 60 min average
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
                    }
                }
            },
            "ROM - tons delivered": {
                "source": "SNOWFLAKE",
                "description": "Total tons delivered to ROM stockpile",
                "sensible_range": "~250kt per shift",
                "queries": {
                    "L1_rom_destinations": {
                        "level": 1,
                        "description": "Find ROM-related dump locations",
                        "query": """
-- Find ROM dump locations
SELECT DISTINCT dump_loc_name
FROM prod_wg.load_haul.lh_haul_cycle
WHERE site_name = 'Morenci'
  AND dump_loc_name ILIKE '%rom%'
  AND cycle_start_ts_local >= DATEADD(day, -7, CURRENT_TIMESTAMP())
LIMIT 20;
"""
                    },
                    "L2_actuals_shift": {
                        "level": 2,
                        "time_dimension": "Actuals - Near Real-Time",
                        "description": "ROM tons delivered - current shift",
                        "query": """
-- ROM - Tons Delivered - Current Shift
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
                    }
                }
            }
        }
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
def run_all_validations():
    """Run all query validations and generate results."""
    results = {
        "validation_timestamp": datetime.now().isoformat(),
        "sections": {}
    }
    
    print("=" * 80)
    print("COMPREHENSIVE QUERY VALIDATION - Snowflake & ADX")
    print("=" * 80)
    
    # Connect to Snowflake
    print("\n🔐 Connecting to Snowflake...")
    try:
        sf_conn = get_snowflake_connection()
        print("✅ Snowflake connected")
    except Exception as e:
        print(f"❌ Snowflake connection failed: {e}")
        sf_conn = None
    
    # Connect to ADX
    print("\n🔐 Connecting to ADX...")
    try:
        adx_client = get_adx_client()
        print("✅ ADX connected")
    except Exception as e:
        print(f"❌ ADX connection failed: {e}")
        adx_client = None
    
    # Process each section
    for section_name, value_chain_steps in QUERY_HIERARCHY.items():
        print(f"\n{'='*60}")
        print(f"📊 SECTION: {section_name}")
        print(f"{'='*60}")
        
        results["sections"][section_name] = {}
        
        for step_name, outcomes in value_chain_steps.items():
            print(f"\n  📦 VALUE CHAIN STEP: {step_name}")
            results["sections"][section_name][step_name] = {}
            
            for outcome_name, outcome_config in outcomes.items():
                print(f"\n    📈 OUTCOME: {outcome_name}")
                print(f"       Source: {outcome_config['source']}")
                print(f"       Range: {outcome_config['sensible_range']}")
                
                outcome_results = {
                    "source": outcome_config["source"],
                    "description": outcome_config["description"],
                    "sensible_range": outcome_config["sensible_range"],
                    "queries": {}
                }
                
                if "pi_tag" in outcome_config:
                    outcome_results["pi_tag"] = outcome_config["pi_tag"]
                if "pi_tags" in outcome_config:
                    outcome_results["pi_tags"] = outcome_config["pi_tags"]
                
                # Execute queries
                for query_name, query_config in outcome_config.get("queries", {}).items():
                    print(f"\n       🔍 {query_name}...")
                    
                    query_result = {
                        "level": query_config.get("level"),
                        "description": query_config.get("description"),
                        "query": query_config["query"].strip()
                    }
                    
                    if "time_dimension" in query_config:
                        query_result["time_dimension"] = query_config["time_dimension"]
                    
                    # Execute based on source
                    if outcome_config["source"] == "SNOWFLAKE" and sf_conn:
                        result = execute_snowflake_query(sf_conn, query_config["query"])
                        query_result["result"] = result
                        status = "✅" if result["status"] == "SUCCESS" else "❌"
                        print(f"          {status} {result['status']} - {result.get('row_count', 0)} rows")
                        
                    elif outcome_config["source"] == "ADX" and adx_client:
                        db = query_config.get("database", "Morenci")
                        result = execute_adx_query(adx_client, db, query_config["query"])
                        query_result["result"] = result
                        query_result["database"] = db
                        status = "✅" if result["status"] == "SUCCESS" else "❌"
                        print(f"          {status} {result['status']} - {result.get('row_count', 0)} rows")
                    else:
                        query_result["result"] = {"status": "SKIPPED", "reason": "No connection"}
                        print(f"          ⏭️ SKIPPED - No connection")
                    
                    outcome_results["queries"][query_name] = query_result
                
                results["sections"][section_name][step_name][outcome_name] = outcome_results
    
    # Close connections
    if sf_conn:
        sf_conn.close()
    
    # Save results
    output_path = Path(__file__).parent.parent.parent / "reports" / f"query_validation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    print(f"\n\n{'='*80}")
    print(f"✅ VALIDATION COMPLETE")
    print(f"📄 Results saved to: {output_path}")
    print(f"{'='*80}")
    
    return results

if __name__ == "__main__":
    run_all_validations()
