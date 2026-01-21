"""
ADX/KQL Discovery Helper - Browser Authentication
Cluster: fctsnaproddatexp01.westus2.kusto.windows.net

Databases por sitio:
- BAG, SAM, MOR, CMX, SIE, NMO, CVE
- Global (Registry)

Queries de ejemplo:
1. Current Value: database('BAG').FCTSCURRENT | where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
2. Historical:    database('BAG').FCTS | where timestamp > ago(180d) | where sensor_id == "..."
3. Registry:      database('Global').RegistryStreams | where sensor_id == "..."
"""
import argparse
from dataclasses import dataclass
from typing import Iterable

from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import InteractiveBrowserCredential


@dataclass(frozen=True)
class AdxCluster:
    uri: str
    mgmt_db: str = "Global"


# FCTS Production cluster
DEFAULT_CLUSTER = AdxCluster(
    uri="https://fctsnaproddatexp01.westus2.kusto.windows.net",
    mgmt_db="Global"
)

# Sitios disponibles
SITES = ["BAG", "SAM", "MOR", "CMX", "SIE", "NMO", "CVE"]


def make_client(cluster_uri: str) -> KustoClient:
    """Create KQL client with browser-based auth (like SQL Azure/Snowflake)"""
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster_uri, credential)
    return KustoClient(kcsb)


def print_rows(result) -> None:
    primary = result.primary_results[0]
    for row in primary:
        print("\t".join(str(v) for v in row))


def show_databases(client: KustoClient, cluster: AdxCluster) -> None:
    """List all databases in the cluster"""
    result = client.execute_mgmt(cluster.mgmt_db, ".show databases")
    print("=" * 80)
    print("DATABASES IN CLUSTER:", cluster.uri)
    print("=" * 80)
    print_rows(result)


def show_tables(client: KustoClient, database: str) -> None:
    """List all tables in a database"""
    result = client.execute_mgmt(database, ".show tables")
    print("=" * 80)
    print(f"TABLES IN DATABASE: {database}")
    print("=" * 80)
    print_rows(result)


def run_kql(client: KustoClient, database: str, kql: str) -> None:
    """Execute a KQL query"""
    print("=" * 80)
    print(f"QUERY: {kql[:100]}...")
    print("=" * 80)
    result = client.execute(database, kql)
    print_rows(result)


def show_schema(client: KustoClient, database: str, table: str) -> None:
    """Show schema of a table"""
    kql = f".show table {table} schema as json"
    result = client.execute_mgmt(database, kql)
    print("=" * 80)
    print(f"SCHEMA: {database}.{table}")
    print("=" * 80)
    print_rows(result)


def sample_query(client: KustoClient, database: str, table: str, limit: int = 10) -> None:
    """Sample rows from a table"""
    kql = f"{table} | take {limit}"
    print("=" * 80)
    print(f"SAMPLE: {database}.{table} (limit {limit})")
    print("=" * 80)
    result = client.execute(database, kql)
    print_rows(result)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="ADX/KQL Discovery Helper (browser auth)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python adx_browser.py list-dbs
  python adx_browser.py list-tables --db BAG
  python adx_browser.py sample --db BAG --table FCTS --limit 5
  python adx_browser.py query --db BAG --kql "FCTSCURRENT | where sensor_id == 'BAG-REPT_CLP_CYANEX_VOL' | take 10"
  python adx_browser.py schema --db BAG --table FCTS
        """
    )
    parser.add_argument(
        "--cluster",
        default=DEFAULT_CLUSTER.uri,
        help="ADX cluster URI",
    )
    parser.add_argument(
        "--mgmt-db",
        default=DEFAULT_CLUSTER.mgmt_db,
        help="Database for mgmt commands",
    )

    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list-dbs", help="List databases in the cluster")

    p_tables = sub.add_parser("list-tables", help="List tables for a database")
    p_tables.add_argument("--db", required=True, choices=SITES + ["Global"], help="Database name")

    p_query = sub.add_parser("query", help="Run a KQL query")
    p_query.add_argument("--db", required=True, help="Database name")
    p_query.add_argument("--kql", required=True, help="KQL to execute")

    p_sample = sub.add_parser("sample", help="Sample rows from a table")
    p_sample.add_argument("--db", required=True, help="Database name")
    p_sample.add_argument("--table", required=True, help="Table name (e.g., FCTS, FCTSCURRENT)")
    p_sample.add_argument("--limit", type=int, default=10, help="Number of rows")

    p_schema = sub.add_parser("schema", help="Show table schema")
    p_schema.add_argument("--db", required=True, help="Database name")
    p_schema.add_argument("--table", required=True, help="Table name")

    args = parser.parse_args(list(argv) if argv is not None else None)

    cluster = AdxCluster(uri=args.cluster, mgmt_db=args.mgmt_db)
    
    print(f"Connecting to: {cluster.uri}")
    client = make_client(cluster.uri)

    if args.cmd == "list-dbs":
        show_databases(client, cluster)
        return 0

    if args.cmd == "list-tables":
        show_tables(client, args.db)
        return 0

    if args.cmd == "query":
        run_kql(client, args.db, args.kql)
        return 0

    if args.cmd == "sample":
        sample_query(client, args.db, args.table, args.limit)
        return 0

    if args.cmd == "schema":
        show_schema(client, args.db, args.table)
        return 0

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
