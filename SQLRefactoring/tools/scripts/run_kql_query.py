"""
Quick KQL Query Runner for ADX
Usage: python run_kql_query.py
"""

from azure.identity import InteractiveBrowserCredential
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder

CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"

def get_kusto_client() -> KustoClient:
    """Create Kusto client with browser authentication (SSO)."""
    print(f"🔐 Connecting to {CLUSTER_URL}...")
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(
        CLUSTER_URL, credential
    )
    return KustoClient(kcsb)

def execute_query(client: KustoClient, database: str, query: str) -> list[dict]:
    """Execute KQL query and return results as list of dicts."""
    try:
        response = client.execute(database, query)
        columns = [col.column_name for col in response.primary_results[0].columns]
        return [dict(zip(columns, row)) for row in response.primary_results[0]]
    except Exception as e:
        print(f"⚠️ Error: {e}")
        return []

# Mill IOS Query with Direction of Change
# FIXED: prev() requires direct column reference, not expressions
KQL_QUERY = """
// Mill IOS Level with Direction of Change
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
        "→ STABLE")
| project sensor_id, current_level, direction, timestamp
"""

if __name__ == "__main__":
    print("=" * 60)
    print("Mill IOS Query - Testing KQL Syntax")
    print("=" * 60)
    
    client = get_kusto_client()
    print("✅ Connected to ADX\n")
    
    print("🔍 Running query...")
    print("-" * 60)
    
    results = execute_query(client, "Morenci", KQL_QUERY)
    
    if results:
        print(f"\n✅ Query returned {len(results)} rows:\n")
        for row in results:
            print(f"  sensor_id: {row.get('sensor_id')}")
            print(f"  current_level: {row.get('current_level')}")
            print(f"  direction: {row.get('direction')}")
            print(f"  timestamp: {row.get('timestamp')}")
            print("-" * 40)
    else:
        print("\n⚠️ No results or query failed")
    
    print("\n" + "=" * 60)
