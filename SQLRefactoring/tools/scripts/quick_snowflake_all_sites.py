"""
Quick Snowflake Validation - All Sites, All 10 Snowflake Outcomes
Generates sample data for each site to enrich the global model
"""
import os
import sys
import json
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

SITES = ["MOR", "BAG", "SAM", "CMX", "SIE", "NMO", "CVE"]

SNOWFLAKE_OUTCOMES = {
    "dig_compliance": """
SELECT SITE_CODE, COUNT(*) as total_dig_events, COUNT(DISTINCT EXCAV_ID) as active_shovels
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",
    
    "dig_rate": """
SELECT SITE_CODE, ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS), 2) as total_tons_12hr, COUNT(DISTINCT EXCAV_ID) as shovel_count
FROM prod_wg.load_haul.lh_loading_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "truck_count": """
SELECT SITE_CODE, COUNT(DISTINCT TRUCK_ID) as active_trucks, COUNT(*) as total_cycles
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "cycle_time": """
SELECT SITE_CODE, ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as avg_cycle_time_mins, COUNT(*) as total_cycles
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}'
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS > 0 AND TOTAL_CYCLE_DURATION_CALENDAR_MINS < 180
GROUP BY SITE_CODE""",

    "asset_efficiency": """
SELECT SITE_CODE, COUNT(DISTINCT TRUCK_ID) as unique_trucks, SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons, 
       ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT TRUCK_ID), 0), 2) as cycles_per_truck
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}'
GROUP BY SITE_CODE""",

    "dump_locations": """
SELECT SITE_CODE, DUMP_LOC_NAME, SUM(REPORT_PAYLOAD_SHORT_TONS) as total_tons
FROM prod_wg.load_haul.lh_haul_cycle
WHERE CYCLE_START_TS_LOCAL >= DATEADD(hour, -12, CURRENT_TIMESTAMP()) AND SITE_CODE = '{site}' AND DUMP_LOC_NAME IS NOT NULL
GROUP BY SITE_CODE, DUMP_LOC_NAME ORDER BY total_tons DESC LIMIT 5""",
}

def connect_snowflake():
    import snowflake.connector
    return snowflake.connector.connect(
        account='FCX-NA',
        authenticator='externalbrowser',
        user='ccarrill2@fmi.com',
        warehouse='WH_PROD_WG_DATENG',
        database='PROD_WG',
        schema='LOAD_HAUL'
    )

def run_query(conn, query):
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        columns = [col[0] for col in cursor.description]
        rows = cursor.fetchall()
        cursor.close()
        return [{col: str(val) if val is not None else None for col, val in zip(columns, row)} for row in rows]
    except Exception as e:
        return [{"error": str(e)}]

def main():
    print("=" * 80)
    print("SNOWFLAKE MULTI-SITE VALIDATION - Quick Summary")
    print("=" * 80)
    
    print("🔐 Connecting to Snowflake...")
    conn = connect_snowflake()
    print("✅ Connected\n")
    
    all_results = {"timestamp": datetime.now().isoformat(), "sites": {}}
    
    for site in SITES:
        print(f"\n📍 {site}:")
        site_results = {}
        
        for outcome_name, query_template in SNOWFLAKE_OUTCOMES.items():
            query = query_template.format(site=site)
            results = run_query(conn, query)
            has_data = len(results) > 0 and "error" not in results[0]
            
            site_results[outcome_name] = {
                "status": "SUCCESS" if has_data else "NO_DATA",
                "row_count": len(results) if has_data else 0,
                "sample": results[0] if has_data else None
            }
            
            status = "✅" if has_data else "⚠️"
            if has_data and results[0]:
                # Print key metric
                sample = results[0]
                if 'TOTAL_TONS_12HR' in sample:
                    print(f"   {status} {outcome_name}: {sample.get('TOTAL_TONS_12HR', 'N/A')} tons")
                elif 'ACTIVE_TRUCKS' in sample:
                    print(f"   {status} {outcome_name}: {sample.get('ACTIVE_TRUCKS', 'N/A')} trucks")
                elif 'AVG_CYCLE_TIME_MINS' in sample:
                    print(f"   {status} {outcome_name}: {sample.get('AVG_CYCLE_TIME_MINS', 'N/A')} min")
                elif 'TOTAL_DIG_EVENTS' in sample:
                    print(f"   {status} {outcome_name}: {sample.get('TOTAL_DIG_EVENTS', 'N/A')} events, {sample.get('ACTIVE_SHOVELS', 'N/A')} shovels")
                else:
                    print(f"   {status} {outcome_name}: {len(results)} rows")
            else:
                print(f"   {status} {outcome_name}: no data")
        
        all_results["sites"][site] = site_results
    
    conn.close()
    
    # Summary
    print("\n" + "=" * 80)
    print("SUMMARY BY SITE:")
    print("=" * 80)
    for site, data in all_results["sites"].items():
        success_count = sum(1 for v in data.values() if v["status"] == "SUCCESS")
        print(f"  {site}: {success_count}/{len(data)} outcomes with data")
    
    # Save results
    output_file = f"reports/snowflake_all_sites_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(output_file, 'w') as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"\n📄 Results saved to: {output_file}")

if __name__ == "__main__":
    main()
