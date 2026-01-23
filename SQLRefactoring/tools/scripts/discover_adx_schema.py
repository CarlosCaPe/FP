"""
ADX Schema Discovery - Find correct column names for FCTS functions
"""
import os
from dotenv import load_dotenv
load_dotenv()

from azure.identity import InteractiveBrowserCredential
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder

CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
credential = InteractiveBrowserCredential()
kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER_URL, credential)
client = KustoClient(kcsb)

# Test query to see column names
queries = [
    ("FCTSCURRENT() | take 5", "Get FCTSCURRENT columns"),
    ("FCTS() | take 5", "Get FCTS columns"),
    ("FCTSCURRENT() | getschema", "Get FCTSCURRENT schema"),
    ("FCTS() | getschema", "Get FCTS schema"),
]

for query, desc in queries:
    print(f"\n{'='*60}")
    print(f"{desc}")
    print(f"Query: {query}")
    print(f"{'='*60}")
    try:
        response = client.execute("Morenci", query)
        columns = [col.column_name for col in response.primary_results[0].columns]
        print(f"Columns: {columns}")
        rows = list(response.primary_results[0])[:3]
        for row in rows:
            print(dict(zip(columns, [str(v) for v in row])))
    except Exception as e:
        print(f"Error: {e}")
