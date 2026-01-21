import argparse
from dataclasses import dataclass
import datetime as _dt
import subprocess
import webbrowser
from typing import Iterable

from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import DeviceCodeCredential


@dataclass(frozen=True)
class AdxCluster:
    # Example: https://fctsnaproddatexp01.westus2.kusto.windows.net
    uri: str
    # Any database that exists in the cluster; used to run cluster-level mgmt commands.
    mgmt_db: str = "Global"


DEFAULT_CLUSTER = AdxCluster(uri="https://fctsnaproddatexp01.westus2.kusto.windows.net", mgmt_db="Global")


def make_client(cluster_uri: str) -> KustoClient:
    def prompt(verification_uri: str, user_code: str, expires_on: _dt.datetime) -> None:
        msg = (
            f"To sign in, open {verification_uri} and enter the code {user_code}. "
            f"(expires {expires_on})"
        )
        print(msg, flush=True)

        # Best-effort: open default browser.
        try:
            webbrowser.open(verification_uri, new=1)
        except Exception:
            pass

        # Best-effort: copy code to clipboard on Windows.
        try:
            subprocess.run(
                [
                    "powershell",
                    "-NoProfile",
                    "-Command",
                    f"Set-Clipboard -Value '{user_code}'",
                ],
                check=False,
                capture_output=True,
                text=True,
            )
        except Exception:
            pass

    # Device code login (interactive).
    credential = DeviceCodeCredential(prompt_callback=prompt, timeout=900)
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster_uri, credential)
    return KustoClient(kcsb)


def print_rows(result) -> None:
    primary = result.primary_results[0]
    for row in primary:
        print("\t".join(str(v) for v in row))


def show_databases(client: KustoClient, cluster: AdxCluster) -> None:
    # Cluster-level command; still requires a database context.
    result = client.execute_mgmt(cluster.mgmt_db, ".show databases")
    print_rows(result)


def show_tables(client: KustoClient, database: str) -> None:
    result = client.execute_mgmt(database, ".show tables")
    print_rows(result)


def run_kql(client: KustoClient, database: str, kql: str) -> None:
    result = client.execute(database, kql)
    print_rows(result)


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="ADX discovery helper (device code auth).")
    parser.add_argument(
        "--cluster",
        default=DEFAULT_CLUSTER.uri,
        help="ADX cluster URI (e.g. https://<cluster>.<region>.kusto.windows.net)",
    )
    parser.add_argument(
        "--mgmt-db",
        default=DEFAULT_CLUSTER.mgmt_db,
        help="Database context for cluster-level mgmt commands (e.g. Global)",
    )

    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list-dbs", help="List databases in the cluster")

    p_tables = sub.add_parser("list-tables", help="List tables for a database")
    p_tables.add_argument("--db", required=True, help="Database name (e.g. BAG)")

    p_query = sub.add_parser("query", help="Run a KQL query")
    p_query.add_argument("--db", required=True, help="Database name (e.g. BAG)")
    p_query.add_argument("--kql", required=True, help="KQL to execute")

    args = parser.parse_args(list(argv) if argv is not None else None)

    cluster = AdxCluster(uri=args.cluster, mgmt_db=args.mgmt_db)
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

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
