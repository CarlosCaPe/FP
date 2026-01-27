"""
🎯 INTELLIGENT DASHBOARD - Video Wall with Integrated Chat
============================================================
A smart dashboard that combines:
- Real-time mining KPI visualization
- Natural Language to Query chat interface
- Multi-site switching capability
- Live query execution and results

Run with: streamlit run SQLRefactoring/VideoWallDashboard/intelligent_dashboard.py

Author: Mining Operations Team
Version: 1.0.0
"""

import streamlit as st
import pandas as pd
from datetime import datetime
from typing import Dict, List, Optional, Any
import sys
from pathlib import Path

# Add paths for imports
sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent))

from config.settings import SITES, SiteConfig, DisplayConfig, APP_CONFIG
from ui.components import (
    StatusColor,
    get_status_color,
    MetricDisplayData,
)

# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="⛏️ IROC Intelligent Dashboard",
    page_icon="⛏️",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# =============================================================================
# GLOBAL STYLES
# =============================================================================
st.markdown("""
<style>
    /* Dark theme base */
    .stApp {
        background-color: #0a0a0f;
    }
    
    /* Remove padding */
    .block-container {
        padding-top: 0.5rem;
        padding-bottom: 0rem;
        padding-left: 0.5rem;
        padding-right: 0.5rem;
        max-width: 100%;
    }
    
    /* Hide streamlit elements */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    
    /* Site selector tabs */
    .site-tab {
        display: inline-block;
        padding: 8px 16px;
        margin: 2px;
        border-radius: 20px;
        cursor: pointer;
        font-size: 12px;
        font-weight: bold;
        transition: all 0.3s;
    }
    .site-tab-active {
        background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
        color: white;
    }
    .site-tab-inactive {
        background: #1a1a2e;
        color: #6b7280;
        border: 1px solid #333;
    }
    .site-tab-inactive:hover {
        background: #2d2d4a;
        color: white;
    }
    
    /* Chat container */
    .chat-container {
        background: #0d1117;
        border-left: 1px solid #333;
        height: calc(100vh - 60px);
        overflow-y: auto;
        padding: 10px;
    }
    
    /* Chat messages */
    .user-msg {
        background: #1e3a5f;
        padding: 10px 14px;
        border-radius: 12px 12px 4px 12px;
        margin: 8px 0;
        font-size: 13px;
        color: #e2e8f0;
    }
    .bot-msg {
        background: #1a1a2e;
        padding: 10px 14px;
        border-radius: 12px 12px 12px 4px;
        margin: 8px 0;
        font-size: 13px;
        color: #cbd5e0;
        border-left: 3px solid #22c55e;
    }
    
    /* Query code block */
    .query-block {
        background: #161b22;
        border: 1px solid #30363d;
        border-radius: 6px;
        padding: 10px;
        font-family: 'Courier New', monospace;
        font-size: 11px;
        color: #79c0ff;
        overflow-x: auto;
        margin: 8px 0;
    }
    
    /* Metric cards */
    .metric-card {
        background: #1a1a2e;
        border-radius: 8px;
        padding: 12px;
        margin-bottom: 8px;
    }
    
    /* Section headers */
    .section-header {
        padding: 8px 16px;
        border-radius: 4px;
        margin-bottom: 12px;
        text-align: center;
        font-weight: bold;
        font-size: 13px;
        text-transform: uppercase;
        color: white;
    }
    
    /* Results table */
    .results-table {
        background: #161b22;
        border-radius: 6px;
        padding: 8px;
        margin: 8px 0;
        font-size: 11px;
    }
    
    /* Status badge */
    .status-badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 10px;
        font-size: 10px;
        font-weight: bold;
    }
    .status-connected { background: #166534; color: #4ade80; }
    .status-disconnected { background: #7f1d1d; color: #fca5a5; }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# SESSION STATE INITIALIZATION
# =============================================================================
if 'selected_site' not in st.session_state:
    st.session_state.selected_site = 'MOR'
if 'chat_messages' not in st.session_state:
    st.session_state.chat_messages = []
if 'adx_authenticated' not in st.session_state:
    st.session_state.adx_authenticated = False
if 'snowflake_authenticated' not in st.session_state:
    st.session_state.snowflake_authenticated = False
if 'last_query_result' not in st.session_state:
    st.session_state.last_query_result = None

# =============================================================================
# DATA CONNECTIONS
# =============================================================================
@st.cache_resource
def get_adx_client():
    """Get cached ADX client."""
    try:
        from azure.identity import InteractiveBrowserCredential
        from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
        
        cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
        credential = InteractiveBrowserCredential()
        kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
        client = KustoClient(kcsb)
        st.session_state.adx_authenticated = True
        return client
    except Exception as e:
        st.session_state.adx_authenticated = False
        return None

@st.cache_resource
def get_snowflake_connection():
    """Get cached Snowflake connection."""
    try:
        import snowflake.connector
        conn = snowflake.connector.connect(
            account="FCX-NA",
            authenticator="externalbrowser",
            warehouse="WH_BATCH_DE_NONPROD",
            database="PROD_WG",
            schema="LOAD_HAUL"
        )
        st.session_state.snowflake_authenticated = True
        return conn
    except Exception as e:
        st.session_state.snowflake_authenticated = False
        return None

def execute_adx_query(database: str, kql: str) -> pd.DataFrame:
    """Execute KQL query."""
    client = get_adx_client()
    if not client:
        return pd.DataFrame()
    try:
        result = client.execute(database, kql)
        columns = [col.column_name for col in result.primary_results[0].columns]
        data = [list(row) for row in result.primary_results[0]]
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        return pd.DataFrame()

def execute_snowflake_query(sql: str) -> pd.DataFrame:
    """Execute Snowflake query."""
    conn = get_snowflake_connection()
    if not conn:
        return pd.DataFrame()
    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        return pd.DataFrame()

# =============================================================================
# NLP QUERY TRANSLATOR
# =============================================================================
def translate_to_query(user_input: str, site_code: str) -> Dict[str, Any]:
    """
    Translate natural language to executable query.
    Returns: {source, database, query, explanation, metric_type}
    """
    user_lower = user_input.lower()
    site_config = SITES.get(site_code, SITES['MOR'])
    adx_database = site_config.adx_database
    
    result = {
        'source': 'ADX',
        'database': adx_database,
        'site': site_code,
        'query': '',
        'explanation': '',
        'metric_type': '',
        'success': True
    }
    
    # === IOS / STOCKPILE LEVEL ===
    if any(word in user_lower for word in ['ios', 'stockpile', 'level', 'inventory', 'silo']):
        result['metric_type'] = 'ios_level'
        result['explanation'] = f"📊 **IOS Level** para {site_config.name}\nNivel actual de stockpile (In-Ore Stockpile)"
        
        if site_code == 'MOR':
            result['query'] = """FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project 
    Sensor = sensor_id,
    Level_Pct = round(todouble(value), 2),
    Timestamp = timestamp,
    UOM = uom
| order by Level_Pct desc"""
        else:
            result['query'] = f"""FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'Level'
| where todouble(value) > 0 and todouble(value) < 100
| project Sensor = sensor_id, Level_Pct = round(todouble(value), 2), Timestamp = timestamp
| order by Level_Pct desc
| take 10"""
    
    # === CRUSHER RATE ===
    elif any(word in user_lower for word in ['crusher', 'crushing', 'triturador']):
        result['metric_type'] = 'crusher_rate'
        result['explanation'] = f"🔨 **Crusher Rate** para {site_config.name}\nTasa de trituración en TPH"
        
        if site_code == 'MOR':
            result['query'] = """FCTSCURRENT()
| where sensor_id in ('MOR-CR03_WI00317_PV', 'MOR-CR02_WI01203_PV')
| project 
    Crusher = case(
        sensor_id == 'MOR-CR03_WI00317_PV', 'Mill Crusher #3',
        sensor_id == 'MOR-CR02_WI01203_PV', 'MFL Crusher',
        sensor_id),
    Rate_TPH = round(todouble(value), 0),
    Target = iff(sensor_id == 'MOR-CR03_WI00317_PV', 8500, 4500),
    Status = case(
        todouble(value) >= 8000, '✅ ON TARGET',
        todouble(value) >= 6000, '⚠️ BELOW',
        '🔴 LOW'),
    Timestamp = timestamp"""
        else:
            result['query'] = f"""FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'Crusher'
| where todouble(value) > 100
| project Sensor = sensor_id, Rate_TPH = round(todouble(value), 0), Timestamp = timestamp
| order by Rate_TPH desc
| take 10"""
    
    # === DIG RATE / LOADING ===
    elif any(word in user_lower for word in ['dig', 'loading', 'shovel', 'excavator', 'pala', 'carga']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'dig_rate'
        result['explanation'] = f"⛏️ **Dig Rate** para {site_config.name}\nTasa de excavación en TPOH (últimas 24h)"
        result['query'] = f"""SELECT 
    '{site_code}' as SITE,
    COUNT(DISTINCT EXCAV_ID) as SHOVEL_COUNT,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / 
          NULLIF(TIMESTAMPDIFF(minute, MIN(CYCLE_START_TS_LOCAL), MAX(CYCLE_START_TS_LOCAL)) / 60.0, 0)) as DIG_RATE_TPOH
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    
    # === TRUCK COUNT / HAULAGE ===
    elif any(word in user_lower for word in ['truck', 'haul', 'fleet', 'camion', 'acarreo']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'truck_count'
        result['explanation'] = f"🚚 **Truck Fleet** para {site_config.name}\nCamiones activos y estadísticas de acarreo"
        result['query'] = f"""SELECT 
    '{site_code}' as SITE,
    COUNT(DISTINCT TRUCK_ID) as ACTIVE_TRUCKS,
    COUNT(*) as TOTAL_CYCLES,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TOTAL_TONS_HAULED
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    
    # === CYCLE TIME ===
    elif any(word in user_lower for word in ['cycle', 'time', 'tiempo', 'ciclo']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'cycle_time'
        result['explanation'] = f"⏱️ **Cycle Time** para {site_config.name}\nTiempo promedio de ciclo de camiones"
        result['query'] = f"""SELECT 
    '{site_code}' as SITE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MIN_CYCLE_MIN,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MAX_CYCLE_MIN,
    COUNT(*) as TOTAL_CYCLES
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS BETWEEN 10 AND 120"""
    
    # === MILL RATE ===
    elif any(word in user_lower for word in ['mill', 'molino', 'ball', 'sag']):
        result['metric_type'] = 'mill_rate'
        result['explanation'] = f"🏭 **Mill Rate** para {site_config.name}\nTasa de molienda actual"
        result['query'] = f"""FCTSCURRENT()
| where sensor_id contains 'Mill' or sensor_id contains 'SAG' or sensor_id contains 'Ball'
| where todouble(value) > 50
| project Sensor = sensor_id, Rate = round(todouble(value), 0), Timestamp = timestamp, UOM = uom
| order by Rate desc
| take 10"""
    
    # === PRIORITY SHOVELS ===
    elif any(word in user_lower for word in ['priority', 'top', 'best', 'ranking', 'mejores']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'priority_shovels'
        result['explanation'] = f"🏆 **Top Shovels** para {site_config.name}\nPalas con mayor producción (24h)"
        result['query'] = f"""SELECT 
    EXCAV_ID as SHOVEL,
    COUNT(*) as LOADS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS), 1) as AVG_LOAD_TONS
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY EXCAV_ID
ORDER BY TOTAL_TONS DESC
LIMIT 5"""
    
    # === TONS DELIVERED ===
    elif any(word in user_lower for word in ['tons', 'delivered', 'dump', 'toneladas', 'entregado']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'tons_delivered'
        result['explanation'] = f"📦 **Tons Delivered** para {site_config.name}\nToneladas por destino"
        result['query'] = f"""SELECT 
    DUMP_LOC_ID as DESTINATION,
    COUNT(*) as DUMPS,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TOTAL_TONS
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY DUMP_LOC_ID
ORDER BY TOTAL_TONS DESC
LIMIT 10"""
    
    # === ALL SENSORS ===
    elif any(word in user_lower for word in ['sensor', 'sensors', 'all', 'todo', 'sensores']):
        result['metric_type'] = 'all_sensors'
        result['explanation'] = f"📡 **All Sensors** para {site_config.name}\nSensores activos con datos recientes"
        result['query'] = f"""FCTSCURRENT()
| where todouble(value) > 0
| summarize 
    Count = count(),
    Last_Reading = max(timestamp)
    by sensor_id
| order by Last_Reading desc
| take 20"""
    
    # === COMPLIANCE ===
    elif any(word in user_lower for word in ['compliance', 'cumplimiento']):
        result['source'] = 'SNOWFLAKE'
        result['metric_type'] = 'compliance'
        result['explanation'] = f"✅ **Compliance** para {site_config.name}\nMétricas de cumplimiento"
        result['query'] = f"""SELECT 
    '{site_code}' as SITE,
    COUNT(*) as TOTAL_EVENTS,
    COUNT(DISTINCT EXCAV_ID) as ACTIVE_SHOVELS,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as AVG_DIG_ELEVATION_FT
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())"""
    
    # === HELP / DEFAULT ===
    else:
        result['source'] = 'HELP'
        result['success'] = False
        result['explanation'] = """❓ **Comandos disponibles:**

🔹 `ios level` - Nivel de stockpile
🔹 `crusher rate` - Tasa de crusher
🔹 `dig rate` - Tasa de excavación
🔹 `truck count` - Conteo de camiones
🔹 `cycle time` - Tiempo de ciclo
🔹 `mill rate` - Tasa de molino
🔹 `top shovels` - Mejores palas
🔹 `tons delivered` - Toneladas entregadas
🔹 `all sensors` - Todos los sensores

💡 Tip: Agrega el nombre del site para filtrar
Ejemplo: "crusher rate bagdad" """
        result['query'] = ''
    
    return result

# =============================================================================
# MOCK DATA GENERATORS
# =============================================================================
import random

def get_mock_metrics(site_code: str) -> Dict:
    """Generate mock metrics for a site."""
    random.seed(hash(site_code + datetime.now().strftime("%H")))
    
    return {
        'dig_compliance': MetricDisplayData(
            label="Dig Compliance (%)",
            actual=random.uniform(83, 95),
            target=100,
            projected=random.uniform(85, 97),
            trend_value=random.uniform(-5, 5),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green" if random.random() > 0.3 else "orange",
            unit="%",
        ),
        'dig_rate': MetricDisplayData(
            label="Dig Rate (TPOH)",
            actual=random.uniform(27000, 35000),
            target=35000,
            projected=random.uniform(30000, 36000),
            trend_value=random.uniform(-3, 5),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green",
            unit="TPOH",
        ),
        'truck_count': MetricDisplayData(
            label="# of Trucks (Qty)",
            actual=random.randint(65, 85),
            target=76,
            projected=random.randint(70, 82),
            trend_value=random.uniform(-3, 3),
            trend_direction="↑" if random.random() > 0.5 else "↓",
            actual_status="green",
            projected_status="green",
            trend_status="green",
            unit="",
        ),
        'cycle_time': MetricDisplayData(
            label="Cycle Time (min)",
            actual=random.uniform(40, 55),
            target=45,
            projected=random.uniform(42, 50),
            trend_value=random.uniform(-5, 5),
            trend_direction="↑" if random.random() > 0.5 else "↓",
            actual_status="green" if random.random() > 0.4 else "orange",
            projected_status="green",
            trend_status="green",
            unit="min",
        ),
        'mill_crusher': MetricDisplayData(
            label="Mill Crusher (TPH)",
            actual=random.uniform(8000, 9200),
            target=8750,
            projected=random.uniform(8200, 9000),
            trend_value=random.uniform(-2, 4),
            trend_direction="↑",
            actual_status="green",
            projected_status="green",
            trend_status="green",
            unit="TPH",
        ),
        'mfl_crusher': MetricDisplayData(
            label="MFL Crusher (TPH)",
            actual=random.uniform(4200, 4800),
            target=4500,
            projected=random.uniform(4300, 4600),
            trend_value=random.uniform(-3, 3),
            trend_direction="↑" if random.random() > 0.5 else "↓",
            actual_status="green" if random.random() > 0.4 else "orange",
            projected_status="green",
            trend_status="green",
            unit="TPH",
        ),
        'ios_level': {
            'main': random.uniform(60, 85),
            'small': random.uniform(45, 70),
        },
        'priority_shovels': [
            {"id": f"S{random.randint(10,20)}", "material": "Mill", "compliance": 64 + random.randint(0, 25), "rate": 4100 + random.randint(-300, 500)},
            {"id": f"S{random.randint(10,20)}", "material": "MFL", "compliance": 72 + random.randint(0, 20), "rate": 3800 + random.randint(-200, 400)},
            {"id": f"S{random.randint(10,20)}", "material": "ROM", "compliance": 79 + random.randint(0, 15), "rate": 3500 + random.randint(-200, 300)},
        ],
    }

# =============================================================================
# UI COMPONENTS
# =============================================================================

def render_site_selector():
    """Render horizontal site selector tabs."""
    current_site = st.session_state.selected_site
    
    cols = st.columns(len(SITES) + 2)
    
    with cols[0]:
        st.markdown(f"""
        <div style="padding: 8px; color: #f97316; font-weight: bold; font-size: 14px;">
            ⛏️ IROC
        </div>
        """, unsafe_allow_html=True)
    
    for i, (code, config) in enumerate(SITES.items()):
        with cols[i + 1]:
            is_active = code == current_site
            style_class = "site-tab-active" if is_active else "site-tab-inactive"
            
            if st.button(
                f"{config.name}",
                key=f"site_{code}",
                use_container_width=True,
                type="primary" if is_active else "secondary"
            ):
                st.session_state.selected_site = code
                st.rerun()
    
    # Connection status
    with cols[-1]:
        adx_status = "🟢" if st.session_state.adx_authenticated else "⚪"
        snow_status = "🟢" if st.session_state.snowflake_authenticated else "⚪"
        st.markdown(f"""
        <div style="text-align: right; padding: 8px; color: #6b7280; font-size: 11px;">
            ADX {adx_status} | SF {snow_status}
        </div>
        """, unsafe_allow_html=True)


def render_metric_card_compact(data: MetricDisplayData):
    """Render compact metric card."""
    actual_color = get_status_color(data.actual_status)
    trend_color = get_status_color(data.trend_status)
    bar_width = min((data.actual / data.target * 100) if data.target > 0 else 0, 100)
    trend_sign = "+" if data.trend_value >= 0 else ""
    
    st.markdown(f"""
    <div class="metric-card">
        <div style="display: flex; justify-content: space-between; margin-bottom: 4px;">
            <span style="color: #6b7280; font-size: 11px;">{data.label}</span>
            <span style="color: white; font-size: 11px;">{data.target:,.0f}</span>
        </div>
        <div style="color: {actual_color}; font-size: 22px; font-weight: bold;">{data.actual:,.0f}</div>
        <div style="background: #333; border-radius: 3px; height: 4px; margin: 6px 0;">
            <div style="background: {actual_color}; width: {bar_width}%; height: 100%; border-radius: 3px;"></div>
        </div>
        <div style="display: flex; justify-content: space-between; color: #6b7280; font-size: 10px;">
            <span>PROJ {data.projected:,.0f}</span>
            <span style="color: {trend_color};">{data.trend_direction}{trend_sign}{data.trend_value:.1f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_ios_gauge(label: str, value: float):
    """Render IOS level gauge."""
    color = "#22c55e" if 30 < value < 80 else "#f97316" if 20 < value < 90 else "#ef4444"
    
    st.markdown(f"""
    <div class="metric-card" style="text-align: center;">
        <div style="color: #6b7280; font-size: 10px; margin-bottom: 4px;">{label}</div>
        <div style="color: {color}; font-size: 24px; font-weight: bold;">{value:.1f}%</div>
        <div style="background: #333; border-radius: 3px; height: 6px; margin-top: 6px;">
            <div style="background: {color}; width: {value}%; height: 100%; border-radius: 3px;"></div>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_shovels_table(shovels: List[Dict]):
    """Render priority shovels mini table."""
    st.markdown(f"""
    <div class="metric-card">
        <div style="color: #6b7280; font-size: 11px; margin-bottom: 8px;">Priority Shovels</div>
        <table style="width: 100%; font-size: 11px; color: white;">
            <tr style="color: #6b7280;">
                <th style="text-align: left;">ID</th>
                <th style="text-align: left;">Type</th>
                <th style="text-align: right;">Rate</th>
            </tr>
    """, unsafe_allow_html=True)
    
    for s in shovels[:3]:
        st.markdown(f"""
            <tr>
                <td>{s['id']}</td>
                <td>{s['material']}</td>
                <td style="text-align: right;">{s['rate']:,}</td>
            </tr>
        """, unsafe_allow_html=True)
    
    st.markdown("</table></div>", unsafe_allow_html=True)


def render_chat_interface():
    """Render the chat interface."""
    current_site = st.session_state.selected_site
    site_name = SITES[current_site].name
    
    st.markdown(f"""
    <div style="background: #161b22; padding: 10px; border-radius: 8px; margin-bottom: 10px;">
        <div style="color: #f97316; font-size: 14px; font-weight: bold;">💬 Chat Assistant</div>
        <div style="color: #6b7280; font-size: 11px;">Site: {site_name}</div>
    </div>
    """, unsafe_allow_html=True)
    
    # Chat history container
    chat_container = st.container()
    
    with chat_container:
        for msg in st.session_state.chat_messages[-10:]:  # Show last 10 messages
            if msg['role'] == 'user':
                st.markdown(f'<div class="user-msg">🧑 {msg["content"]}</div>', unsafe_allow_html=True)
            else:
                st.markdown(f'<div class="bot-msg">{msg["content"]}</div>', unsafe_allow_html=True)
    
    # Show last query result if exists
    if st.session_state.last_query_result is not None and not st.session_state.last_query_result.empty:
        with st.expander("📊 Últimos Resultados", expanded=True):
            st.dataframe(
                st.session_state.last_query_result,
                use_container_width=True,
                hide_index=True,
                height=150
            )
    
    # Chat input
    st.markdown("---")
    user_query = st.text_input(
        "Pregunta algo:",
        placeholder="ej: ios level, crusher rate, truck count...",
        key="chat_input",
        label_visibility="collapsed"
    )
    
    col1, col2 = st.columns([3, 1])
    with col2:
        send_btn = st.button("🚀", use_container_width=True)
    
    if send_btn and user_query:
        # Add user message
        st.session_state.chat_messages.append({
            'role': 'user',
            'content': user_query
        })
        
        # Translate to query
        result = translate_to_query(user_query, current_site)
        
        # Build response
        response_parts = [result['explanation']]
        
        if result['query']:
            response_parts.append(f"\n**Query ({result['source']}):**")
            response_parts.append(f"```\n{result['query'][:200]}...\n```" if len(result['query']) > 200 else f"```\n{result['query']}\n```")
            
            # Execute query
            if result['source'] == 'ADX':
                df = execute_adx_query(result['database'], result['query'])
            elif result['source'] == 'SNOWFLAKE':
                df = execute_snowflake_query(result['query'])
            else:
                df = pd.DataFrame()
            
            if not df.empty:
                response_parts.append(f"\n✅ **{len(df)} filas** retornadas")
                st.session_state.last_query_result = df
            else:
                response_parts.append("\n⚠️ Sin datos (requiere autenticación)")
        
        st.session_state.chat_messages.append({
            'role': 'assistant',
            'content': '\n'.join(response_parts)
        })
        
        st.rerun()
    
    # Quick actions
    st.markdown("<div style='margin-top: 10px; color: #6b7280; font-size: 10px;'>Quick:</div>", unsafe_allow_html=True)
    
    quick_cols = st.columns(3)
    quick_queries = ["ios level", "trucks", "crusher"]
    
    for i, q in enumerate(quick_queries):
        with quick_cols[i]:
            if st.button(q, key=f"quick_{q}", use_container_width=True):
                st.session_state.chat_messages.append({'role': 'user', 'content': q})
                result = translate_to_query(q, current_site)
                st.session_state.chat_messages.append({'role': 'assistant', 'content': result['explanation']})
                st.rerun()


# =============================================================================
# MAIN DASHBOARD
# =============================================================================
def render_dashboard(site_code: str):
    """Render the main dashboard for a site."""
    metrics = get_mock_metrics(site_code)
    site_config = SITES[site_code]
    
    # Header
    st.markdown(f"""
    <div style="display: flex; justify-content: space-between; align-items: center; padding: 8px 0;">
        <span style="color: white; font-size: 16px; font-weight: bold;">{site_config.name}</span>
        <span style="color: #6b7280; font-size: 12px;">{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</span>
    </div>
    """, unsafe_allow_html=True)
    
    # Section: LOADING
    st.markdown('<div class="section-header" style="background: #22c55e;">⚙️ LOADING</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    with col1:
        render_metric_card_compact(metrics['dig_compliance'])
    with col2:
        render_metric_card_compact(metrics['dig_rate'])
    
    render_shovels_table(metrics['priority_shovels'])
    
    # Section: HAULAGE
    st.markdown('<div class="section-header" style="background: #f97316;">🚚 HAULAGE</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    with col1:
        render_metric_card_compact(metrics['truck_count'])
    with col2:
        render_metric_card_compact(metrics['cycle_time'])
    
    # Section: THROUGHPUT
    st.markdown('<div class="section-header" style="background: #3b82f6;">🏭 THROUGHPUT</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    with col1:
        render_metric_card_compact(metrics['mill_crusher'])
    with col2:
        render_metric_card_compact(metrics['mfl_crusher'])
    
    # Section: IOS LEVEL
    st.markdown('<div class="section-header" style="background: #8b5cf6;">📊 IOS LEVEL</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    with col1:
        render_ios_gauge("Main IOS", metrics['ios_level']['main'])
    with col2:
        render_ios_gauge("Small IOS", metrics['ios_level']['small'])


# =============================================================================
# MAIN APP
# =============================================================================
def main():
    """Main application entry point."""
    
    # Site selector bar
    render_site_selector()
    
    st.markdown("<hr style='border-color: #333; margin: 8px 0;'>", unsafe_allow_html=True)
    
    # Main layout: Dashboard (75%) | Chat (25%)
    col_dashboard, col_chat = st.columns([3, 1])
    
    with col_dashboard:
        render_dashboard(st.session_state.selected_site)
    
    with col_chat:
        render_chat_interface()
    
    # Footer
    st.markdown(f"""
    <div style="text-align: center; color: #4b5563; font-size: 10px; margin-top: 20px; padding: 10px;">
        IROC Intelligent Dashboard v1.0 | {datetime.now().strftime('%Y-%m-%d %H:%M')} | 
        Site: {SITES[st.session_state.selected_site].name}
    </div>
    """, unsafe_allow_html=True)


if __name__ == "__main__":
    main()
