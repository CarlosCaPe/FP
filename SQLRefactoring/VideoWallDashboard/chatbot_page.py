"""
💬 Mining Operations Chatbot - Standalone Page
===============================================
Natural language interface to query ADX and Snowflake.
Query ANY site from this single interface.

Run with: streamlit run chatbot_page.py
"""

import streamlit as st
import pandas as pd
from datetime import datetime
from typing import Dict, Any, List, Optional
import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent))

# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="⛏️ Mining Ops Chatbot",
    page_icon="💬",
    layout="wide",
    initial_sidebar_state="expanded",
)

# =============================================================================
# DARK CHATGPT-STYLE THEME
# =============================================================================
st.markdown("""
<style>
    /* Dark background */
    .stApp {
        background-color: #1a1a2e;
    }
    
    /* Sidebar */
    [data-testid="stSidebar"] {
        background-color: #16213e;
    }
    [data-testid="stSidebar"] .stMarkdown {
        color: #e2e8f0;
    }
    
    /* Remove padding */
    .block-container {
        padding: 1rem 2rem;
        max-width: 1200px;
    }
    
    /* Chat container */
    .chat-container {
        max-width: 900px;
        margin: 0 auto;
    }
    
    /* User message */
    .user-message {
        background: #2d3748;
        padding: 14px 18px;
        border-radius: 12px 12px 4px 12px;
        margin: 12px 0;
        border-left: 4px solid #4299e1;
    }
    .user-message .label {
        color: #4299e1;
        font-size: 11px;
        font-weight: bold;
        margin-bottom: 4px;
    }
    .user-message .content {
        color: #e2e8f0;
        font-size: 14px;
    }
    
    /* Assistant message */
    .assistant-message {
        background: #1e293b;
        padding: 14px 18px;
        border-radius: 12px 12px 12px 4px;
        margin: 12px 0;
        border-left: 4px solid #48bb78;
    }
    .assistant-message .label {
        color: #48bb78;
        font-size: 11px;
        font-weight: bold;
        margin-bottom: 4px;
    }
    .assistant-message .content {
        color: #cbd5e0;
        font-size: 14px;
    }
    
    /* Query block */
    .query-block {
        background: #0d1117;
        border: 1px solid #30363d;
        border-radius: 6px;
        padding: 12px;
        font-family: 'Cascadia Code', 'Fira Code', 'Courier New', monospace;
        font-size: 12px;
        color: #79c0ff;
        overflow-x: auto;
        margin: 10px 0;
        white-space: pre-wrap;
    }
    
    /* Results badge */
    .result-badge {
        display: inline-block;
        background: #166534;
        color: #4ade80;
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 11px;
        font-weight: bold;
        margin: 8px 0;
    }
    
    /* Site selector pills */
    .site-pill {
        display: inline-block;
        padding: 6px 14px;
        margin: 3px;
        border-radius: 16px;
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }
    .site-pill-active {
        background: #f97316;
        color: white;
    }
    .site-pill-inactive {
        background: #374151;
        color: #9ca3af;
    }
    
    /* Quick query buttons */
    .quick-btn {
        background: #374151;
        color: #e2e8f0;
        border: 1px solid #4b5563;
        padding: 8px 14px;
        border-radius: 8px;
        font-size: 12px;
        margin: 4px;
        cursor: pointer;
    }
    .quick-btn:hover {
        background: #4b5563;
    }
    
    /* Headers */
    h1, h2, h3 {
        color: #f1f5f9 !important;
    }
    
    /* Hide streamlit branding */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
</style>
""", unsafe_allow_html=True)

# =============================================================================
# SITES CONFIGURATION
# =============================================================================
SITES = {
    "MOR": {"name": "Morenci", "database": "Morenci", "has_snowflake": True},
    "BAG": {"name": "Bagdad", "database": "Bagdad", "has_snowflake": True},
    "SIE": {"name": "Sierrita", "database": "Sierrita", "has_snowflake": True},
    "SAM": {"name": "Miami", "database": "Miami", "has_snowflake": False},
    "CMX": {"name": "Climax", "database": "Climax", "has_snowflake": False},
    "NMO": {"name": "New Mexico", "database": "NewMexico", "has_snowflake": False},
    "CVE": {"name": "Cerro Verde", "database": "CerroVerde", "has_snowflake": False},
}

# =============================================================================
# SESSION STATE
# =============================================================================
if 'chat_messages' not in st.session_state:
    st.session_state.chat_messages = []
if 'selected_site' not in st.session_state:
    st.session_state.selected_site = 'MOR'
if 'adx_client' not in st.session_state:
    st.session_state.adx_client = None
if 'snowflake_conn' not in st.session_state:
    st.session_state.snowflake_conn = None

# =============================================================================
# DATA CONNECTIONS
# =============================================================================
def connect_adx():
    """Connect to ADX."""
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
            st.error(f"ADX connection failed: {e}")
            return False
    return True

def connect_snowflake():
    """Connect to Snowflake."""
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
            st.error(f"Snowflake connection failed: {e}")
            return False
    return True

def execute_adx(database: str, kql: str) -> pd.DataFrame:
    """Execute KQL query."""
    if st.session_state.adx_client is None:
        return pd.DataFrame()
    try:
        result = st.session_state.adx_client.execute(database, kql)
        columns = [col.column_name for col in result.primary_results[0].columns]
        data = [list(row) for row in result.primary_results[0]]
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        st.error(f"Query error: {e}")
        return pd.DataFrame()

def execute_snowflake(sql: str) -> pd.DataFrame:
    """Execute Snowflake query."""
    if st.session_state.snowflake_conn is None:
        return pd.DataFrame()
    try:
        cursor = st.session_state.snowflake_conn.cursor()
        cursor.execute(sql)
        columns = [desc[0] for desc in cursor.description]
        data = cursor.fetchall()
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        st.error(f"Query error: {e}")
        return pd.DataFrame()

# =============================================================================
# NLP QUERY TRANSLATOR
# =============================================================================
def translate_query(user_input: str, site_code: str) -> Dict[str, Any]:
    """Translate natural language to query."""
    user_lower = user_input.lower()
    site = SITES[site_code]
    database = site["database"]
    
    result = {
        "source": "ADX",
        "database": database,
        "site": site_code,
        "site_name": site["name"],
        "query": "",
        "explanation": "",
        "success": True
    }
    
    # === IOS LEVEL ===
    if any(w in user_lower for w in ['ios', 'stockpile', 'level', 'nivel']):
        result["explanation"] = f"📊 **IOS Level** - {site['name']}\nNivel actual del stockpile de mineral"
        if site_code == 'MOR':
            result["query"] = """FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project 
    Sensor = sensor_id,
    Level_Pct = round(todouble(value), 2),
    Timestamp = timestamp,
    UOM = uom
| order by Level_Pct desc"""
        else:
            result["query"] = """FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'Level'
| where todouble(value) > 0 and todouble(value) < 100
| project Sensor = sensor_id, Level = round(todouble(value), 2), Timestamp = timestamp
| order by Level desc
| take 10"""
    
    # === CRUSHER RATE ===
    elif any(w in user_lower for w in ['crusher', 'crushing', 'triturador', 'chancadora']):
        result["explanation"] = f"🔨 **Crusher Rate** - {site['name']}\nTasa de trituración en TPH"
        if site_code == 'MOR':
            result["query"] = """FCTSCURRENT()
| where sensor_id in ('MOR-CR03_WI00317_PV', 'MOR-CR02_WI01203_PV')
| project 
    Crusher = case(
        sensor_id == 'MOR-CR03_WI00317_PV', 'Mill Crusher #3',
        sensor_id == 'MOR-CR02_WI01203_PV', 'MFL Crusher',
        sensor_id),
    Rate_TPH = round(todouble(value), 0),
    Status = case(
        todouble(value) >= 8000, '✅ ON TARGET',
        todouble(value) >= 6000, '⚠️ BELOW',
        '🔴 LOW'),
    Timestamp = timestamp"""
        else:
            result["query"] = """FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'Crusher'
| where todouble(value) > 100
| project Sensor = sensor_id, Rate_TPH = round(todouble(value), 0), Timestamp = timestamp
| order by Rate_TPH desc
| take 10"""
    
    # === DIG RATE ===
    elif any(w in user_lower for w in ['dig', 'loading', 'shovel', 'pala', 'carga']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"⛏️ **Dig Rate** - {site['name']}\nTasa de excavación (últimas 24h)"
        result["query"] = f"""SELECT 
    '{site_code}' as SITE,
    COUNT(DISTINCT EXCAV_ID) as SHOVELS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / 
          NULLIF(TIMESTAMPDIFF(minute, MIN(CYCLE_START_TS_LOCAL), MAX(CYCLE_START_TS_LOCAL)) / 60.0, 0)) as DIG_RATE_TPOH
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    
    # === TRUCK COUNT ===
    elif any(w in user_lower for w in ['truck', 'camion', 'fleet', 'flota', 'haul']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"🚚 **Truck Count** - {site['name']}\nCamiones activos y ciclos"
        result["query"] = f"""SELECT 
    '{site_code}' as SITE,
    COUNT(DISTINCT TRUCK_ID) as ACTIVE_TRUCKS,
    COUNT(*) as TOTAL_CYCLES,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TONS_HAULED
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    
    # === CYCLE TIME ===
    elif any(w in user_lower for w in ['cycle', 'time', 'tiempo', 'ciclo']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"⏱️ **Cycle Time** - {site['name']}\nTiempo promedio de ciclo"
        result["query"] = f"""SELECT 
    '{site_code}' as SITE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MIN_MIN,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MAX_MIN,
    COUNT(*) as CYCLES
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS BETWEEN 10 AND 120"""
    
    # === TOP SHOVELS ===
    elif any(w in user_lower for w in ['top', 'best', 'priority', 'ranking', 'mejores']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"🏆 **Top Shovels** - {site['name']}\nPalas con mayor producción"
        result["query"] = f"""SELECT 
    EXCAV_ID as SHOVEL,
    COUNT(*) as LOADS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS), 1) as AVG_LOAD
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY EXCAV_ID
ORDER BY TOTAL_TONS DESC
LIMIT 5"""
    
    # === MILL RATE ===
    elif any(w in user_lower for w in ['mill', 'molino', 'sag', 'ball']):
        result["explanation"] = f"🏭 **Mill Rate** - {site['name']}\nTasa de molienda"
        result["query"] = """FCTSCURRENT()
| where sensor_id contains 'Mill' or sensor_id contains 'SAG' or sensor_id contains 'Ball'
| where todouble(value) > 50
| project Sensor = sensor_id, Rate = round(todouble(value), 0), Timestamp = timestamp
| order by Rate desc
| take 10"""
    
    # === ALL SENSORS ===
    elif any(w in user_lower for w in ['sensor', 'all', 'todo', 'sensores']):
        result["explanation"] = f"📡 **Active Sensors** - {site['name']}\nSensores con lecturas recientes"
        result["query"] = """FCTSCURRENT()
| where todouble(value) > 0
| summarize Count = count(), LastReading = max(timestamp) by sensor_id
| order by LastReading desc
| take 20"""
    
    # === TONS DELIVERED ===
    elif any(w in user_lower for w in ['tons', 'delivered', 'dump', 'toneladas']):
        result["source"] = "SNOWFLAKE"
        result["explanation"] = f"📦 **Tons Delivered** - {site['name']}\nToneladas por destino"
        result["query"] = f"""SELECT 
    DUMP_LOC_ID as DESTINATION,
    COUNT(*) as DUMPS,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TOTAL_TONS
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site_code}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY DUMP_LOC_ID
ORDER BY TOTAL_TONS DESC
LIMIT 10"""
    
    # === HELP ===
    else:
        result["success"] = False
        result["explanation"] = """❓ **Comandos disponibles:**

**ADX (Real-time sensors):**
🔹 `ios level` - Nivel de stockpile
🔹 `crusher rate` - Tasa de crusher
🔹 `mill rate` - Tasa de molino
🔹 `all sensors` - Lista de sensores

**Snowflake (Historical):**
🔹 `dig rate` - Tasa de excavación
🔹 `truck count` - Conteo de camiones
🔹 `cycle time` - Tiempo de ciclo
🔹 `top shovels` - Mejores palas
🔹 `tons delivered` - Toneladas entregadas

💡 **Tip:** Cambia el site en la barra lateral"""
    
    return result

# =============================================================================
# SIDEBAR
# =============================================================================
def render_sidebar():
    """Render sidebar with site selector and info."""
    st.sidebar.markdown("# 💬 Mining Chatbot")
    st.sidebar.markdown("---")
    
    # Site selector
    st.sidebar.markdown("### 🌍 Select Site")
    
    selected = st.sidebar.radio(
        "Site:",
        options=list(SITES.keys()),
        format_func=lambda x: f"{SITES[x]['name']} ({x})",
        index=list(SITES.keys()).index(st.session_state.selected_site),
        label_visibility="collapsed"
    )
    
    if selected != st.session_state.selected_site:
        st.session_state.selected_site = selected
        st.rerun()
    
    # Site info
    site = SITES[st.session_state.selected_site]
    st.sidebar.markdown(f"""
    **ADX Database:** `{site['database']}`  
    **Snowflake:** {'✅ Available' if site['has_snowflake'] else '⚠️ ADX Only'}
    """)
    
    st.sidebar.markdown("---")
    
    # Connection status
    st.sidebar.markdown("### 🔐 Connections")
    
    col1, col2 = st.sidebar.columns(2)
    with col1:
        if st.button("Connect ADX", use_container_width=True):
            with st.spinner("Connecting..."):
                if connect_adx():
                    st.success("✅ ADX")
    with col2:
        if st.button("Connect SF", use_container_width=True):
            with st.spinner("Connecting..."):
                if connect_snowflake():
                    st.success("✅ SF")
    
    adx_status = "🟢" if st.session_state.adx_client else "⚪"
    sf_status = "🟢" if st.session_state.snowflake_conn else "⚪"
    st.sidebar.markdown(f"Status: ADX {adx_status} | SF {sf_status}")
    
    st.sidebar.markdown("---")
    
    # Quick queries
    st.sidebar.markdown("### ⚡ Quick Queries")
    
    quick_queries = [
        ("📊 IOS Level", "ios level"),
        ("🔨 Crusher", "crusher rate"),
        ("🚚 Trucks", "truck count"),
        ("⏱️ Cycle Time", "cycle time"),
        ("⛏️ Dig Rate", "dig rate"),
        ("🏆 Top Shovels", "top shovels"),
    ]
    
    for label, query in quick_queries:
        if st.sidebar.button(label, key=f"quick_{query}", use_container_width=True):
            process_query(query)
    
    st.sidebar.markdown("---")
    
    # Clear chat
    if st.sidebar.button("🗑️ Clear Chat", use_container_width=True):
        st.session_state.chat_messages = []
        st.rerun()
    
    # Link to dashboard
    st.sidebar.markdown("---")
    st.sidebar.markdown("### 📊 Dashboard")
    st.sidebar.markdown("[Open Video Wall →](./app_v2.py)")

# =============================================================================
# PROCESS QUERY
# =============================================================================
def process_query(user_input: str):
    """Process user query and add to chat."""
    site_code = st.session_state.selected_site
    
    # Add user message
    st.session_state.chat_messages.append({
        "role": "user",
        "content": user_input,
        "site": site_code,
        "timestamp": datetime.now().strftime("%H:%M")
    })
    
    # Translate query
    result = translate_query(user_input, site_code)
    
    # Execute if we have a query
    df = pd.DataFrame()
    if result["success"] and result["query"]:
        if result["source"] == "ADX" and st.session_state.adx_client:
            df = execute_adx(result["database"], result["query"])
        elif result["source"] == "SNOWFLAKE" and st.session_state.snowflake_conn:
            df = execute_snowflake(result["query"])
    
    # Add assistant message
    st.session_state.chat_messages.append({
        "role": "assistant",
        "content": result["explanation"],
        "query": result["query"] if result["success"] else "",
        "source": result["source"] if result["success"] else "",
        "dataframe": df,
        "timestamp": datetime.now().strftime("%H:%M")
    })
    
    st.rerun()

# =============================================================================
# RENDER CHAT
# =============================================================================
def render_chat():
    """Render chat messages."""
    for msg in st.session_state.chat_messages:
        if msg["role"] == "user":
            st.markdown(f"""
            <div class="user-message">
                <div class="label">🧑 You • {msg.get('timestamp', '')} • Site: {msg.get('site', 'MOR')}</div>
                <div class="content">{msg['content']}</div>
            </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown(f"""
            <div class="assistant-message">
                <div class="label">🤖 Assistant • {msg.get('timestamp', '')}</div>
                <div class="content">{msg['content']}</div>
            </div>
            """, unsafe_allow_html=True)
            
            # Show query if exists
            if msg.get("query"):
                st.markdown(f"""
                <div style="margin: 0 0 10px 0;">
                    <span style="color: #6b7280; font-size: 11px;">Query ({msg.get('source', 'ADX')}):</span>
                </div>
                <div class="query-block">{msg['query']}</div>
                """, unsafe_allow_html=True)
            
            # Show results if exists
            if msg.get("dataframe") is not None and not msg["dataframe"].empty:
                st.markdown(f'<div class="result-badge">✅ {len(msg["dataframe"])} rows</div>', unsafe_allow_html=True)
                st.dataframe(msg["dataframe"], use_container_width=True, hide_index=True, height=200)
            elif msg.get("query") and (msg.get("dataframe") is None or msg["dataframe"].empty):
                st.markdown('<div style="color: #f97316; font-size: 12px;">⚠️ No data returned - connect to data source first</div>', unsafe_allow_html=True)

# =============================================================================
# MAIN
# =============================================================================
def main():
    render_sidebar()
    
    # Header
    site = SITES[st.session_state.selected_site]
    st.markdown(f"""
    <div style="text-align: center; margin-bottom: 20px;">
        <h1 style="margin: 0;">⛏️ Mining Operations Chatbot</h1>
        <p style="color: #6b7280; margin: 5px 0;">Query ADX & Snowflake using natural language</p>
        <p style="color: #f97316; font-size: 14px;">Current Site: <strong>{site['name']}</strong></p>
    </div>
    """, unsafe_allow_html=True)
    
    # Chat container
    chat_container = st.container()
    
    with chat_container:
        if not st.session_state.chat_messages:
            st.markdown("""
            <div style="text-align: center; padding: 40px; color: #6b7280;">
                <div style="font-size: 48px; margin-bottom: 16px;">💬</div>
                <div style="font-size: 16px;">Start by asking a question...</div>
                <div style="font-size: 13px; margin-top: 8px;">
                    Try: "ios level", "crusher rate", "truck count", "cycle time"
                </div>
            </div>
            """, unsafe_allow_html=True)
        else:
            render_chat()
    
    # Input area
    st.markdown("---")
    
    col1, col2 = st.columns([6, 1])
    with col1:
        user_input = st.text_input(
            "Ask a question:",
            placeholder="e.g., ios level, crusher rate, truck count, cycle time...",
            key="chat_input",
            label_visibility="collapsed"
        )
    with col2:
        send = st.button("🚀 Send", use_container_width=True)
    
    if send and user_input:
        process_query(user_input)
    
    # Footer
    st.markdown(f"""
    <div style="text-align: center; color: #4b5563; font-size: 11px; margin-top: 30px;">
        Mining Ops Chatbot v2.0 | ADX: fctsnaproddatexp02 | {datetime.now().strftime('%Y-%m-%d %H:%M')}
    </div>
    """, unsafe_allow_html=True)


if __name__ == "__main__":
    main()
