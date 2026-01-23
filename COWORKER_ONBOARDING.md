# 🚀 ADX/KQL Workspace Onboarding Guide
## Setup Your Environment to Query Azure Data Explorer from VS Code with Copilot

---

## 📋 COPILOT PROMPT TO GET STARTED

**Copy and paste this entire prompt into Copilot chat to set up your project:**

```
I need to set up a Python workspace for querying Azure Data Explorer (ADX) using KQL. Here's what I need:

## My Goals:
1. Connect to the FCTS ADX cluster: https://fctsnaproddatexp02.westus2.kusto.windows.net
2. Query sensor data from mining sites (Morenci, Bagdad, Miami, Sierrita, Climax, NewMexico, CerroVerde)
3. Use browser-based Azure AD authentication (SSO)
4. Run KQL queries from Python scripts

## Please help me:
1. Create a virtual environment with required packages (azure-kusto-data, azure-identity, pandas)
2. Create a Python script that:
   - Connects to ADX using InteractiveBrowserCredential
   - Lists available databases
   - Runs sample KQL queries against sensor data
3. Create a .env.example file for configuration
4. Show me how to query:
   - Current sensor values using FCTSCURRENT function
   - Historical sensor data using FCTS function

## ADX Structure I'll be querying:
- Cluster: https://fctsnaproddatexp02.westus2.kusto.windows.net
- Databases per site: Miami, Morenci, Bagdad, Sierrita, Climax, NewMexico, CerroVerde
- Main functions: FCTS (historical), FCTSCURRENT (latest snapshot)
- Global database for registry/metadata

## Example KQL I want to run:
database('Morenci').FCTSCURRENT 
| where sensor_id contains "CR03"
| take 10
```

---

## 🛠️ MANUAL SETUP STEPS

### Step 1: Prerequisites

1. **Request ADX Access:**
   - Security Group: `SG-ENT-FCTS-ADX-Viewer`
   - Submit ticket for access approval
   - Admin Contact: Chris Martin

2. **Install Python 3.10+** from python.org

3. **Install VS Code Extensions:**
   - Python (Microsoft)
   - GitHub Copilot
   - Jupyter (optional, for notebooks)

### Step 2: Create Project Structure

```
my-adx-project/
├── .venv/                    # Virtual environment
├── .env                      # Connection config (create from .env.example)
├── .env.example              # Template
├── requirements.txt          # Dependencies
├── scripts/
│   ├── adx_connect.py        # Connection helper
│   ├── adx_browser.py        # Interactive KQL runner
│   └── sample_queries.py     # Example queries
└── semantic_models/
    └── ADX_UNIFIED.semantic.yaml  # Schema reference
```

### Step 3: Create Environment

Open terminal in VS Code and run:

```powershell
# Navigate to your project folder
cd C:\path\to\your\project

# Create virtual environment
python -m venv .venv

# Activate it
.\.venv\Scripts\Activate.ps1

# Install dependencies
pip install azure-kusto-data azure-identity pandas python-dotenv
```

### Step 4: Create Configuration Files

#### `.env.example` (copy to `.env` and fill values)

```env
# =============================================================================
# ADX (Azure Data Explorer) Configuration
# =============================================================================
# Main FCTS Production Cluster
ADX_CLUSTER_URL=https://fctsnaproddatexp02.westus2.kusto.windows.net

# Default database for management queries
ADX_DEFAULT_DB=Global

# Site databases (no credentials needed - uses Azure SSO)
# Available: Miami, Morenci, Bagdad, Sierrita, Climax, NewMexico, CerroVerde

# =============================================================================
# SQL Azure Configuration (Optional - for hybrid queries)
# =============================================================================
# DEV Server
SQLAZURE_DEV_SERVER=azwd22midbx02.eb8a77f2eea6.database.windows.net

# TEST Server  
SQLAZURE_TEST_SERVER=azwt22midbx02.9959d3e6fe6e.database.windows.net

# PROD Server
SQLAZURE_PROD_SERVER=azwp22midbx02.8232c56adfdf.database.windows.net

# Databases: ConnectedOperations, SNOWFLAKE_WG

# =============================================================================
# Snowflake Configuration (Optional - for legacy comparison)
# =============================================================================
# CONN_LIB_SNOWFLAKE_ACCOUNT=freeportmcmoran.east-us-2.azure
# CONN_LIB_SNOWFLAKE_USER=your.email@fmi.com
# CONN_LIB_SNOWFLAKE_AUTHENTICATOR=externalbrowser
# CONN_LIB_SNOWFLAKE_ROLE=ANALYST
# CONN_LIB_SNOWFLAKE_WAREHOUSE=WH_ANALYST
# CONN_LIB_SNOWFLAKE_DATABASE=PROD_DATALAKE
# CONN_LIB_SNOWFLAKE_SCHEMA=FCTS

# =============================================================================
# Authentication (Service Principal - for automation only)
# =============================================================================
# For interactive use, leave these blank - browser auth will be used
# AZURE_CLIENT_ID=
# AZURE_CLIENT_SECRET=
# AZURE_TENANT_ID=
```

#### `requirements.txt`

```
azure-identity
azure-kusto-data
pandas
python-dotenv
tabulate
```

---

## 📜 STARTER SCRIPT

Create `scripts/adx_connect.py`:

```python
"""
ADX Connection Helper - Browser Authentication (SSO)
====================================================
Connects to FCTS ADX cluster using your Azure AD credentials.
No passwords needed - opens browser for authentication.
"""
from azure.identity import InteractiveBrowserCredential
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
import pandas as pd
import os
from dotenv import load_dotenv

# Load environment
load_dotenv()

# Configuration
CLUSTER_URL = os.getenv("ADX_CLUSTER_URL", "https://fctsnaproddatexp02.westus2.kusto.windows.net")

# Site to Database mapping
SITE_TO_DATABASE = {
    "SAM": "Miami",
    "MOR": "Morenci", 
    "CMX": "Climax",
    "SIE": "Sierrita",
    "NMO": "NewMexico",
    "BAG": "Bagdad",
    "CVE": "CerroVerde",
}

def get_kusto_client() -> KustoClient:
    """Create Kusto client with browser authentication (SSO)."""
    print(f"🔐 Connecting to {CLUSTER_URL}...")
    print("   (Browser will open for Azure AD login)")
    
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(
        CLUSTER_URL, credential
    )
    return KustoClient(kcsb)

def list_databases(client: KustoClient) -> None:
    """List all databases in the cluster."""
    result = client.execute_mgmt("Global", ".show databases")
    print("\n📋 DATABASES IN CLUSTER:")
    print("=" * 50)
    for row in result.primary_results[0]:
        print(f"   • {row[0]}")

def query_current_sensors(client: KustoClient, site_code: str, sensor_filter: str = None) -> pd.DataFrame:
    """Get current sensor values for a site."""
    database = SITE_TO_DATABASE.get(site_code.upper())
    if not database:
        raise ValueError(f"Unknown site: {site_code}. Valid: {list(SITE_TO_DATABASE.keys())}")
    
    kql = "FCTSCURRENT"
    if sensor_filter:
        kql += f" | where sensor_id contains '{sensor_filter}'"
    kql += " | take 100"
    
    print(f"\n🔍 Querying {database}...")
    result = client.execute(database, kql)
    
    # Convert to DataFrame
    columns = [col.column_name for col in result.primary_results[0].columns]
    data = [list(row) for row in result.primary_results[0]]
    return pd.DataFrame(data, columns=columns)

def query_historical(client: KustoClient, site_code: str, sensor_id: str, hours: int = 24) -> pd.DataFrame:
    """Get historical sensor data."""
    database = SITE_TO_DATABASE.get(site_code.upper())
    if not database:
        raise ValueError(f"Unknown site: {site_code}")
    
    kql = f"""
    FCTS
    | where timestamp > ago({hours}h)
    | where sensor_id =~ '{sensor_id}'
    | order by timestamp asc
    """
    
    print(f"\n📊 Historical query for {sensor_id} ({hours}h)...")
    result = client.execute(database, kql)
    
    columns = [col.column_name for col in result.primary_results[0].columns]
    data = [list(row) for row in result.primary_results[0]]
    return pd.DataFrame(data, columns=columns)

def run_custom_kql(client: KustoClient, database: str, kql: str) -> pd.DataFrame:
    """Run any custom KQL query."""
    print(f"\n🚀 Running KQL on {database}...")
    result = client.execute(database, kql)
    
    columns = [col.column_name for col in result.primary_results[0].columns]
    data = [list(row) for row in result.primary_results[0]]
    return pd.DataFrame(data, columns=columns)


# =============================================================================
# MAIN - Example Usage
# =============================================================================
if __name__ == "__main__":
    # Connect
    client = get_kusto_client()
    
    # List databases
    list_databases(client)
    
    # Query current sensors from Morenci
    print("\n" + "=" * 60)
    print("SAMPLE QUERY: Current Crusher Sensors (Morenci)")
    print("=" * 60)
    df = query_current_sensors(client, "MOR", "CR03")
    print(df.head(10).to_string())
    
    # Custom KQL example
    print("\n" + "=" * 60)
    print("SAMPLE QUERY: Mill IOS Levels")
    print("=" * 60)
    kql = """
    FCTSCURRENT
    | where sensor_id in~ ("MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV")
    | project sensor_id, timestamp, value, uom
    """
    df = run_custom_kql(client, "Morenci", kql)
    print(df.to_string())
```

---

## 🔍 COMMON KQL QUERIES

### Get Current Sensor Values

```kql
// Current values for specific sensors
database('Morenci').FCTSCURRENT
| where sensor_id in~ ("MOR-CR03_WI00317_PV", "MOR-CC06_LI00601_PV")
| project sensor_id, timestamp, value, uom
```

### Historical Time Series

```kql
// Last 24 hours of data
database('Morenci').FCTS
| where timestamp > ago(24h)
| where sensor_id =~ "MOR-CR03_WI00317_PV"
| summarize avg(todouble(value)) by bin(timestamp, 5m)
```

### Cross-Site Comparison

```kql
union
  (database('Morenci').FCTSCURRENT | extend site = "MOR"),
  (database('Bagdad').FCTSCURRENT | extend site = "BAG")
| where sensor_id contains "CRUSHER"
| project site, sensor_id, timestamp, value
```

### Using Pre-Built Functions

```kql
// Ball Mill Aggregates (AppIntegration)
database('AppIntegration').Morenci_Batman_BallMill_Aggregates()
| project section, ballmill, tph_now, tpoh_now, mill_power

// Acid Tank Levels
database('AppIntegration').AcidTankLevels()
| take 20
```

---

## 🌐 ADX WEB INTERFACE

You can also query directly in browser:
- **URL:** https://dataexplorer.azure.com/clusters/fctsnaproddatexp02.westus2/databases/AppIntegration

---

## 📚 KEY REFERENCES

| Item | Value |
|------|-------|
| **Cluster URL** | `https://fctsnaproddatexp02.westus2.kusto.windows.net` |
| **Auth Method** | Azure AD (Browser SSO) |
| **Security Group** | `SG-ENT-FCTS-ADX-Viewer` |
| **Main Functions** | `FCTS` (historical), `FCTSCURRENT` (snapshot) |
| **Databases** | Miami, Morenci, Bagdad, Sierrita, Climax, NewMexico, CerroVerde |
| **Metadata DB** | Global, AppIntegration |

---

## ❓ ASK COPILOT

Once your environment is set up, ask Copilot:

1. **"Show me how to query sensor XYZ from Morenci"**
2. **"Create a KQL query to compare crusher rates across all sites"**
3. **"Help me build a time series chart from ADX data"**
4. **"How do I convert this Snowflake query to KQL?"**

Use the `ADX_UNIFIED.semantic.yaml` file as context - it contains the complete schema and business KPI mappings!

---

## 🔧 TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| `Not authorized` | Request access to `SG-ENT-FCTS-ADX-Viewer` security group |
| `Database not found` | Use full name: `Morenci` not `MOR` |
| Browser doesn't open | Use `DeviceCodeCredential` instead of `InteractiveBrowserCredential` |
| Slow queries | Use `FCTSCURRENT` for snapshots, add time filters to `FCTS` |

---

**Happy Querying! 🎉**
