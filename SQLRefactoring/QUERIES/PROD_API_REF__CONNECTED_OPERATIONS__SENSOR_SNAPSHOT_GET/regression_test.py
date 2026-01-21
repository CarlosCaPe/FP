"""
Regression Test: SENSOR_SNAPSHOT_GET - 3 Versions
==================================================
Compara las 3 versiones de la función:
  1. Baseline (Snowflake original) - PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET
  2. Refactor (Snowflake optimizado) - SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET
  3. ADX Function - database('Morenci').FCTSCURRENT

Output:
  - Tiempos de ejecución
  - Columnas (deben ser iguales)
  - Row counts (pueden variar por timing)
  - Muestra de datos

Requiere:
  pip install snowflake-connector-python azure-kusto-data azure-identity pandas tabulate

Uso:
  python regression_test.py --site MOR --sensors "sensor1,sensor2"
"""

import argparse
import time
from datetime import datetime
from pathlib import Path
import pandas as pd
from tabulate import tabulate

# -----------------------------------------------------------------------------
# Configuración
# -----------------------------------------------------------------------------

# Snowflake
SNOWFLAKE_BASELINE_FUNC = "PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET"
SNOWFLAKE_REFACTOR_FUNC = "SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET"

# ADX
ADX_CLUSTER = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
SITE_TO_DATABASE = {
    "SAM": "Miami",
    "MOR": "Morenci",
    "CMX": "Climax",
    "SIE": "Sierrita",
    "NMO": "NewMexico",
    "BAG": "Bagdad",
    "CVE": "CerroVerde",
}

# Expected columns
EXPECTED_COLUMNS = ["TAG_NAME", "VALUE_UTC_TS", "SENSOR_VALUE", "UOM", "QUALITY"]


def get_snowflake_connection():
    """Crea conexión a Snowflake usando variables de entorno."""
    import os
    from dotenv import load_dotenv
    import snowflake.connector
    
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


def get_kusto_client():
    """Crea cliente Kusto con autenticación de browser."""
    from azure.identity import InteractiveBrowserCredential
    from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
    
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(ADX_CLUSTER, credential)
    return KustoClient(kcsb)


def run_snowflake_query(conn, func_name: str, site_code: str, sensors: list[str]) -> tuple[pd.DataFrame, float]:
    """Ejecuta query en Snowflake y retorna DataFrame + tiempo."""
    sensors_array = ", ".join([f"'{s}'" for s in sensors])
    query = f"""
    SELECT * FROM TABLE({func_name}(
        '{site_code}',
        FALSE,
        ARRAY_CONSTRUCT(''),
        ARRAY_CONSTRUCT({sensors_array})
    ))
    """
    
    cursor = conn.cursor()
    start = time.perf_counter()
    cursor.execute(query)
    rows = cursor.fetchall()
    elapsed = time.perf_counter() - start
    
    columns = [desc[0] for desc in cursor.description]
    df = pd.DataFrame(rows, columns=columns)
    cursor.close()
    
    return df, elapsed


def run_adx_query(client, site_code: str, sensors: list[str]) -> tuple[pd.DataFrame, float]:
    """Ejecuta query en ADX y retorna DataFrame + tiempo."""
    database = SITE_TO_DATABASE.get(site_code.upper())
    if not database:
        raise ValueError(f"Site code '{site_code}' no reconocido")
    
    sensor_list = ", ".join([f"'{s}'" for s in sensors])
    query = f"""
    FCTSCURRENT
    | where sensor_id in ({sensor_list})
    | project 
        TAG_NAME = sensor_id,
        VALUE_UTC_TS = timestamp,
        SENSOR_VALUE = tostring(value),
        UOM = uom,
        QUALITY = quality
    """
    
    start = time.perf_counter()
    response = client.execute(database, query)
    elapsed = time.perf_counter() - start
    
    rows = []
    for row in response.primary_results[0]:
        rows.append({
            "TAG_NAME": row["TAG_NAME"],
            "VALUE_UTC_TS": row["VALUE_UTC_TS"],
            "SENSOR_VALUE": row["SENSOR_VALUE"],
            "UOM": row["UOM"],
            "QUALITY": row["QUALITY"],
        })
    
    return pd.DataFrame(rows), elapsed


def compare_schemas(dfs: dict[str, pd.DataFrame]) -> dict:
    """Compara schemas de los DataFrames."""
    schemas = {}
    for name, df in dfs.items():
        schemas[name] = list(df.columns)
    
    # Check if all schemas match expected
    results = {
        "expected": EXPECTED_COLUMNS,
        "versions": schemas,
        "all_match": all(list(df.columns) == EXPECTED_COLUMNS for df in dfs.values())
    }
    return results


def generate_report(results: dict, output_path: Path = None):
    """Genera reporte de comparación."""
    report = []
    report.append("=" * 80)
    report.append("REGRESSION TEST: SENSOR_SNAPSHOT_GET - 3 Versions")
    report.append(f"Generated: {datetime.now().isoformat()}")
    report.append("=" * 80)
    report.append("")
    
    # Test parameters
    report.append("## Test Parameters")
    report.append(f"- Site: {results['site_code']}")
    report.append(f"- Sensors: {results['sensors']}")
    report.append("")
    
    # Timing comparison
    report.append("## Timing Comparison")
    timing_data = [
        ["1. Baseline (Snowflake)", f"{results['baseline']['time']:.3f}s", results['baseline']['rows']],
        ["2. Refactor (Snowflake)", f"{results['refactor']['time']:.3f}s", results['refactor']['rows']],
        ["3. ADX Function", f"{results['adx']['time']:.3f}s", results['adx']['rows']],
    ]
    report.append(tabulate(timing_data, headers=["Version", "Time", "Rows"], tablefmt="pipe"))
    report.append("")
    
    # Speedup
    baseline_time = results['baseline']['time']
    refactor_time = results['refactor']['time']
    adx_time = results['adx']['time']
    
    report.append("## Speedup Analysis")
    report.append(f"- Refactor vs Baseline: {baseline_time/refactor_time:.2f}x faster")
    report.append(f"- ADX vs Baseline: {baseline_time/adx_time:.2f}x faster")
    report.append(f"- ADX vs Refactor: {refactor_time/adx_time:.2f}x faster")
    report.append("")
    
    # Schema comparison
    report.append("## Schema Comparison")
    schema_results = results['schema_comparison']
    report.append(f"- Expected columns: {schema_results['expected']}")
    report.append(f"- All schemas match: {'✅ YES' if schema_results['all_match'] else '❌ NO'}")
    for name, cols in schema_results['versions'].items():
        status = "✅" if cols == EXPECTED_COLUMNS else "❌"
        report.append(f"  - {name}: {status} {cols}")
    report.append("")
    
    # Sample data
    report.append("## Sample Data (first 5 rows from each)")
    for name in ['baseline', 'refactor', 'adx']:
        report.append(f"\n### {name.upper()}")
        df = results[name]['df']
        if len(df) > 0:
            report.append(tabulate(df.head(), headers='keys', tablefmt='pipe', showindex=False))
        else:
            report.append("(no rows)")
    
    report_text = "\n".join(report)
    
    if output_path:
        output_path.write_text(report_text)
        print(f"Report saved to: {output_path}")
    
    return report_text


def main():
    parser = argparse.ArgumentParser(description="Regression test for SENSOR_SNAPSHOT_GET (3 versions)")
    parser.add_argument("--site", "-s", required=True, choices=list(SITE_TO_DATABASE.keys()), help="Site code")
    parser.add_argument("--sensors", "-n", required=True, help="Comma-separated sensor IDs")
    parser.add_argument("--output", "-o", help="Output report path (optional)")
    parser.add_argument("--skip-baseline", action="store_true", help="Skip baseline (slow)")
    parser.add_argument("--skip-adx", action="store_true", help="Skip ADX (if no access)")
    
    args = parser.parse_args()
    sensors = [s.strip() for s in args.sensors.split(",")]
    
    print(f"Site: {args.site}")
    print(f"Sensors: {sensors}")
    print()
    
    results = {
        "site_code": args.site,
        "sensors": sensors,
        "baseline": {"time": 0, "rows": 0, "df": pd.DataFrame()},
        "refactor": {"time": 0, "rows": 0, "df": pd.DataFrame()},
        "adx": {"time": 0, "rows": 0, "df": pd.DataFrame()},
    }
    
    # 1. Snowflake Baseline
    if not args.skip_baseline:
        print("1. Running BASELINE (Snowflake original)...")
        try:
            conn = get_snowflake_connection()
            df, elapsed = run_snowflake_query(conn, SNOWFLAKE_BASELINE_FUNC, args.site, sensors)
            results['baseline'] = {"time": elapsed, "rows": len(df), "df": df}
            print(f"   ✅ {len(df)} rows in {elapsed:.3f}s")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    else:
        print("1. BASELINE skipped")
    
    # 2. Snowflake Refactor
    print("2. Running REFACTOR (Snowflake optimizado)...")
    try:
        conn = get_snowflake_connection()
        df, elapsed = run_snowflake_query(conn, SNOWFLAKE_REFACTOR_FUNC, args.site, sensors)
        results['refactor'] = {"time": elapsed, "rows": len(df), "df": df}
        print(f"   ✅ {len(df)} rows in {elapsed:.3f}s")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # 3. ADX Function
    if not args.skip_adx:
        print("3. Running ADX Function...")
        try:
            client = get_kusto_client()
            df, elapsed = run_adx_query(client, args.site, sensors)
            results['adx'] = {"time": elapsed, "rows": len(df), "df": df}
            print(f"   ✅ {len(df)} rows in {elapsed:.3f}s")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    else:
        print("3. ADX skipped")
    
    # Compare schemas
    dfs_to_compare = {
        name: results[name]['df'] 
        for name in ['baseline', 'refactor', 'adx'] 
        if len(results[name]['df']) > 0
    }
    results['schema_comparison'] = compare_schemas(dfs_to_compare)
    
    # Generate report
    print()
    output_path = Path(args.output) if args.output else None
    report = generate_report(results, output_path)
    print(report)


if __name__ == "__main__":
    main()
