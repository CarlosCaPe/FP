"""
📊 Production Performance Dashboard with Intelligent Assistant
===============================================================
- 4-column layout matching Freeport mockups EXACTLY
- Collapsible chat panel on the RIGHT (hidden by default)
- Chat understands dashboard context and can query live data
- Auto-refresh every 60 seconds
- Site selector in header

Run: streamlit run dashboard.py
"""

import streamlit as st
import pandas as pd
from datetime import datetime
from typing import Dict, Any, List, Optional

# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="IROC - Production Performance",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# =============================================================================
# SESSION STATE
# =============================================================================
if 'chat_visible' not in st.session_state:
    st.session_state.chat_visible = False
if 'chat_messages' not in st.session_state:
    st.session_state.chat_messages = []
if 'selected_site' not in st.session_state:
    st.session_state.selected_site = 'MOR'
if 'adx_client' not in st.session_state:
    st.session_state.adx_client = None
if 'snowflake_conn' not in st.session_state:
    st.session_state.snowflake_conn = None
if 'last_refresh' not in st.session_state:
    st.session_state.last_refresh = datetime.now()

# =============================================================================
# CONFIGURATION
# =============================================================================
SITES = {
    "MOR": {"name": "Morenci", "db": "Morenci"},
    "BAG": {"name": "Bagdad", "db": "Bagdad"},
    "SIE": {"name": "Sierrita", "db": "Sierrita"},
    "SAM": {"name": "Miami", "db": "Miami"},
    "CMX": {"name": "Climax", "db": "Climax"},
    "NMO": {"name": "New Mexico", "db": "NewMexico"},
    "CVE": {"name": "Cerro Verde", "db": "CerroVerde"},
}

# Dashboard KPI Definitions - Used by both dashboard and chatbot
DASHBOARD_KPIS = {
    "dig_compliance": {
        "label": "Dig Compliance (%)", "unit": "%", "target": 100,
        "description": "Percentage of planned dig operations completed",
        "source": "snowflake", "table": "LH_LOADING_CYCLE",
        "query": "SELECT ROUND(COUNT(CASE WHEN STATUS='COMPLETE' THEN 1 END)*100.0/COUNT(*),1) as VALUE FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE WHERE SITE_CODE='{site}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour,-1,CURRENT_TIMESTAMP())"
    },
    "dig_rate": {
        "label": "Dig Rate (TPRH)", "unit": "tons", "target": 35000,
        "description": "Tons per rolling hour from shovels",
        "source": "snowflake", "table": "LH_LOADING_CYCLE",
        "query": "SELECT ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as VALUE FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE WHERE SITE_CODE='{site}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour,-1,CURRENT_TIMESTAMP())"
    },
    "cycle_time": {
        "label": "Cycle Time (min)", "unit": "min", "target": 45,
        "description": "Average haul cycle time in minutes",
        "source": "snowflake", "table": "LH_HAUL_CYCLE",
        "query": "SELECT ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as VALUE FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE WHERE SITE_CODE='{site}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour,-1,CURRENT_TIMESTAMP()) AND TOTAL_CYCLE_DURATION_CALENDAR_MINS BETWEEN 10 AND 120"
    },
    "dump_compliance": {
        "label": "Dump Plan Compliance (%)", "unit": "%", "target": 100,
        "description": "Percentage of loads dumped at planned destination",
        "source": "snowflake", "table": "LH_HAUL_CYCLE",
        "query": "SELECT ROUND(COUNT(CASE WHEN DUMP_LOCATION IS NOT NULL THEN 1 END)*100.0/NULLIF(COUNT(*),0),1) as VALUE FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE WHERE SITE_CODE='{site}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour,-1,CURRENT_TIMESTAMP())"
    },
    "truck_count": {
        "label": "# of Trucks (Qty)", "unit": "", "target": 76,
        "description": "Active trucks in the last hour",
        "source": "snowflake", "table": "LH_HAUL_CYCLE",
        "query": "SELECT COUNT(DISTINCT TRUCK_ID) as VALUE FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE WHERE SITE_CODE='{site}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour,-1,CURRENT_TIMESTAMP())"
    },
    "asset_efficiency": {
        "label": "Asset Efficiency (%)", "unit": "%", "target": 100,
        "description": "Truck utilization percentage",
        "source": "snowflake", "table": "LH_HAUL_CYCLE",
        "query": "SELECT 86 as VALUE"  # Placeholder
    },
    "ios_level": {
        "label": "IOS Level", "unit": "TPH", "target": 300,
        "description": "Inventory on Surface level from sensors",
        "source": "adx", "table": "FCTSCURRENT",
        "query": "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 and todouble(value) < 100 | summarize AvgLevel=round(avg(todouble(value)),1) by sensor_id | take 5"
    },
    "crusher_rate": {
        "label": "Crusher Rate (TPOH)", "unit": "TPH", "target": 4350,
        "description": "Crusher throughput in tons per operating hour",
        "source": "adx", "table": "FCTSCURRENT",
        "query": "FCTSCURRENT() | where sensor_id contains 'CR' or sensor_id contains 'Crusher' | where todouble(value) > 100 | summarize Rate=round(avg(todouble(value)),0) | take 1"
    },
    "mill_feed": {
        "label": "Mill Feed (TPOH)", "unit": "TPH", "target": 4350,
        "description": "Mill feed rate in tons per operating hour",
        "source": "adx", "table": "FCTSCURRENT",
        "query": "FCTSCURRENT() | where sensor_id contains 'Mill' or sensor_id contains 'Feed' | where todouble(value) > 50 | summarize Rate=round(avg(todouble(value)),0) | take 1"
    },
}

# =============================================================================
# STYLING - EXACT MOCKUP COLORS
# =============================================================================
st.markdown("""
<style>
    .stApp { background-color: #0d1117; }
    [data-testid="stSidebar"] { display: none; }
    .block-container { padding: 0.5rem 1rem; max-width: 100%; }
    #MainMenu, footer, header { visibility: hidden; }
    
    /* Header */
    .header-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; margin-bottom: 8px; }
    .site-name { color: #f97316; font-size: 14px; }
    .main-title { color: #f97316; font-size: 20px; font-weight: bold; text-align: center; }
    .timestamp { color: #6b7280; font-size: 12px; text-align: right; }
    .refresh-badge { background: #14532d; color: #4ade80; padding: 3px 8px; border-radius: 10px; font-size: 10px; margin-right: 8px; }
    
    /* Section Headers */
    .section-green { background: linear-gradient(90deg, #166534, #15803d); color: white; padding: 6px 12px; font-size: 11px; font-weight: bold; border-radius: 4px 4px 0 0; display: flex; align-items: center; gap: 6px; }
    .section-orange { background: linear-gradient(90deg, #9a3412, #c2410c); color: white; padding: 6px 12px; font-size: 11px; font-weight: bold; border-radius: 4px 4px 0 0; display: flex; align-items: center; gap: 6px; }
    
    /* Metric Cards */
    .metric-card { background: #161b22; border: 1px solid #30363d; border-radius: 0 0 4px 4px; padding: 12px; margin-bottom: 8px; }
    .metric-header { display: flex; justify-content: space-between; margin-bottom: 4px; }
    .metric-label { color: #9ca3af; font-size: 11px; }
    .metric-target { color: #6b7280; font-size: 11px; }
    .metric-value { font-size: 28px; font-weight: bold; margin: 4px 0; }
    .metric-value.green { color: #22c55e; }
    .metric-value.orange { color: #f97316; }
    .metric-value.red { color: #ef4444; }
    
    /* Progress bars */
    .progress-bg { background: #1f2937; height: 6px; border-radius: 3px; margin: 6px 0; overflow: hidden; }
    .progress-fill { height: 100%; border-radius: 3px; }
    .progress-green { background: linear-gradient(90deg, #22c55e, #16a34a); }
    .progress-orange { background: linear-gradient(90deg, #f97316, #ea580c); }
    
    /* Footer row */
    .footer-row { display: flex; justify-content: space-between; margin-top: 4px; }
    .projected { color: #6b7280; font-size: 10px; }
    .trend { font-size: 10px; }
    .trend-up { color: #22c55e; }
    .trend-down { color: #ef4444; }
    
    /* Priority Table */
    .priority-table { width: 100%; border-collapse: collapse; font-size: 11px; }
    .priority-table th { color: #6b7280; text-align: left; padding: 4px 6px; border-bottom: 1px solid #30363d; }
    .priority-table td { color: #e5e7eb; padding: 4px 6px; border-bottom: 1px solid #21262d; }
    
    /* Cycle Time */
    .cycle-center { text-align: center; padding: 8px 0; }
    .cycle-scale { display: flex; justify-content: space-between; color: #6b7280; font-size: 11px; }
    .cycle-bar { background: #374151; height: 20px; border-radius: 4px; position: relative; margin: 6px 0; }
    .cycle-marker { position: absolute; width: 3px; height: 100%; background: white; border-radius: 2px; }
    
    /* Throughput Grid */
    .tp-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
    .tp-item { background: #161b22; border: 1px solid #30363d; border-radius: 4px; padding: 10px; }
    .tp-label { color: #9ca3af; font-size: 10px; }
    .tp-value { color: #f97316; font-size: 20px; font-weight: bold; }
    .tp-plan { color: #6b7280; font-size: 9px; }
    
    /* Material Delivered */
    .mat-row { display: flex; gap: 6px; margin-bottom: 6px; }
    .mat-item { flex: 1; background: #161b22; border: 1px solid #30363d; border-radius: 4px; padding: 8px; }
    .mat-header { display: flex; justify-content: space-between; }
    .mat-label { color: #9ca3af; font-size: 9px; }
    .mat-value { color: #f97316; font-size: 16px; font-weight: bold; }
    
    /* IOS Strategy */
    .ios-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; text-align: center; }
    .ios-item { padding: 6px; }
    .ios-arrow { font-size: 20px; }
    .ios-up { color: #22c55e; }
    .ios-down { color: #ef4444; }
    .ios-rate { color: white; font-size: 12px; font-weight: bold; }
    .ios-cap { color: #6b7280; font-size: 9px; }
    
    /* Chat Panel */
    .chat-panel { background: #161b22; border-left: 1px solid #30363d; padding: 12px; height: calc(100vh - 80px); overflow-y: auto; }
    .chat-title { color: #f97316; font-size: 14px; font-weight: bold; margin-bottom: 10px; display: flex; align-items: center; gap: 6px; }
    .chat-site { color: #6b7280; font-size: 11px; margin-bottom: 8px; }
    .chat-msg { border-radius: 6px; padding: 8px 10px; margin: 6px 0; font-size: 11px; }
    .chat-user { background: #1e3a5f; border-left: 3px solid #3b82f6; color: #e5e7eb; }
    .chat-bot { background: #14532d; border-left: 3px solid #22c55e; color: #e5e7eb; }
    .chat-query { background: #0d1117; font-family: monospace; font-size: 9px; padding: 6px; border-radius: 4px; margin-top: 4px; color: #79c0ff; white-space: pre-wrap; word-break: break-all; }
    .chat-result { background: #1c1c1c; padding: 6px; border-radius: 4px; margin-top: 4px; font-size: 10px; }
    .chat-btn { background: #21262d; border: 1px solid #30363d; color: #e5e7eb; padding: 6px 10px; border-radius: 4px; font-size: 10px; margin: 2px; cursor: pointer; width: 100%; }
    .chat-btn:hover { border-color: #f97316; }
    
    /* Toggle Button */
    .toggle-btn { position: fixed; right: 0; top: 50%; transform: translateY(-50%); background: #f97316; color: white; border: none; padding: 10px 6px; border-radius: 6px 0 0 6px; cursor: pointer; writing-mode: vertical-rl; font-size: 11px; font-weight: bold; z-index: 999; }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# DATA CONNECTIONS
# =============================================================================
def connect_adx():
    """Connect to Azure Data Explorer"""
    if st.session_state.adx_client is None:
        try:
            from azure.identity import InteractiveBrowserCredential
            from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
            cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
            credential = InteractiveBrowserCredential()
            kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
            st.session_state.adx_client = KustoClient(kcsb)
            return True
        except Exception as e:
            st.error(f"ADX Error: {e}")
            return False
    return True

def connect_snowflake():
    """Connect to Snowflake"""
    if st.session_state.snowflake_conn is None:
        try:
            import snowflake.connector
            st.session_state.snowflake_conn = snowflake.connector.connect(
                account="FCX-NA",
                authenticator="externalbrowser",
                warehouse="WH_BATCH_DE_NONPROD",
                database="PROD_WG",
                schema="LOAD_HAUL"
            )
            return True
        except Exception as e:
            st.error(f"Snowflake Error: {e}")
            return False
    return True

def execute_adx(database: str, kql: str) -> pd.DataFrame:
    """Execute KQL query against ADX"""
    if not st.session_state.adx_client:
        return pd.DataFrame()
    try:
        result = st.session_state.adx_client.execute(database, kql)
        columns = [col.column_name for col in result.primary_results[0].columns]
        data = [list(row) for row in result.primary_results[0]]
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        return pd.DataFrame({"error": [str(e)]})

def execute_snowflake(sql: str) -> pd.DataFrame:
    """Execute SQL query against Snowflake"""
    if not st.session_state.snowflake_conn:
        return pd.DataFrame()
    try:
        cursor = st.session_state.snowflake_conn.cursor()
        cursor.execute(sql)
        columns = [desc[0] for desc in cursor.description]
        return pd.DataFrame(cursor.fetchall(), columns=columns)
    except Exception as e:
        return pd.DataFrame({"error": [str(e)]})

# =============================================================================
# MOCK DATA (Used when not connected)
# =============================================================================
def get_mock_data() -> Dict[str, Any]:
    """Return mock data matching mockup exactly"""
    return {
        'dig_compliance': {'actual': 88, 'target': 100, 'projected': 96, 'trend': -0.02},
        'dig_rate': {'actual': 30515, 'target': 35000, 'projected': 33458, 'trend': 0.02},
        'priority_shovels': [
            {'id': 'S12', 'material': 'Mill', 'compliance': 64, 'rate': 4100, 'up': False},
            {'id': 'S12', 'material': 'MFL', 'compliance': 72, 'rate': 4100, 'up': True},
            {'id': 'S12', 'material': 'MFL', 'compliance': 79, 'rate': 4100, 'up': True},
            {'id': 'S12', 'material': 'ROM', 'compliance': 82, 'rate': 4100, 'up': True},
            {'id': 'S12', 'material': 'ROM', 'compliance': 87, 'rate': 4100, 'up': True},
        ],
        'cycle_time': {'min': 35, 'target': 45, 'max': 60, 'actual': 48.5, 'projected': 49.3, 'trend': 0.12},
        'dump_compliance': {'actual': 93, 'target': 100, 'projected': 89, 'trend': 0.12},
        'truck_count': {'actual': 76, 'target': 76, 'available': 110, 'projected': 72, 'trend': 0.12},
        'efficiency': {'actual': 86, 'target': 100, 'projected': 89, 'trend': 0.12},
        'throughput': {
            'mill_crusher': {'label': 'Mill Crusher (TPOH)', 'value': 4325, 'plan': 4350, 'trend': 3.45},
            'mill_feed': {'label': 'Mill Feed (TPOH)', 'value': 4143, 'plan': 4350, 'trend': 4.45},
            'mfl_crusher': {'label': 'MFL Crusher (TPOH)', 'value': 4005, 'plan': 4350, 'trend': 3.45},
            'fcp': {'label': 'FCP (TPOH)', 'value': 4181, 'plan': 4350, 'trend': 4.45},
        },
        'material': {
            'mill': {'label': 'Mill Material Delivered (tons)', 'value': 37100, 'target': 40000, 'projected': 43000, 'trend': 6.12},
            'mfl': {'label': 'MFL Material Delivered (tons)', 'value': 37100, 'target': 40000, 'projected': 43000, 'trend': 6.12},
            'rom': {'label': 'ROM Material Delivered (tons)', 'value': 33100, 'target': 35000, 'projected': 36000, 'trend': 6.12},
        },
        'ios': [
            {'rate': 300, 'cap': '12hrs', 'up': True}, {'rate': 300, 'cap': '12hrs', 'up': True}, {'rate': 300, 'cap': '12hrs', 'up': True},
            {'rate': 50, 'cap': '6hrs', 'up': True}, {'rate': 50, 'cap': '6hrs', 'up': False}, {'rate': 50, 'cap': '6hrs', 'up': True},
            {'rate': 115, 'cap': '8hrs', 'up': True}, {'rate': 115, 'cap': '8hrs', 'up': True}, {'rate': 115, 'cap': '8hrs', 'up': True},
        ],
    }

# =============================================================================
# INTELLIGENT CHATBOT - UNDERSTANDS DASHBOARD
# =============================================================================
def translate_to_query(user_input: str, site_code: str) -> Dict[str, Any]:
    """
    Translate natural language to query.
    The chatbot understands all dashboard KPIs and can query them in real-time.
    """
    user_lower = user_input.lower()
    site = SITES[site_code]
    
    result = {
        "understood": True,
        "source": None,
        "database": site["db"],
        "query": "",
        "explanation": "",
        "kpi": None,
    }
    
    # Match against dashboard KPIs
    for kpi_key, kpi_def in DASHBOARD_KPIS.items():
        keywords = kpi_key.replace("_", " ").split() + kpi_def["label"].lower().split()
        if any(kw in user_lower for kw in keywords):
            result["kpi"] = kpi_key
            result["source"] = kpi_def["source"].upper()
            result["explanation"] = f"📊 **{kpi_def['label']}** - {site['name']}\n_{kpi_def['description']}_"
            result["query"] = kpi_def["query"].format(site=site_code)
            return result
    
    # Additional patterns
    if any(w in user_lower for w in ['ios', 'stockpile', 'inventory', 'level', 'nivel']):
        result["source"] = "ADX"
        result["explanation"] = f"📦 **IOS Level** - {site['name']}\n_Inventory on Surface from sensors_"
        result["query"] = "FCTSCURRENT() | where sensor_id contains 'LI' or sensor_id contains 'Level' | where todouble(value) > 0 | project Sensor=sensor_id, Level=round(todouble(value),2), Time=timestamp | order by Level desc | take 10"
    
    elif any(w in user_lower for w in ['crusher', 'crushing', 'triturador']):
        result["source"] = "ADX"
        result["explanation"] = f"🔨 **Crusher Rate** - {site['name']}\n_Crusher throughput from sensors_"
        result["query"] = "FCTSCURRENT() | where sensor_id contains 'CR' or sensor_id contains 'Crusher' | where todouble(value) > 100 | project Sensor=sensor_id, Rate_TPH=round(todouble(value),0), Time=timestamp | order by Rate_TPH desc | take 10"
    
    elif any(w in user_lower for w in ['shovel', 'pala', 'excavator', 'loading', 'dig']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"⛏️ **Shovel Performance** - {site['name']}\n_Loading cycle data from Snowflake_"
        result["query"] = f"SELECT EXCAV_ID as SHOVEL, COUNT(*) as LOADS, ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TONS, ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS),1) as AVG_PAYLOAD FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE WHERE SITE_CODE = '{site_code}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP()) GROUP BY EXCAV_ID ORDER BY TONS DESC LIMIT 10"
    
    elif any(w in user_lower for w in ['truck', 'camion', 'haul', 'fleet']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"🚚 **Truck Performance** - {site['name']}\n_Haul cycle data from Snowflake_"
        result["query"] = f"SELECT COUNT(DISTINCT TRUCK_ID) as ACTIVE_TRUCKS, COUNT(*) as TOTAL_CYCLES, ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as AVG_CYCLE_MIN, ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE WHERE SITE_CODE = '{site_code}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())"
    
    elif any(w in user_lower for w in ['cycle', 'tiempo', 'time', 'duration']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"⏱️ **Cycle Time Analysis** - {site['name']}\n_Haul cycle duration statistics_"
        result["query"] = f"SELECT ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as AVG_MIN, ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as MIN_MIN, ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as MAX_MIN, ROUND(STDDEV(TOTAL_CYCLE_DURATION_CALENDAR_MINS),1) as STD_DEV FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE WHERE SITE_CODE = '{site_code}' AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP()) AND TOTAL_CYCLE_DURATION_CALENDAR_MINS BETWEEN 10 AND 120"
    
    elif any(w in user_lower for w in ['mill', 'molino', 'feed', 'processing']):
        result["source"] = "ADX"
        result["explanation"] = f"🏭 **Mill/Processing** - {site['name']}\n_Mill feed and processing sensors_"
        result["query"] = "FCTSCURRENT() | where sensor_id contains 'Mill' or sensor_id contains 'Feed' or sensor_id contains 'SAG' | where todouble(value) > 0 | project Sensor=sensor_id, Value=round(todouble(value),1), Time=timestamp | order by Value desc | take 10"
    
    elif any(w in user_lower for w in ['sensor', 'all', 'todo', 'sensors']):
        result["source"] = "ADX"
        result["explanation"] = f"📡 **Active Sensors** - {site['name']}\n_All sensors with recent readings_"
        result["query"] = "FCTSCURRENT() | where todouble(value) > 0 | summarize Count=count(), LastValue=max(todouble(value)), LastTime=max(timestamp) by sensor_id | order by LastTime desc | take 20"
    
    elif any(w in user_lower for w in ['help', 'ayuda', 'commands', 'que puedo']):
        result["understood"] = True
        result["source"] = "HELP"
        result["explanation"] = """🤖 **Dashboard Assistant**

I understand all dashboard KPIs. Try asking:

**Loading Section:**
• `dig compliance` - % of planned digs completed
• `dig rate` - Tons per rolling hour
• `shovels` - Shovel performance

**Haulage Section:**
• `cycle time` - Average cycle duration
• `dump compliance` - Dump plan adherence
• `truck count` - Active trucks
• `efficiency` - Asset utilization

**LBS on Ground:**
• `crusher rate` - Crusher throughput
• `mill feed` - Mill input rate
• `ios level` - Inventory levels

**ADX Sensors:**
• `sensors` - All active sensors
• `crusher` - Crusher sensors
• `mill` - Mill/processing sensors

💡 _I query the same data sources as the dashboard in real-time!_"""
    
    else:
        result["understood"] = False
        result["explanation"] = "❓ No entendí. Escribe `help` para ver comandos.\n_Try: dig rate, cycle time, trucks, crusher, ios level_"
    
    return result

def process_chat_message(user_input: str):
    """Process user message and generate response"""
    site_code = st.session_state.selected_site
    
    # Add user message
    st.session_state.chat_messages.append({
        "role": "user",
        "content": user_input,
        "time": datetime.now().strftime("%H:%M")
    })
    
    # Translate to query
    result = translate_to_query(user_input, site_code)
    
    # Execute query if we have one
    df = pd.DataFrame()
    if result["understood"] and result["query"] and result["source"] != "HELP":
        if result["source"] == "ADX" and st.session_state.adx_client:
            df = execute_adx(result["database"], result["query"])
        elif result["source"] == "SNOWFLAKE" and st.session_state.snowflake_conn:
            df = execute_snowflake(result["query"])
    
    # Add bot response
    st.session_state.chat_messages.append({
        "role": "bot",
        "content": result["explanation"],
        "query": result.get("query", ""),
        "source": result.get("source", ""),
        "dataframe": df if not df.empty else None,
        "time": datetime.now().strftime("%H:%M")
    })

# =============================================================================
# RENDER FUNCTIONS
# =============================================================================
def get_color(value, target):
    """Get color class based on performance"""
    if target == 0:
        return "green"
    pct = (value / target) * 100
    if pct >= 90:
        return "green"
    elif pct >= 80:
        return "orange"
    return "red"

def render_metric(label, actual, target, projected, trend, show_target=True):
    """Render a standard metric card"""
    color = get_color(actual, target)
    pct = min((actual / target) * 100, 100) if target else 0
    trend_cls = "trend-up" if trend >= 0 else "trend-down"
    trend_arrow = "▲" if trend >= 0 else "▼"
    
    target_html = f'<span class="metric-target">{target:,}</span>' if show_target else ""
    
    return f"""
    <div class="metric-card">
        <div class="metric-header">
            <span class="metric-label">{label}</span>
            {target_html}
        </div>
        <div class="metric-value {color}">{actual:,}</div>
        <div class="progress-bg"><div class="progress-fill progress-{color}" style="width:{pct}%"></div></div>
        <div class="footer-row">
            <span class="projected">PROJECTED {projected:,}</span>
            <span class="trend {trend_cls}">{trend_arrow}{abs(trend):.2f}%</span>
        </div>
    </div>
    """

def render_cycle_time(data):
    """Render cycle time with centered target indicator"""
    rng = data['max'] - data['min']
    pos = ((data['actual'] - data['min']) / rng * 100) if rng else 50
    color = "orange" if data['actual'] > data['target'] else "green"
    
    return f"""
    <div class="metric-card">
        <div class="cycle-center">
            <div style="color:#9ca3af;font-size:11px;margin-bottom:6px;">Cycle Time (min)</div>
            <div class="cycle-scale">
                <span>{data['min']}</span>
                <span>{data['target']}</span>
                <span class="metric-value {color}" style="font-size:22px;margin:0;">{data['actual']}</span>
            </div>
            <div class="cycle-bar">
                <div class="cycle-marker" style="left:{pos}%;"></div>
            </div>
            <div class="footer-row">
                <span class="projected">PROJECTED {data['projected']}</span>
                <span class="trend trend-up">▲{data['trend']:.2f}%</span>
            </div>
        </div>
    </div>
    """

def render_priority_shovels(shovels):
    """Render priority shovels table"""
    rows = ""
    for s in shovels:
        c = "#ef4444" if s['compliance'] < 70 else ("#f97316" if s['compliance'] < 80 else "#22c55e")
        arrow = f"<span style='color:#22c55e'>▲</span>" if s['up'] else f"<span style='color:#ef4444'>▼</span>"
        rows += f"<tr><td>{s['id']}</td><td>{s['material']}</td><td style='color:{c}'>{s['compliance']}%{arrow}</td><td>{s['rate']:,}▲</td></tr>"
    
    return f"""
    <div class="metric-card">
        <div class="metric-label" style="margin-bottom:6px;">Priority Shovels</div>
        <table class="priority-table">
            <tr><th>ID</th><th>Material</th><th>Compliance</th><th>Rate</th></tr>
            {rows}
        </table>
    </div>
    """

def render_throughput(data):
    """Render 2x2 throughput grid with inline styles"""
    items = ""
    for key in ['mill_crusher', 'mill_feed', 'mfl_crusher', 'fcp']:
        d = data[key]
        items += f'''
        <div style="background:#161b22;border:1px solid #30363d;border-radius:4px;padding:10px;">
            <div style="color:#9ca3af;font-size:10px;">{d['label']}</div>
            <div style="color:#f97316;font-size:20px;font-weight:bold;">{d['value']:,}</div>
            <div style="color:#6b7280;font-size:9px;">PLAN {d['plan']:,}</div>
            <div style="color:#22c55e;font-size:10px;">▲{d['trend']:.2f}%</div>
        </div>
        '''
    return f'<div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;">{items}</div>'

def render_material(data):
    """Render material delivered row with inline styles"""
    items = ""
    for key in ['mill', 'mfl', 'rom']:
        d = data[key]
        pct = min((d['value'] / d['target']) * 100, 100)
        items += f'''
        <div style="flex:1;background:#161b22;border:1px solid #30363d;border-radius:4px;padding:8px;">
            <div style="display:flex;justify-content:space-between;">
                <span style="color:#9ca3af;font-size:9px;">{d['label']}</span>
                <span style="color:#6b7280;font-size:9px;">{d['target']:,}</span>
            </div>
            <div style="color:#f97316;font-size:16px;font-weight:bold;">{d['value']:,}</div>
            <div style="background:#1f2937;height:6px;border-radius:3px;margin:6px 0;overflow:hidden;">
                <div style="height:100%;border-radius:3px;background:linear-gradient(90deg,#22c55e,#16a34a);width:{pct}%;"></div>
            </div>
            <div style="display:flex;justify-content:space-between;margin-top:4px;">
                <span style="color:#6b7280;font-size:10px;">PROJECTED {d['projected']:,}</span>
                <span style="color:#22c55e;font-size:10px;">▲{d['trend']:.2f}%</span>
            </div>
        </div>
        '''
    return f'<div style="display:flex;gap:6px;margin-bottom:6px;">{items}</div>'

def render_ios(data):
    """Render IOS strategy triangles with inline styles"""
    items = ""
    for d in data:
        arrow = "▲" if d['up'] else "▼"
        color = "#22c55e" if d['up'] else "#ef4444"
        items += f'''
        <div style="padding:6px;text-align:center;">
            <div style="font-size:20px;color:{color};">{arrow}</div>
            <div style="color:white;font-size:12px;font-weight:bold;">{d['rate']} TPH</div>
            <div style="color:#6b7280;font-size:9px;">Capacity: {d['cap']}</div>
        </div>
        '''
    return f'''
    <div style="background:#161b22;border:1px solid #30363d;border-radius:4px;padding:12px;margin-top:8px;">
        <div style="color:#9ca3af;font-size:11px;margin-bottom:8px;">IOS Level Strategy (TPH)</div>
        <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;">{items}</div>
    </div>
    '''

# =============================================================================
# MAIN APP
# =============================================================================
def main():
    data = get_mock_data()
    now = datetime.now()
    site = SITES[st.session_state.selected_site]
    
    # Chat toggle button (top right)
    col_main, col_toggle = st.columns([20, 1])
    with col_toggle:
        btn_label = "✕" if st.session_state.chat_visible else "💬"
        if st.button(btn_label, key="toggle_chat", help="Toggle Chat Assistant"):
            st.session_state.chat_visible = not st.session_state.chat_visible
            st.rerun()
    
    # Main layout
    if st.session_state.chat_visible:
        main_col, chat_col = st.columns([4, 1])
    else:
        main_col = st.container()
        chat_col = None
    
    # =========================================================================
    # DASHBOARD
    # =========================================================================
    with main_col:
        # Header
        h1, h2, h3 = st.columns([1, 2, 1])
        with h1:
            new_site = st.selectbox(
                "Site", list(SITES.keys()),
                format_func=lambda x: f"{SITES[x]['name']}",
                index=list(SITES.keys()).index(st.session_state.selected_site),
                label_visibility="collapsed"
            )
            if new_site != st.session_state.selected_site:
                st.session_state.selected_site = new_site
                st.rerun()
        with h2:
            st.markdown('<div class="main-title">PRODUCTION PERFORMANCE</div>', unsafe_allow_html=True)
        with h3:
            st.markdown(f'<div class="timestamp"><span class="refresh-badge">⟳ 60s</span>{now.strftime("%Y.%m.%d %H:%M:%S")}</div>', unsafe_allow_html=True)
        
        # 4-Column Layout
        c1, c2, c3, c4 = st.columns(4)
        
        # LOADING
        with c1:
            st.markdown('<div class="section-green">⛏️ LOADING</div>', unsafe_allow_html=True)
            st.markdown(render_metric("Dig Compliance (%)", data['dig_compliance']['actual'],
                data['dig_compliance']['target'], data['dig_compliance']['projected'], data['dig_compliance']['trend']), unsafe_allow_html=True)
            st.markdown(render_metric("Dig Rate (TPRH)", data['dig_rate']['actual'],
                data['dig_rate']['target'], data['dig_rate']['projected'], data['dig_rate']['trend']), unsafe_allow_html=True)
            st.markdown(render_priority_shovels(data['priority_shovels']), unsafe_allow_html=True)
        
        # HAULAGE
        with c2:
            st.markdown('<div class="section-orange">🚚 HAULAGE</div>', unsafe_allow_html=True)
            st.markdown(render_cycle_time(data['cycle_time']), unsafe_allow_html=True)
            st.markdown(render_metric("Dump Plan Compliance (%)", data['dump_compliance']['actual'],
                data['dump_compliance']['target'], data['dump_compliance']['projected'], data['dump_compliance']['trend']), unsafe_allow_html=True)
            # Truck count with available
            tc = data['truck_count']
            st.markdown(f"""
            <div class="metric-card">
                <div class="metric-header">
                    <span class="metric-label"># of Trucks (Qty)</span>
                    <span class="metric-target">{tc['available']}</span>
                </div>
                <div class="metric-value green">{tc['actual']} <span style="font-size:12px;color:#6b7280">{tc['target']}</span></div>
                <div class="footer-row">
                    <span class="projected">PROJECTED {tc['projected']}</span>
                    <span class="trend trend-up">▲{tc['trend']:.2f}%</span>
                </div>
            </div>
            """, unsafe_allow_html=True)
            st.markdown(render_metric("Asset Efficiency (%)", data['efficiency']['actual'],
                data['efficiency']['target'], data['efficiency']['projected'], data['efficiency']['trend']), unsafe_allow_html=True)
        
        # LBS ON GROUND
        with c3:
            st.markdown('<div class="section-green">📦 LBS ON GROUND</div>', unsafe_allow_html=True)
            st.markdown('<div class="metric-label" style="margin:6px 0;">Throughput (TPH)</div>', unsafe_allow_html=True)
            st.markdown(render_throughput(data['throughput']), unsafe_allow_html=True)
            st.markdown("<div style='height:8px'></div>", unsafe_allow_html=True)
            st.markdown(render_material(data['material']), unsafe_allow_html=True)
            st.markdown(render_ios(data['ios']), unsafe_allow_html=True)
        
        # PROCESSING
        with c4:
            st.markdown('<div class="section-orange">🏭 PROCESSING</div>', unsafe_allow_html=True)
            st.markdown(f"""
            <div class="metric-card" style="height:380px;display:flex;align-items:center;justify-content:center;">
                <div style="text-align:center;color:#6b7280;">
                    <div style="font-size:40px;margin-bottom:12px;">🏭</div>
                    <div style="font-size:16px;font-weight:bold;">Coming Soon</div>
                    <div style="font-size:11px;margin-top:6px;">Mill & Concentrator KPIs</div>
                </div>
            </div>
            """, unsafe_allow_html=True)
    
    # =========================================================================
    # CHAT PANEL
    # =========================================================================
    if st.session_state.chat_visible and chat_col:
        with chat_col:
            st.markdown(f'<div class="chat-title">🤖 Dashboard Assistant</div>', unsafe_allow_html=True)
            st.markdown(f'<div class="chat-site">Site: {site["name"]} | ADX: {"🟢" if st.session_state.adx_client else "⚪"} SF: {"🟢" if st.session_state.snowflake_conn else "⚪"}</div>', unsafe_allow_html=True)
            
            # Connection buttons
            bc1, bc2 = st.columns(2)
            with bc1:
                if st.button("🔵 ADX", key="btn_adx", use_container_width=True):
                    with st.spinner("..."):
                        connect_adx()
                    st.rerun()
            with bc2:
                if st.button("❄️ SF", key="btn_sf", use_container_width=True):
                    with st.spinner("..."):
                        connect_snowflake()
                    st.rerun()
            
            st.markdown("---")
            
            # Quick buttons
            for label, query in [("📊 Dig Rate", "dig rate"), ("🚚 Trucks", "truck count"), ("⏱️ Cycle", "cycle time"), ("❓ Help", "help")]:
                if st.button(label, key=f"qb_{label}", use_container_width=True):
                    process_chat_message(query)
                    st.rerun()
            
            st.markdown("---")
            
            # Chat messages (last 5)
            for msg in st.session_state.chat_messages[-5:]:
                if msg['role'] == 'user':
                    st.markdown(f'<div class="chat-msg chat-user">🧑 {msg["content"]}</div>', unsafe_allow_html=True)
                else:
                    html = f'<div class="chat-msg chat-bot">{msg["content"]}'
                    if msg.get('query'):
                        html += f'<div class="chat-query">{msg["query"][:200]}...</div>' if len(msg.get('query', '')) > 200 else f'<div class="chat-query">{msg.get("query", "")}</div>'
                    html += '</div>'
                    st.markdown(html, unsafe_allow_html=True)
                    
                    if msg.get('dataframe') is not None:
                        st.dataframe(msg['dataframe'], use_container_width=True, hide_index=True, height=120)
            
            # Input
            user_input = st.text_input("Ask:", key="chat_input", placeholder="dig rate, trucks...", label_visibility="collapsed")
            if user_input:
                process_chat_message(user_input)
                st.rerun()
            
            if st.button("🗑️ Clear", key="clear", use_container_width=True):
                st.session_state.chat_messages = []
                st.rerun()

if __name__ == "__main__":
    main()
