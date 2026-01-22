"""
Stress Test: SENSOR_SNAPSHOT_GET - 3 Versions
==============================================
Runs multiple iterations to gather robust performance statistics.

Usage:
  python stress_test.py --iterations 10
"""

import argparse
import time
import os
import statistics
from datetime import datetime
import snowflake.connector
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import InteractiveBrowserCredential
from dotenv import load_dotenv

# -----------------------------------------------------------------------------
# Configuración
# -----------------------------------------------------------------------------
SNOWFLAKE_BASELINE_FUNC = "PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET"
SNOWFLAKE_REFACTOR_FUNC = "SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET"
ADX_CLUSTER = "https://fctsnaproddatexp02.westus2.kusto.windows.net"

# Test sensors (CR2_MILL)
TEST_SENSORS = ["CR03_CRUSH_OUT_TIME", "PE_MOR_CC_MflPileTonnage", "PE_MOR_CC_MillPileTonnage"]
SITE = "MOR"

def get_snowflake_connection():
    load_dotenv()
    return snowflake.connector.connect(
        account=os.getenv("CONN_LIB_SNOWFLAKE_ACCOUNT"),
        user=os.getenv("CONN_LIB_SNOWFLAKE_USER"),
        authenticator=os.getenv("CONN_LIB_SNOWFLAKE_AUTHENTICATOR", "externalbrowser"),
        role=os.getenv("CONN_LIB_SNOWFLAKE_ROLE"),
        warehouse=os.getenv("CONN_LIB_SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("CONN_LIB_SNOWFLAKE_DATABASE"),
        schema=os.getenv("CONN_LIB_SNOWFLAKE_SCHEMA"),
    )

def get_adx_client():
    credential = InteractiveBrowserCredential()
    kcs = KustoConnectionStringBuilder.with_azure_token_credential(ADX_CLUSTER, credential)
    return KustoClient(kcs)

def run_baseline(conn, sensors):
    """Run baseline Snowflake function"""
    sensors_str = ", ".join([f"'{s}'" for s in sensors])
    query = f"""
    SELECT TAG_NAME, VALUE_UTC_TS, SENSOR_VALUE, UOM, QUALITY
    FROM TABLE({SNOWFLAKE_BASELINE_FUNC}(
        '{SITE}', False, 
        array_construct(''),
        array_construct({sensors_str})
    ))
    """
    start = time.time()
    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    elapsed = time.time() - start
    cur.close()
    return elapsed, len(rows)

def run_refactor(conn, sensors):
    """Run refactored Snowflake function"""
    sensors_str = ", ".join([f"'{s}'" for s in sensors])
    query = f"""
    SELECT TAG_NAME, VALUE_UTC_TS, SENSOR_VALUE, UOM, QUALITY
    FROM TABLE({SNOWFLAKE_REFACTOR_FUNC}(
        '{SITE}', False, 
        array_construct(''),
        array_construct({sensors_str})
    ))
    """
    start = time.time()
    cur = conn.cursor()
    cur.execute(query)
    rows = cur.fetchall()
    elapsed = time.time() - start
    cur.close()
    return elapsed, len(rows)

def run_adx(client, sensors):
    """Run ADX query"""
    sensors_str = ", ".join([f'"{s}"' for s in sensors])
    query = f"""
    database('Morenci').FCTSCURRENT
    | where sensor_id in ({sensors_str})
    | project TAG_NAME = sensor_id, VALUE_UTC_TS = timestamp, 
              SENSOR_VALUE = value, UOM = uom, QUALITY = quality
    """
    start = time.time()
    response = client.execute("Morenci", query)
    rows = list(response.primary_results[0])
    elapsed = time.time() - start
    return elapsed, len(rows)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--iterations", type=int, default=10, help="Number of test iterations")
    parser.add_argument("--skip-baseline", action="store_true", help="Skip baseline (slow)")
    args = parser.parse_args()

    print(f"\n{'='*60}")
    print(f"STRESS TEST - SENSOR_SNAPSHOT_GET")
    print(f"Iterations: {args.iterations}")
    print(f"Sensors: {TEST_SENSORS}")
    print(f"{'='*60}\n")

    # Initialize connections
    print("Connecting to Snowflake...")
    sf_conn = get_snowflake_connection()
    
    print("Connecting to ADX...")
    adx_client = get_adx_client()

    # Results storage
    baseline_times = []
    refactor_times = []
    adx_times = []

    print(f"\nRunning {args.iterations} iterations...\n")
    print(f"{'Iter':<6} {'Baseline':<12} {'Refactor':<12} {'ADX':<12}")
    print("-" * 42)

    for i in range(1, args.iterations + 1):
        # Baseline
        if not args.skip_baseline:
            b_time, b_rows = run_baseline(sf_conn, TEST_SENSORS)
            baseline_times.append(b_time)
            b_str = f"{b_time:.2f}s"
        else:
            b_str = "skipped"

        # Refactor
        r_time, r_rows = run_refactor(sf_conn, TEST_SENSORS)
        refactor_times.append(r_time)

        # ADX
        a_time, a_rows = run_adx(adx_client, TEST_SENSORS)
        adx_times.append(a_time)

        print(f"{i:<6} {b_str:<12} {r_time:.2f}s ({r_rows}r)  {a_time:.2f}s ({a_rows}r)")

    # Summary statistics
    print(f"\n{'='*60}")
    print("SUMMARY STATISTICS")
    print(f"{'='*60}\n")

    def stats(times, name):
        if not times:
            return
        print(f"{name}:")
        print(f"  Min:    {min(times):.2f}s")
        print(f"  Max:    {max(times):.2f}s")
        print(f"  Mean:   {statistics.mean(times):.2f}s")
        print(f"  Median: {statistics.median(times):.2f}s")
        if len(times) > 1:
            print(f"  StdDev: {statistics.stdev(times):.2f}s")
        print()

    if baseline_times:
        stats(baseline_times, "BASELINE (Snowflake original)")
    stats(refactor_times, "REFACTOR (Snowflake optimized)")
    stats(adx_times, "ADX")

    # Speedup comparison
    print(f"{'='*60}")
    print("SPEEDUP COMPARISON")
    print(f"{'='*60}\n")

    if baseline_times:
        b_mean = statistics.mean(baseline_times)
        r_mean = statistics.mean(refactor_times)
        a_mean = statistics.mean(adx_times)
        
        print(f"Refactor vs Baseline: {b_mean/r_mean:.1f}x faster ({b_mean:.1f}s → {r_mean:.1f}s)")
        print(f"ADX vs Baseline:      {b_mean/a_mean:.1f}x faster ({b_mean:.1f}s → {a_mean:.1f}s)")
        print(f"ADX vs Refactor:      {r_mean/a_mean:.1f}x faster ({r_mean:.1f}s → {a_mean:.1f}s)")
    else:
        r_mean = statistics.mean(refactor_times)
        a_mean = statistics.mean(adx_times)
        print(f"ADX vs Refactor: {r_mean/a_mean:.1f}x faster ({r_mean:.1f}s → {a_mean:.1f}s)")

    # CSV output
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    csv_file = f"stress_test_results_{timestamp}.csv"
    
    with open(csv_file, "w") as f:
        f.write("iteration,baseline_sec,refactor_sec,adx_sec\n")
        for i in range(len(refactor_times)):
            b = baseline_times[i] if baseline_times else ""
            f.write(f"{i+1},{b},{refactor_times[i]:.3f},{adx_times[i]:.3f}\n")
    
    print(f"\nResults saved to: {csv_file}")

    sf_conn.close()

if __name__ == "__main__":
    main()
