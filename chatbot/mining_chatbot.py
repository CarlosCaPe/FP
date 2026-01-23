"""
🏭 Mining Operations Chatbot
==============================
Chat interface to query ADX and Snowflake using natural language.
Uses the ADX_UNIFIED semantic model as the source of truth.

Run with: streamlit run chatbot/mining_chatbot.py
"""

import streamlit as st
import pandas as pd
import yaml
from pathlib import Path
from datetime import datetime
import re

# =============================================================================
# PAGE CONFIG - Dark Theme
# =============================================================================
st.set_page_config(
    page_title="⛏️ Mining Ops Chat",
    page_icon="⛏️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for dark ChatGPT-like style
st.markdown("""
<style>
    /* Main background */
    .stApp {
        background-color: #1a1a2e;
    }
    
    /* Sidebar */
    [data-testid="stSidebar"] {
        background-color: #16213e;
    }
    
    /* Chat messages */
    .user-message {
        background-color: #2d3748;
        padding: 15px;
        border-radius: 10px;
        margin: 10px 0;
        border-left: 4px solid #4299e1;
    }
    
    .assistant-message {
        background-color: #1e293b;
        padding: 15px;
        border-radius: 10px;
        margin: 10px 0;
        border-left: 4px solid #48bb78;
    }
    
    /* Code blocks */
    .stCodeBlock {
        background-color: #0d1117 !important;
    }
    
    /* Headers */
    h1, h2, h3 {
        color: #e2e8f0 !important;
    }
    
    /* Text */
    p, span, label {
        color: #cbd5e0 !important;
    }
    
    /* Input box */
    .stTextInput input {
        background-color: #2d3748 !important;
        color: #e2e8f0 !important;
        border: 1px solid #4a5568 !important;
    }
    
    /* Buttons */
    .stButton button {
        background-color: #4299e1 !important;
        color: white !important;
    }
    
    /* Tables */
    .dataframe {
        background-color: #1e293b !important;
    }
    
    /* Success/Error boxes */
    .success-box {
        background-color: #1c4532;
        padding: 10px;
        border-radius: 5px;
        border-left: 4px solid #48bb78;
    }
    
    .error-box {
        background-color: #4a1c1c;
        padding: 10px;
        border-radius: 5px;
        border-left: 4px solid #f56565;
    }
    
    /* Query box */
    .query-box {
        background-color: #0d1117;
        padding: 15px;
        border-radius: 8px;
        font-family: 'Courier New', monospace;
        margin: 10px 0;
    }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# LOAD SEMANTIC MODEL
# =============================================================================
@st.cache_data
def load_semantic_model():
    """Load the ADX_UNIFIED semantic model."""
    model_path = Path(__file__).parent.parent / "SQLRefactoring" / "adx_semantic_models" / "ADX_UNIFIED.semantic.yaml"
    
    if not model_path.exists():
        st.error(f"❌ Semantic model not found: {model_path}")
        return None
    
    with open(model_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

# =============================================================================
# CONNECTION MANAGERS
# =============================================================================
def get_adx_client():
    """Get or create ADX client (cached in session)."""
    if 'adx_client' not in st.session_state:
        try:
            from azure.identity import InteractiveBrowserCredential
            from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
            
            cluster = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
            credential = InteractiveBrowserCredential()
            kcsb = KustoConnectionStringBuilder.with_azure_token_credential(cluster, credential)
            st.session_state['adx_client'] = KustoClient(kcsb)
            st.session_state['adx_authenticated'] = True
        except Exception as e:
            st.error(f"❌ ADX Auth Error: {e}")
            return None
    return st.session_state.get('adx_client')

def get_snowflake_connection():
    """Get or create Snowflake connection (cached in session)."""
    if 'snowflake_conn' not in st.session_state:
        try:
            import snowflake.connector
            
            conn = snowflake.connector.connect(
                account="FCX-NA",
                authenticator="externalbrowser",
                warehouse="WH_BATCH_DE_NONPROD",
                database="PROD_WG",
                schema="LOAD_HAUL"
            )
            st.session_state['snowflake_conn'] = conn
            st.session_state['snowflake_authenticated'] = True
        except Exception as e:
            st.error(f"❌ Snowflake Auth Error: {e}")
            return None
    return st.session_state.get('snowflake_conn')

# =============================================================================
# QUERY EXECUTION
# =============================================================================
def execute_adx_query(database: str, kql: str) -> pd.DataFrame:
    """Execute KQL query and return DataFrame."""
    client = get_adx_client()
    if not client:
        return pd.DataFrame()
    
    try:
        result = client.execute(database, kql)
        columns = [col.column_name for col in result.primary_results[0].columns]
        data = [list(row) for row in result.primary_results[0]]
        return pd.DataFrame(data, columns=columns)
    except Exception as e:
        st.error(f"❌ ADX Query Error: {e}")
        return pd.DataFrame()

def execute_snowflake_query(sql: str) -> pd.DataFrame:
    """Execute Snowflake query and return DataFrame."""
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
        st.error(f"❌ Snowflake Query Error: {e}")
        return pd.DataFrame()

# =============================================================================
# QUERY BUILDER - Interprets natural language
# =============================================================================
def interpret_query(user_input: str, model: dict) -> dict:
    """
    Interpret user input and generate appropriate query.
    Returns: {source, database, query, explanation, outcome}
    """
    user_lower = user_input.lower()
    
    # Extract site from input
    sites = ['mor', 'bag', 'sam', 'cmx', 'sie', 'nmo', 'cve', 
             'morenci', 'bagdad', 'miami', 'climax', 'sierrita', 'newmexico', 'cerroverde']
    detected_site = None
    for site in sites:
        if site in user_lower:
            detected_site = site.upper()[:3]
            if detected_site == 'MOR' or 'morenci' in user_lower:
                detected_site = 'MOR'
            elif detected_site == 'BAG' or 'bagdad' in user_lower:
                detected_site = 'BAG'
            elif detected_site == 'MIA' or 'miami' in user_lower:
                detected_site = 'SAM'
            elif detected_site == 'CLI' or 'climax' in user_lower:
                detected_site = 'CMX'
            elif detected_site == 'SIE' or 'sierrita' in user_lower:
                detected_site = 'SIE'
            elif detected_site == 'NEW' or 'newmexico' in user_lower:
                detected_site = 'NMO'
            elif detected_site == 'CER' or 'cerroverde' in user_lower:
                detected_site = 'CVE'
            break
    
    if not detected_site:
        detected_site = 'MOR'  # Default to Morenci
    
    # Get site config
    site_config = model.get(detected_site, {})
    adx_database = site_config.get('adx_database', 'Morenci')
    
    # Detect outcome type
    result = {
        'source': 'ADX',
        'database': adx_database,
        'site': detected_site,
        'query': '',
        'explanation': '',
        'outcome': ''
    }
    
    # IOS / Stockpile Level
    if any(word in user_lower for word in ['ios', 'stockpile', 'level', 'inventory']):
        result['outcome'] = '11_mill_strategy'
        result['explanation'] = f"📊 **IOS Level (In-Ore Stockpile)** for {detected_site}\nShows current stockpile level and trend."
        
        if detected_site == 'MOR':
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
    
    # Crusher Rate
    elif any(word in user_lower for word in ['crusher', 'crushing']):
        result['outcome'] = '09_mill_crusher'
        result['explanation'] = f"🔨 **Crusher Rate** for {detected_site}\nCurrent crushing rate in TPH (tons per hour)."
        
        if detected_site == 'MOR':
            result['query'] = """FCTSCURRENT()
| where sensor_id in ('MOR-CR03_WI00317_PV', 'MOR-CR02_WI01203_PV')
| project 
    Crusher = case(
        sensor_id == 'MOR-CR03_WI00317_PV', 'Mill Crusher #3',
        sensor_id == 'MOR-CR02_WI01203_PV', 'MFL Crusher',
        sensor_id),
    Rate_TPH = round(todouble(value), 0),
    Target_Min = iff(sensor_id == 'MOR-CR03_WI00317_PV', 8500, 4500),
    Target_Max = iff(sensor_id == 'MOR-CR03_WI00317_PV', 9000, 6000),
    Status = case(
        todouble(value) >= 8500 and todouble(value) <= 9000, '✅ ON TARGET',
        todouble(value) < 8500, '⚠️ BELOW',
        '🔴 ABOVE'),
    Timestamp = timestamp"""
        else:
            result['query'] = f"""FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'Crusher'
| where todouble(value) > 100
| project Sensor = sensor_id, Rate_TPH = round(todouble(value), 0), Timestamp = timestamp
| order by Rate_TPH desc
| take 10"""
    
    # Dig Rate / Loading
    elif any(word in user_lower for word in ['dig', 'loading', 'shovel', 'excavator']):
        result['source'] = 'SNOWFLAKE'
        result['outcome'] = '02_dig_rate'
        result['explanation'] = f"⛏️ **Dig Rate** for {detected_site}\nExcavation rate in TPOH. Data from the last 24 hours."
        result['query'] = f"""SELECT 
    '{detected_site}' as SITE,
    COUNT(DISTINCT EXCAV_ID) as SHOVEL_COUNT,
    ROUND(SUM(LOAD_TONNAGE)) as TOTAL_TONS,
    ROUND(SUM(LOAD_TONNAGE) / NULLIF(SUM(LOAD_DURATION_MIN)/60, 0)) as DIG_RATE_TPOH
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{detected_site}'
  AND LOAD_END_UTC >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY SITE_CODE"""
    
    # Truck Count / Haulage
    elif any(word in user_lower for word in ['truck', 'haul', 'fleet']):
        result['source'] = 'SNOWFLAKE'
        result['outcome'] = '04_truck_count'
        result['explanation'] = f"🚚 **Truck Count & Haulage** for {detected_site}\nActive trucks and haulage statistics."
        result['query'] = f"""SELECT 
    '{detected_site}' as SITE,
    COUNT(DISTINCT TRUCK_ID) as ACTIVE_TRUCKS,
    COUNT(*) as TOTAL_CYCLES,
    ROUND(AVG(CYCLE_DURATION_MIN), 1) as AVG_CYCLE_MIN,
    ROUND(SUM(PAYLOAD_TONS)) as TOTAL_TONS_HAULED
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{detected_site}'
  AND DUMP_TIME_UTC >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY SITE_CODE"""
    
    # Cycle Time
    elif any(word in user_lower for word in ['cycle', 'time']):
        result['source'] = 'SNOWFLAKE'
        result['outcome'] = '05_cycle_time'
        result['explanation'] = f"⏱️ **Cycle Time** for {detected_site}\nAverage truck cycle time."
        result['query'] = f"""SELECT 
    '{detected_site}' as SITE,
    ROUND(AVG(CYCLE_DURATION_MIN), 1) as AVG_CYCLE_MIN,
    ROUND(MIN(CYCLE_DURATION_MIN), 1) as MIN_CYCLE_MIN,
    ROUND(MAX(CYCLE_DURATION_MIN), 1) as MAX_CYCLE_MIN,
    ROUND(STDDEV(CYCLE_DURATION_MIN), 1) as STDDEV_MIN,
    COUNT(*) as TOTAL_CYCLES
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{detected_site}'
  AND DUMP_TIME_UTC >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND CYCLE_DURATION_MIN BETWEEN 10 AND 120
GROUP BY SITE_CODE"""
    
    # Mill Rate
    elif any(word in user_lower for word in ['mill', 'ball', 'sag']):
        result['outcome'] = '10_mill_rate'
        result['explanation'] = f"🏭 **Mill Rate** for {detected_site}\nCurrent milling rate."
        result['query'] = f"""FCTSCURRENT()
| where sensor_id contains 'Mill' or sensor_id contains 'SAG' or sensor_id contains 'Ball'
| where todouble(value) > 50
| project Sensor = sensor_id, Rate = round(todouble(value), 0), Timestamp = timestamp, UOM = uom
| order by Rate desc
| take 10"""
    
    # Priority Shovels
    elif any(word in user_lower for word in ['priority', 'top', 'best', 'ranking']):
        result['source'] = 'SNOWFLAKE'
        result['outcome'] = '03_priority_shovels'
        result['explanation'] = f"🏆 **Top 5 Shovels** for {detected_site}\nHighest producing shovels in the last 24h."
        result['query'] = f"""SELECT 
    EXCAV_ID as SHOVEL,
    COUNT(*) as LOADS,
    ROUND(SUM(LOAD_TONNAGE)) as TOTAL_TONS,
    ROUND(AVG(LOAD_TONNAGE), 1) as AVG_LOAD
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{detected_site}'
  AND LOAD_END_UTC >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY EXCAV_ID
ORDER BY TOTAL_TONS DESC
LIMIT 5"""
    
    # Tons delivered (Mill, MFL, ROM)
    elif any(word in user_lower for word in ['tons', 'delivered', 'dump']):
        result['source'] = 'SNOWFLAKE'
        result['outcome'] = '08_mill_tons'
        result['explanation'] = f"📦 **Tons Delivered by Destination** for {detected_site}\nTons by destination (Mill, MFL, ROM)."
        result['query'] = f"""SELECT 
    DUMP_LOCATION as DESTINATION,
    COUNT(*) as DUMPS,
    ROUND(SUM(PAYLOAD_TONS)) as TOTAL_TONS
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{detected_site}'
  AND DUMP_TIME_UTC >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY DUMP_LOCATION
ORDER BY TOTAL_TONS DESC"""
    
    # All current sensors
    elif any(word in user_lower for word in ['sensor', 'all', 'list']):
        result['explanation'] = f"📡 **All Active Sensors** for {detected_site}\nList of sensors with recent data."
        result['query'] = f"""FCTSCURRENT()
| where todouble(value) > 0
| summarize 
    Count = count(),
    Last_Reading = max(timestamp)
    by sensor_id
| order by Last_Reading desc
| take 20"""
    
    # Default - show help
    else:
        result['source'] = 'HELP'
        result['explanation'] = "❓ **I didn't understand your query.**\nUse keywords like: `ios`, `crusher`, `truck`, `dig`, `cycle`, `mill`, `tons`"
        result['query'] = ''
    
    return result

# =============================================================================
# SIDEBAR - Reference Info
# =============================================================================
def render_sidebar(model):
    st.sidebar.markdown("# ⛏️ Mining Ops Chat")
    st.sidebar.markdown("---")
    
    # Auth Status
    st.sidebar.markdown("### 🔐 Auth Status")
    adx_auth = "✅" if st.session_state.get('adx_authenticated') else "⚪"
    snow_auth = "✅" if st.session_state.get('snowflake_authenticated') else "⚪"
    st.sidebar.markdown(f"{adx_auth} ADX | {snow_auth} Snowflake")
    
    st.sidebar.markdown("---")
    
    # Sites Reference
    st.sidebar.markdown("### 🌍 Available Sites")
    sites_info = """
| Code | Name | Data |
|------|------|------|
| MOR | Morenci | ✅ Full |
| BAG | Bagdad | ✅ Full |
| SIE | Sierrita | ✅ Partial |
| SAM | Miami | ⚠️ ADX Only |
| CMX | Climax | ⚠️ ADX Only |
| NMO | NewMexico | ⚠️ ADX Only |
| CVE | CerroVerde | ⚠️ ADX Only |
"""
    st.sidebar.markdown(sites_info)
    
    st.sidebar.markdown("---")
    
    # Outcomes Reference
    st.sidebar.markdown("### 📊 Outcomes (KPIs)")
    outcomes_list = """
**Loading:**
- `dig compliance` - % compliance
- `dig rate` - TPOH excavation
- `priority shovels` - Top 5 shovels

**Haulage:**
- `truck count` - Active trucks
- `cycle time` - Cycle time
- `dump compliance` - % compliance

**Mill:**
- `mill tons` - Tons delivered
- `crusher rate` - TPH crusher
- `mill rate` - TPH milling
- `ios level` - Stockpile level ⭐

**MFL/ROM:**
- `mfl tons` - MFL tons
- `rom tons` - ROM tons
"""
    st.sidebar.markdown(outcomes_list)
    
    st.sidebar.markdown("---")
    
    # Example queries
    st.sidebar.markdown("### 💡 Examples")
    examples = [
        "ios level morenci",
        "crusher rate MOR",
        "truck count bagdad",
        "dig rate sierrita",
        "top shovels MOR",
        "cycle time BAG",
        "mill tons morenci"
    ]
    for ex in examples:
        if st.sidebar.button(f"📝 {ex}", key=ex):
            st.session_state['example_query'] = ex

# =============================================================================
# MAIN CHAT INTERFACE
# =============================================================================
def main():
    # Load semantic model
    model = load_semantic_model()
    if not model:
        st.error("Failed to load semantic model")
        return
    
    # Render sidebar
    render_sidebar(model)
    
    # Initialize chat history
    if 'messages' not in st.session_state:
        st.session_state['messages'] = []
    
    # Header
    st.markdown("# ⛏️ Mining Operations Chatbot")
    st.markdown("*Query ADX and Snowflake data using natural language*")
    st.markdown("---")
    
    # Display chat history
    for msg in st.session_state['messages']:
        if msg['role'] == 'user':
            st.markdown(f"""<div class="user-message">
                <strong>🧑 You:</strong><br>{msg['content']}
            </div>""", unsafe_allow_html=True)
        else:
            st.markdown(f"""<div class="assistant-message">
                {msg['content']}
            </div>""", unsafe_allow_html=True)
    
    # Check for example query
    if 'example_query' in st.session_state:
        user_input = st.session_state.pop('example_query')
    else:
        user_input = None
    
    # Chat input
    col1, col2 = st.columns([6, 1])
    with col1:
        query_input = st.text_input(
            "💬 Your query:",
            placeholder="Ex: ios level morenci, crusher rate BAG, truck count sierrita...",
            key="chat_input",
            value=user_input or ""
        )
    with col2:
        send_button = st.button("🚀 Send", use_container_width=True)
    
    # Process query
    if (send_button or user_input) and (query_input or user_input):
        final_query = query_input or user_input
        
        # Add user message
        st.session_state['messages'].append({
            'role': 'user',
            'content': final_query
        })
        
        # Interpret and execute
        result = interpret_query(final_query, model)
        
        # Build response
        response_parts = []
        response_parts.append(f"**🤖 Assistant**")
        response_parts.append(result['explanation'])
        
        if result['query']:
            response_parts.append(f"\n**📄 Query ({result['source']}):**")
            response_parts.append(f"```{'sql' if result['source'] == 'SNOWFLAKE' else 'kql'}\n{result['query']}\n```")
            
            # Execute query
            if result['source'] == 'ADX':
                with st.spinner(f"🔄 Querying ADX ({result['database']})..."):
                    df = execute_adx_query(result['database'], result['query'])
            elif result['source'] == 'SNOWFLAKE':
                with st.spinner("🔄 Querying Snowflake..."):
                    df = execute_snowflake_query(result['query'])
            else:
                df = pd.DataFrame()
            
            if not df.empty:
                response_parts.append(f"\n**📊 Results ({len(df)} rows):**")
                # Store data for display
                st.session_state['last_result'] = df
            else:
                response_parts.append("\n⚠️ No data returned or authentication required.")
        
        # Add assistant message
        st.session_state['messages'].append({
            'role': 'assistant',
            'content': '\n'.join(response_parts)
        })
        
        # Rerun to update display
        st.rerun()
    
    # Display last result if exists
    if 'last_result' in st.session_state and not st.session_state['last_result'].empty:
        st.markdown("### 📊 Latest Results")
        st.dataframe(
            st.session_state['last_result'],
            use_container_width=True,
            hide_index=True
        )
    
    # Footer
    st.markdown("---")
    st.markdown("""
    <div style='text-align: center; color: #718096; font-size: 12px;'>
        📚 Using ADX_UNIFIED Semantic Model v4.0 | 
        🔗 Cluster: fctsnaproddatexp02.westus2.kusto.windows.net |
        ⏰ {timestamp}
    </div>
    """.format(timestamp=datetime.now().strftime("%Y-%m-%d %H:%M")), unsafe_allow_html=True)

if __name__ == "__main__":
    main()
