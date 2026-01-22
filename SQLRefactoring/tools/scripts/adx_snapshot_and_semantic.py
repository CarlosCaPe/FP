"""
ADX Snapshot Extractor & Semantic Model Generator
==================================================
Extrae metadata de todas las bases de datos ADX del cluster FCTS y genera
semantic models en formato YAML para cada database.

Cluster: fctsnaproddatexp02.westus2.kusto.windows.net

Bases de datos:
    - Miami (SAM)
    - Morenci (MOR)
    - Climax (CMX)
    - Sierrita (SIE)
    - NewMexico (NMO)
    - Bagdad (BAG)
    - CerroVerde (CVE)
    - Global (Registry)
    - AppIntegration

Output:
    - adx_snapshots/<database>_snapshot.json - Metadata completa
    - adx_semantic_models/<database>.semantic.yaml - Semantic model

Uso:
    python adx_snapshot_and_semantic.py                  # Todas las bases
    python adx_snapshot_and_semantic.py --databases MOR BAG  # Solo algunas
    python adx_snapshot_and_semantic.py --skip-snapshot  # Solo generar YAML
"""

import argparse
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Any

from azure.identity import InteractiveBrowserCredential
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
import yaml

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"

# Mapeo completo de databases
DATABASES = {
    "Miami": {"site_code": "SAM", "description": "Miami site sensor data"},
    "Morenci": {"site_code": "MOR", "description": "Morenci site sensor data"},
    "Climax": {"site_code": "CMX", "description": "Climax site sensor data"},
    "Sierrita": {"site_code": "SIE", "description": "Sierrita site sensor data"},
    "NewMexico": {"site_code": "NMO", "description": "New Mexico site sensor data"},
    "Bagdad": {"site_code": "BAG", "description": "Bagdad site sensor data"},
    "CerroVerde": {"site_code": "CVE", "description": "Cerro Verde site sensor data"},
    "Global": {"site_code": None, "description": "Global registry and metadata"},
    "AppIntegration": {"site_code": None, "description": "Application integration functions"},
}

# Core tables to extract schema
CORE_TABLES = ["FCTS", "FCTSCURRENT"]

# Output directories (relative to script location)
SCRIPT_DIR = Path(__file__).parent
OUTPUT_BASE = SCRIPT_DIR.parent.parent  # SQLRefactoring root
SNAPSHOT_DIR = OUTPUT_BASE / "adx_snapshots"
SEMANTIC_DIR = OUTPUT_BASE / "adx_semantic_models"


def get_kusto_client() -> KustoClient:
    """Create Kusto client with browser authentication (SSO)."""
    print(f"🔐 Connecting to {CLUSTER_URL}...")
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(
        CLUSTER_URL, credential
    )
    return KustoClient(kcsb)


def execute_mgmt(client: KustoClient, database: str, command: str) -> list[dict]:
    """Execute management command and return results as list of dicts."""
    try:
        response = client.execute_mgmt(database, command)
        columns = [col.column_name for col in response.primary_results[0].columns]
        return [dict(zip(columns, row)) for row in response.primary_results[0]]
    except Exception as e:
        print(f"    ⚠️ Error: {e}")
        return []


def execute_query(client: KustoClient, database: str, query: str) -> list[dict]:
    """Execute KQL query and return results as list of dicts."""
    try:
        response = client.execute(database, query)
        columns = [col.column_name for col in response.primary_results[0].columns]
        return [dict(zip(columns, row)) for row in response.primary_results[0]]
    except Exception as e:
        print(f"    ⚠️ Error: {e}")
        return []


def get_tables(client: KustoClient, database: str) -> list[dict]:
    """Get list of tables in database."""
    return execute_mgmt(client, database, ".show tables")


def get_functions(client: KustoClient, database: str) -> list[dict]:
    """Get list of functions in database."""
    return execute_mgmt(client, database, ".show functions")


def get_table_schema(client: KustoClient, database: str, table: str) -> list[dict]:
    """Get column schema for a table."""
    result = execute_mgmt(client, database, f".show table {table} schema as csl")
    if result:
        schema_str = result[0].get("Schema", "")
        columns = []
        for col_def in schema_str.split(","):
            col_def = col_def.strip()
            if ":" in col_def:
                parts = col_def.split(":")
                columns.append({
                    "name": parts[0].strip(),
                    "type": parts[1].strip() if len(parts) > 1 else "unknown"
                })
        return columns
    return []


def get_table_stats(client: KustoClient, database: str, table: str) -> dict:
    """Get table statistics (row count, extent count, etc.)."""
    result = execute_mgmt(client, database, f".show table {table} details")
    if result:
        return {
            "total_extents": result[0].get("TotalExtents", 0),
            "total_original_size": result[0].get("TotalOriginalSize", 0),
            "total_row_count": result[0].get("TotalRowCount", 0),
        }
    return {}


def get_function_body(client: KustoClient, database: str, function_name: str) -> str:
    """Get function body/definition."""
    result = execute_mgmt(client, database, f".show function {function_name}")
    if result:
        return result[0].get("Body", "")
    return ""


def sample_data(client: KustoClient, database: str, table: str, limit: int = 5) -> list[dict]:
    """Get sample data from table."""
    return execute_query(client, database, f"{table} | take {limit}")


def extract_database_snapshot(client: KustoClient, database: str) -> dict:
    """Extract complete snapshot of a database."""
    print(f"\n📦 Extracting: {database}")
    
    snapshot = {
        "database": database,
        "cluster": CLUSTER_URL,
        "extracted_at": datetime.now().isoformat(),
        "site_code": DATABASES.get(database, {}).get("site_code"),
        "description": DATABASES.get(database, {}).get("description"),
        "tables": [],
        "functions": [],
    }
    
    # Get tables
    print(f"  📋 Fetching tables...")
    tables = get_tables(client, database)
    for table_info in tables:
        table_name = table_info.get("TableName", "")
        if not table_name:
            continue
            
        print(f"    → {table_name}")
        table_data = {
            "name": table_name,
            "folder": table_info.get("Folder", ""),
            "doc_string": table_info.get("DocString", ""),
            "columns": get_table_schema(client, database, table_name),
            "stats": get_table_stats(client, database, table_name),
        }
        
        # Sample data only for core tables
        if table_name in CORE_TABLES:
            table_data["sample_data"] = sample_data(client, database, table_name, 3)
        
        snapshot["tables"].append(table_data)
    
    # Get functions
    print(f"  📐 Fetching functions...")
    functions = get_functions(client, database)
    for func_info in functions:
        func_name = func_info.get("Name", "")
        if not func_name:
            continue
            
        print(f"    → {func_name}")
        func_data = {
            "name": func_name,
            "folder": func_info.get("Folder", ""),
            "doc_string": func_info.get("DocString", ""),
            "parameters": func_info.get("Parameters", ""),
            "body": get_function_body(client, database, func_name),
        }
        snapshot["functions"].append(func_data)
    
    return snapshot


def generate_semantic_model(snapshot: dict) -> dict:
    """Generate semantic model YAML structure from snapshot."""
    database = snapshot["database"]
    site_code = snapshot.get("site_code")
    
    model = {
        "semantic_model": {
            "name": f"ADX_{database}",
            "description": snapshot.get("description", f"Semantic model for ADX {database} database"),
            "cluster": CLUSTER_URL,
            "database": database,
            "site_code": site_code,
            "updated_at": datetime.now().isoformat(),
        },
        "entities": [],
        "measures": [],
        "dimensions": [],
    }
    
    # Process tables into entities
    for table in snapshot.get("tables", []):
        table_name = table["name"]
        
        entity = {
            "name": table_name,
            "description": table.get("doc_string", f"ADX table {table_name}"),
            "source": {
                "type": "adx_table",
                "database": database,
                "table": table_name,
            },
            "columns": [],
            "primary_key": None,
        }
        
        # Process columns
        for col in table.get("columns", []):
            col_name = col["name"]
            col_type = col["type"]
            
            column_def = {
                "name": col_name,
                "type": map_kusto_type_to_semantic(col_type),
                "kusto_type": col_type,
            }
            
            # Identify common patterns
            if col_name.lower() in ("sensor_id", "tag_name", "id"):
                entity["primary_key"] = col_name
                column_def["is_key"] = True
            elif "timestamp" in col_name.lower() or col_name.lower() in ("ts", "time"):
                column_def["is_temporal"] = True
            elif col_name.lower() in ("value", "sensor_value"):
                column_def["is_measure"] = True
            
            entity["columns"].append(column_def)
        
        # Add row count if available
        if table.get("stats", {}).get("total_row_count"):
            entity["approximate_row_count"] = table["stats"]["total_row_count"]
        
        model["entities"].append(entity)
    
    # Process functions
    for func in snapshot.get("functions", []):
        func_def = {
            "name": func["name"],
            "description": func.get("doc_string", ""),
            "parameters": func.get("parameters", ""),
            "folder": func.get("folder", ""),
        }
        if "measures" not in model:
            model["functions"] = []
        if "functions" not in model:
            model["functions"] = []
        model["functions"].append(func_def)
    
    # Generate standard measures for sensor tables
    if site_code:
        model["measures"] = generate_sensor_measures(database, site_code)
        model["dimensions"] = generate_sensor_dimensions(database, site_code)
    
    return model


def map_kusto_type_to_semantic(kusto_type: str) -> str:
    """Map Kusto data types to semantic model types."""
    type_map = {
        "string": "string",
        "int": "integer",
        "long": "bigint",
        "real": "double",
        "bool": "boolean",
        "datetime": "timestamp",
        "timespan": "duration",
        "guid": "uuid",
        "dynamic": "json",
        "decimal": "decimal",
    }
    return type_map.get(kusto_type.lower(), "string")


def generate_sensor_measures(database: str, site_code: str) -> list[dict]:
    """Generate standard measures for sensor data."""
    return [
        {
            "name": "current_sensor_value",
            "description": f"Current value from FCTSCURRENT for {site_code}",
            "expression": "FCTSCURRENT | summarize Value=take_any(value) by sensor_id",
            "type": "aggregate",
        },
        {
            "name": "sensor_avg_24h",
            "description": f"24-hour average sensor value for {site_code}",
            "expression": "FCTS | where timestamp > ago(24h) | summarize AvgValue=avg(value) by sensor_id",
            "type": "aggregate",
        },
        {
            "name": "sensor_max_24h",
            "description": f"24-hour maximum sensor value for {site_code}",
            "expression": "FCTS | where timestamp > ago(24h) | summarize MaxValue=max(value) by sensor_id",
            "type": "aggregate",
        },
        {
            "name": "sensor_min_24h",
            "description": f"24-hour minimum sensor value for {site_code}",
            "expression": "FCTS | where timestamp > ago(24h) | summarize MinValue=min(value) by sensor_id",
            "type": "aggregate",
        },
        {
            "name": "sensor_reading_count_24h",
            "description": f"Count of readings in last 24 hours for {site_code}",
            "expression": "FCTS | where timestamp > ago(24h) | summarize Count=count() by sensor_id",
            "type": "aggregate",
        },
    ]


def generate_sensor_dimensions(database: str, site_code: str) -> list[dict]:
    """Generate standard dimensions for sensor data."""
    return [
        {
            "name": "sensor_id",
            "description": "Unique sensor identifier / PI Point name",
            "source_column": "sensor_id",
        },
        {
            "name": "timestamp",
            "description": "Reading timestamp (UTC)",
            "source_column": "timestamp",
            "time_grain": ["minute", "hour", "day", "week", "month"],
        },
        {
            "name": "quality",
            "description": "Data quality indicator",
            "source_column": "quality",
        },
        {
            "name": "unit",
            "description": "Unit of measure",
            "source_column": "uom",
        },
    ]


def save_snapshot(snapshot: dict, output_dir: Path) -> Path:
    """Save snapshot to JSON file."""
    output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{snapshot['database']}_snapshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    filepath = output_dir / filename
    
    # Convert any non-serializable objects
    def serialize(obj):
        if hasattr(obj, 'isoformat'):
            return obj.isoformat()
        elif hasattr(obj, '__dict__'):
            return str(obj)
        return str(obj)
    
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, indent=2, default=serialize)
    
    print(f"  💾 Saved: {filepath}")
    return filepath


def save_semantic_model(model: dict, output_dir: Path) -> Path:
    """Save semantic model to YAML file."""
    output_dir.mkdir(parents=True, exist_ok=True)
    db_name = model["semantic_model"]["database"]
    filename = f"{db_name}.semantic.yaml"
    filepath = output_dir / filename
    
    with open(filepath, "w", encoding="utf-8") as f:
        yaml.dump(model, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    
    print(f"  📄 Saved: {filepath}")
    return filepath


def main():
    parser = argparse.ArgumentParser(
        description="Extract ADX snapshots and generate semantic models"
    )
    parser.add_argument(
        "--databases", "-d",
        nargs="*",
        default=list(DATABASES.keys()),
        help=f"Databases to process. Default: all. Options: {list(DATABASES.keys())}"
    )
    parser.add_argument(
        "--skip-snapshot",
        action="store_true",
        help="Skip snapshot extraction, only generate semantic models from existing snapshots"
    )
    parser.add_argument(
        "--snapshot-dir",
        type=Path,
        default=SNAPSHOT_DIR,
        help=f"Output directory for snapshots. Default: {SNAPSHOT_DIR}"
    )
    parser.add_argument(
        "--semantic-dir",
        type=Path,
        default=SEMANTIC_DIR,
        help=f"Output directory for semantic models. Default: {SEMANTIC_DIR}"
    )
    
    args = parser.parse_args()
    
    print("=" * 70)
    print("ADX SNAPSHOT EXTRACTOR & SEMANTIC MODEL GENERATOR")
    print("=" * 70)
    print(f"Cluster: {CLUSTER_URL}")
    print(f"Databases: {args.databases}")
    print(f"Snapshot Dir: {args.snapshot_dir}")
    print(f"Semantic Dir: {args.semantic_dir}")
    print()
    
    snapshots = []
    
    if args.skip_snapshot:
        # Load existing snapshots
        print("📂 Loading existing snapshots...")
        for db in args.databases:
            pattern = f"{db}_snapshot_*.json"
            matches = sorted(args.snapshot_dir.glob(pattern))
            if matches:
                latest = matches[-1]
                print(f"  Loading: {latest}")
                with open(latest, "r", encoding="utf-8") as f:
                    snapshots.append(json.load(f))
            else:
                print(f"  ⚠️ No snapshot found for {db}")
    else:
        # Extract new snapshots
        client = get_kusto_client()
        
        for db in args.databases:
            if db not in DATABASES:
                print(f"⚠️ Unknown database: {db}")
                continue
            
            try:
                snapshot = extract_database_snapshot(client, db)
                save_snapshot(snapshot, args.snapshot_dir)
                snapshots.append(snapshot)
            except Exception as e:
                print(f"❌ Error extracting {db}: {e}")
    
    # Generate semantic models
    print("\n" + "=" * 70)
    print("GENERATING SEMANTIC MODELS")
    print("=" * 70)
    
    for snapshot in snapshots:
        db = snapshot["database"]
        print(f"\n📐 Generating semantic model for: {db}")
        
        try:
            model = generate_semantic_model(snapshot)
            save_semantic_model(model, args.semantic_dir)
        except Exception as e:
            print(f"❌ Error generating semantic model for {db}: {e}")
    
    print("\n" + "=" * 70)
    print("COMPLETE!")
    print("=" * 70)
    print(f"Snapshots: {args.snapshot_dir}")
    print(f"Semantic Models: {args.semantic_dir}")


if __name__ == "__main__":
    main()
