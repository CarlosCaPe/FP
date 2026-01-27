"""
🎯 IROC Video Wall - Production Performance Dashboard
======================================================
EXACT implementation of Freeport mockups.

Layout: LOADING | HAULAGE | LBS ON GROUND | PROCESSING (horizontal)

Run with: streamlit run app_v2.py
"""

import streamlit as st
from datetime import datetime
from typing import Dict, List
import random

# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="IROC Video Wall - Production Performance",
    page_icon="⛏️",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# =============================================================================
# EXACT STYLING FROM MOCKUPS
# =============================================================================
st.markdown("""
<style>
    /* Dark background */
    .stApp {
        background-color: #0d1117;
    }
    
    /* Remove all padding */
    .block-container {
        padding: 0.5rem 1rem 0rem 1rem;
        max-width: 100%;
    }
    
    /* Hide streamlit elements */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    
    /* Section headers - colored bars */
    .section-loading {
        background: linear-gradient(90deg, #22c55e 0%, #16a34a 100%);
        color: white;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        border-radius: 2px;
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .section-haulage {
        background: linear-gradient(90deg, #f97316 0%, #ea580c 100%);
        color: white;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        border-radius: 2px;
        margin-bottom: 8px;
    }
    .section-lbs {
        background: linear-gradient(90deg, #22c55e 0%, #16a34a 100%);
        color: white;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        border-radius: 2px;
        margin-bottom: 8px;
    }
    .section-processing {
        background: linear-gradient(90deg, #22c55e 0%, #16a34a 100%);
        color: white;
        padding: 6px 12px;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        border-radius: 2px;
        margin-bottom: 8px;
    }
    
    /* Metric card */
    .metric-box {
        background: #1a1f2e;
        border-radius: 4px;
        padding: 10px 12px;
        margin-bottom: 6px;
    }
    
    /* Metric label */
    .metric-label {
        color: #9ca3af;
        font-size: 11px;
        margin-bottom: 4px;
    }
    
    /* Actual value */
    .metric-actual {
        font-size: 24px;
        font-weight: bold;
        line-height: 1.2;
    }
    .metric-actual.green { color: #22c55e; }
    .metric-actual.orange { color: #f97316; }
    .metric-actual.red { color: #ef4444; }
    
    /* Target value */
    .metric-target {
        color: white;
        font-size: 12px;
        float: right;
    }
    
    /* Progress bar */
    .progress-bar {
        background: #374151;
        height: 6px;
        border-radius: 3px;
        margin: 6px 0;
        position: relative;
    }
    .progress-fill {
        height: 100%;
        border-radius: 3px;
    }
    .progress-fill.green { background: #22c55e; }
    .progress-fill.orange { background: #f97316; }
    .progress-fill.red { background: #ef4444; }
    
    /* Projected row */
    .projected-row {
        display: flex;
        justify-content: space-between;
        font-size: 11px;
        color: #9ca3af;
    }
    .projected-value { color: #9ca3af; }
    .trend-up { color: #22c55e; }
    .trend-down { color: #ef4444; }
    
    /* Priority shovels table */
    .shovel-table {
        width: 100%;
        font-size: 11px;
        border-collapse: collapse;
    }
    .shovel-table th {
        color: #6b7280;
        text-align: left;
        padding: 4px 6px;
        font-weight: normal;
    }
    .shovel-table td {
        color: white;
        padding: 3px 6px;
    }
    
    /* Cycle time special visualization */
    .cycle-bar-container {
        position: relative;
        background: #374151;
        height: 20px;
        border-radius: 2px;
        margin: 8px 0;
    }
    .cycle-target-marker {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 2px;
        background: white;
    }
    .cycle-actual-fill {
        height: 100%;
        position: absolute;
        top: 0;
    }
    
    /* IOS triangles */
    .ios-triangle {
        text-align: center;
        padding: 8px;
    }
    .ios-arrow {
        font-size: 24px;
    }
    .ios-arrow.up { color: #22c55e; }
    .ios-arrow.down { color: #f97316; }
    .ios-value {
        color: white;
        font-size: 13px;
        font-weight: bold;
    }
    .ios-capacity {
        color: #6b7280;
        font-size: 10px;
    }
    
    /* Throughput grid */
    .throughput-item {
        background: #1a1f2e;
        padding: 8px 10px;
        border-radius: 4px;
    }
    .throughput-label {
        color: #9ca3af;
        font-size: 10px;
    }
    .throughput-value {
        color: #22c55e;
        font-size: 16px;
        font-weight: bold;
    }
    .throughput-plan {
        color: #6b7280;
        font-size: 10px;
    }
    .throughput-trend {
        font-size: 10px;
    }
    
    /* Material delivered bars */
    .material-box {
        background: #1a1f2e;
        border-radius: 4px;
        padding: 8px 10px;
        margin-bottom: 6px;
    }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# COLOR HELPERS
# =============================================================================
def get_status(actual: float, target: float) -> str:
    """Get status color based on actual vs target ratio."""
    if target == 0:
        return "green"
    ratio = (actual / target) * 100
    if ratio >= 90:
        return "green"
    elif ratio >= 80:
        return "orange"
    return "red"

def get_trend_class(trend: float) -> str:
    """Get trend CSS class."""
    return "trend-up" if trend >= 0 else "trend-down"

def get_trend_arrow(trend: float) -> str:
    """Get trend arrow."""
    return "▲" if trend >= 0 else "▼"

# =============================================================================
# MOCK DATA (Rolling 60 min)
# =============================================================================
def get_production_data() -> Dict:
    """Get production performance data (mock)."""
    random.seed(datetime.now().hour)  # Consistent within hour
    
    return {
        # LOADING
        "dig_compliance": {
            "actual": 83 + random.randint(0, 12),
            "target": 100,
            "projected": 89 + random.randint(0, 8),
            "trend": round(random.uniform(-0.5, 0.5), 2),
        },
        "dig_rate": {
            "actual": 27100 + random.randint(0, 5000),
            "target": 35000,
            "projected": 34530 + random.randint(-2000, 2000),
            "trend": round(random.uniform(-0.2, 0.3), 2),
        },
        "priority_shovels": [
            {"id": "S12", "material": "Mill", "compliance": 64, "rate": 4100, "trend": "down"},
            {"id": "S12", "material": "MFL", "compliance": 72, "rate": 4100, "trend": "up"},
            {"id": "S12", "material": "MFL", "compliance": 79, "rate": 4100, "trend": "up"},
            {"id": "S12", "material": "ROM", "compliance": 82, "rate": 4100, "trend": "up"},
            {"id": "S12", "material": "ROM", "compliance": 87, "rate": 4100, "trend": "up"},
        ],
        
        # HAULAGE
        "cycle_time": {
            "actual": 48.2 + random.uniform(-3, 5),
            "target": 45,
            "min": 35,
            "max": 55,
            "projected": 49.3 + random.uniform(-2, 3),
            "trend": round(random.uniform(-0.2, 0.3), 2),
        },
        "dump_compliance": {
            "actual": 83 + random.randint(0, 12),
            "target": 100,
            "projected": 89 + random.randint(0, 8),
            "trend": round(random.uniform(-0.2, 0.3), 2),
        },
        "truck_count": {
            "actual": 68 + random.randint(0, 15),
            "target": 76,
            "available": 110,
            "projected": 72 + random.randint(-3, 5),
            "trend": round(random.uniform(-0.2, 0.3), 2),
        },
        "asset_efficiency": {
            "actual": 83 + random.randint(0, 12),
            "target": 100,
            "projected": 89 + random.randint(0, 8),
            "trend": round(random.uniform(-0.2, 0.3), 2),
        },
        
        # LBS ON GROUND - Throughput
        "mill_crusher": {"actual": 4200 + random.randint(-200, 300), "plan": 4350, "trend": 3.45},
        "mill_feed": {"actual": 4230 + random.randint(-200, 300), "plan": 4350, "trend": 4.45},
        "mfl_crusher": {"actual": 4200 + random.randint(-200, 300), "plan": 4350, "trend": 3.45},
        "fcp": {"actual": 4230 + random.randint(-200, 300), "plan": 4350, "trend": 4.45},
        
        # LBS ON GROUND - Material Delivered
        "mill_delivered": {
            "actual": 37100 + random.randint(-2000, 3000),
            "target": 40000,
            "projected": 43000,
            "trend": 6.12,
        },
        "mfl_delivered": {
            "actual": 37100 + random.randint(-2000, 3000),
            "target": 40000,
            "projected": 43000,
            "trend": 6.12,
        },
        "rom_delivered": {
            "actual": 33100 + random.randint(-2000, 3000),
            "target": 35000,
            "projected": 36000,
            "trend": 6.12,
        },
        
        # IOS Strategy
        "ios_stockpiles": [
            {"rate": 300, "capacity": 12, "direction": "up"},
            {"rate": 300, "capacity": 12, "direction": "up"},
            {"rate": 300, "capacity": 12, "direction": "up"},
            {"rate": 50, "capacity": 6, "direction": "up"},
            {"rate": 50, "capacity": 6, "direction": "down"},
            {"rate": 50, "capacity": 6, "direction": "up"},
            {"rate": 115, "capacity": 8, "direction": "up"},
            {"rate": 115, "capacity": 8, "direction": "up"},
            {"rate": 115, "capacity": 8, "direction": "up"},
            {"rate": 115, "capacity": 4, "direction": "up"},
            {"rate": 115, "capacity": 4, "direction": "up"},
            {"rate": 115, "capacity": 4, "direction": "up"},
        ],
    }

# =============================================================================
# COMPONENT: Standard Metric Card
# =============================================================================
def render_standard_metric(label: str, actual: float, target: float, projected: float, 
                           trend: float, unit: str = "%", decimals: int = 0):
    """Render standard metric card per mockup specs."""
    status = get_status(actual, target)
    bar_width = min((actual / target * 100) if target > 0 else 0, 100)
    trend_class = get_trend_class(trend)
    trend_arrow = get_trend_arrow(trend)
    trend_sign = "+" if trend >= 0 else ""
    
    actual_fmt = f"{actual:,.{decimals}f}"
    target_fmt = f"{target:,.0f}{unit}"
    projected_fmt = f"{projected:,.{decimals}f}"
    
    st.markdown(f"""
    <div class="metric-box">
        <div style="display: flex; justify-content: space-between;">
            <span class="metric-label">{label}</span>
            <span class="metric-target">{target_fmt}</span>
        </div>
        <div class="metric-actual {status}">{actual_fmt}</div>
        <div class="progress-bar">
            <div class="progress-fill {status}" style="width: {bar_width}%;"></div>
        </div>
        <div class="projected-row">
            <span>PROJECTED {projected_fmt}</span>
            <span class="{trend_class}">{trend_arrow}{trend_sign}{trend:.2f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)

# =============================================================================
# COMPONENT: Cycle Time (centered target)
# =============================================================================
def render_cycle_time(data: Dict):
    """Render cycle time with centered target visualization."""
    actual = data["actual"]
    target = data["target"]
    min_val = data["min"]
    max_val = data["max"]
    projected = data["projected"]
    trend = data["trend"]
    
    # Calculate position (target is center = 50%)
    range_size = max_val - min_val
    target_pos = ((target - min_val) / range_size) * 100
    actual_pos = ((actual - min_val) / range_size) * 100
    
    # Determine color based on deviation from target
    deviation = abs(actual - target) / target * 100
    if deviation <= 5:
        status = "green"
    elif deviation <= 15:
        status = "orange"
    else:
        status = "red"
    
    trend_class = get_trend_class(trend)
    trend_arrow = get_trend_arrow(trend)
    trend_sign = "+" if trend >= 0 else ""
    
    st.markdown(f"""
    <div class="metric-box">
        <div class="metric-label" style="text-align: center;">Cycle Time (min)</div>
        
        <div style="display: flex; justify-content: space-between; margin: 6px 0; font-size: 12px;">
            <span style="color: #6b7280;">{min_val}</span>
            <span style="color: white; font-weight: bold;">{target}</span>
            <span class="metric-actual {status}" style="font-size: 18px;">{actual:.1f}</span>
        </div>
        
        <div class="cycle-bar-container">
            <div class="cycle-target-marker" style="left: {target_pos}%;"></div>
            <div class="cycle-actual-fill" 
                 style="left: {min(target_pos, actual_pos)}%; 
                        width: {abs(actual_pos - target_pos)}%; 
                        background: {'#22c55e' if status == 'green' else '#f97316' if status == 'orange' else '#ef4444'};"></div>
        </div>
        
        <div class="projected-row" style="justify-content: center; gap: 20px;">
            <span>PROJECTED {projected:.1f}</span>
            <span class="{trend_class}">{trend_arrow}{trend_sign}{trend:.2f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)

# =============================================================================
# COMPONENT: Truck Count (with available)
# =============================================================================
def render_truck_count(data: Dict):
    """Render truck count with available trucks indicator."""
    actual = data["actual"]
    target = data["target"]
    available = data["available"]
    projected = data["projected"]
    trend = data["trend"]
    
    status = get_status(actual, target)
    bar_width = (actual / available * 100) if available > 0 else 0
    target_pos = (target / available * 100) if available > 0 else 0
    
    trend_class = get_trend_class(trend)
    trend_arrow = get_trend_arrow(trend)
    trend_sign = "+" if trend >= 0 else ""
    
    st.markdown(f"""
    <div class="metric-box">
        <div style="display: flex; justify-content: space-between;">
            <span class="metric-label"># of Trucks (Qty)</span>
            <span class="metric-target">{available}</span>
        </div>
        
        <div style="display: flex; align-items: baseline; gap: 8px;">
            <span class="metric-actual {status}">{actual}</span>
            <span style="color: #6b7280; font-size: 12px;">{target}</span>
        </div>
        
        <div class="progress-bar" style="position: relative;">
            <div class="progress-fill {status}" style="width: {bar_width}%;"></div>
            <div style="position: absolute; left: {target_pos}%; top: -2px; bottom: -2px; width: 2px; background: white;"></div>
        </div>
        
        <div class="projected-row">
            <span>PROJECTED {projected}</span>
            <span class="{trend_class}">{trend_arrow}{trend_sign}{trend:.2f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)

# =============================================================================
# COMPONENT: Priority Shovels Table
# =============================================================================
def render_priority_shovels(shovels: List[Dict]):
    """Render priority shovels table per mockup."""
    st.markdown("""
    <div class="metric-box">
        <div class="metric-label">Priority Shovels</div>
        <table class="shovel-table">
            <thead>
                <tr><th>ID</th><th>Material</th><th>Compliance</th><th>Rate</th></tr>
            </thead>
            <tbody>
    """, unsafe_allow_html=True)
    
    for s in shovels[:5]:
        comp = s["compliance"]
        comp_color = "#22c55e" if comp >= 80 else "#f97316" if comp >= 70 else "#ef4444"
        trend_arrow = "▼" if s["trend"] == "down" else "▲"
        trend_color = "#ef4444" if s["trend"] == "down" else "#22c55e"
        
        st.markdown(f"""
            <tr>
                <td>{s['id']}</td>
                <td>{s['material']}</td>
                <td><span style="color: {comp_color};">{comp}%</span><span style="color: {trend_color};">{trend_arrow}</span></td>
                <td>{s['rate']:,}<span style="color: {trend_color};">{trend_arrow}</span></td>
            </tr>
        """, unsafe_allow_html=True)
    
    st.markdown("</tbody></table></div>", unsafe_allow_html=True)

# =============================================================================
# COMPONENT: Throughput Item
# =============================================================================
def render_throughput(label: str, actual: float, plan: float, trend: float):
    """Render throughput metric item."""
    trend_class = "trend-up" if trend >= 0 else "trend-down"
    trend_arrow = "▲" if trend >= 0 else "▼"
    
    st.markdown(f"""
    <div class="throughput-item">
        <div class="throughput-label">{label}</div>
        <div class="throughput-value">{actual:,.0f}</div>
        <div class="throughput-plan">PLAN {plan:,.0f}</div>
        <div class="throughput-trend {trend_class}">{trend_arrow}{trend:.2f}%</div>
    </div>
    """, unsafe_allow_html=True)

# =============================================================================
# COMPONENT: Material Delivered
# =============================================================================
def render_material_delivered(label: str, actual: float, target: float, projected: float, trend: float):
    """Render material delivered metric."""
    status = get_status(actual, target)
    bar_width = min((actual / target * 100) if target > 0 else 0, 100)
    trend_arrow = "▲" if trend >= 0 else "▼"
    trend_class = "trend-up" if trend >= 0 else "trend-down"
    
    st.markdown(f"""
    <div class="material-box">
        <div style="display: flex; justify-content: space-between; font-size: 10px;">
            <span style="color: #9ca3af;">{label}</span>
            <span style="color: white;">{target:,.0f}</span>
        </div>
        <div class="metric-actual {status}" style="font-size: 18px;">{actual:,.0f}</div>
        <div class="progress-bar">
            <div class="progress-fill {status}" style="width: {bar_width}%;"></div>
        </div>
        <div class="projected-row">
            <span>PROJECTED {projected:,.0f}</span>
            <span class="{trend_class}">{trend_arrow}{trend:.2f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)

# =============================================================================
# COMPONENT: IOS Strategy Triangles
# =============================================================================
def render_ios_strategy(stockpiles: List[Dict]):
    """Render IOS strategy with triangular indicators."""
    cols = st.columns(3)
    
    for i, pile in enumerate(stockpiles[:12]):
        with cols[i % 3]:
            arrow = "▲" if pile["direction"] == "up" else "▼"
            arrow_class = "up" if pile["direction"] == "up" else "down"
            
            st.markdown(f"""
            <div class="ios-triangle">
                <div class="ios-arrow {arrow_class}">{arrow}</div>
                <div class="ios-value">{pile['rate']} TPH</div>
                <div class="ios-capacity">Capacity: {pile['capacity']}hrs</div>
            </div>
            """, unsafe_allow_html=True)

# =============================================================================
# MAIN DASHBOARD
# =============================================================================
def main():
    # Get data
    data = get_production_data()
    
    # Header
    col1, col2, col3 = st.columns([2, 6, 2])
    with col1:
        st.markdown("""
        <div style="color: #6b7280; font-size: 12px;">
            Site: <span style="color: white; font-weight: bold;">Morenci</span>
        </div>
        """, unsafe_allow_html=True)
    with col2:
        st.markdown("""
        <div style="text-align: center; color: #f97316; font-weight: bold; font-size: 14px;">
            PRODUCTION PERFORMANCE
        </div>
        """, unsafe_allow_html=True)
    with col3:
        st.markdown(f"""
        <div style="text-align: right; color: #6b7280; font-size: 11px;">
            {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        </div>
        """, unsafe_allow_html=True)
    
    st.markdown("<hr style='border-color: #333; margin: 6px 0;'>", unsafe_allow_html=True)
    
    # ==========================================================================
    # MAIN LAYOUT: 4 COLUMNS (LOADING | HAULAGE | LBS ON GROUND | PROCESSING)
    # ==========================================================================
    col_loading, col_haulage, col_lbs, col_processing = st.columns([1.2, 1.2, 2.0, 0.6])
    
    # --------------------------------------------------------------------------
    # LOADING SECTION
    # --------------------------------------------------------------------------
    with col_loading:
        st.markdown('<div class="section-loading">⚙️ LOADING</div>', unsafe_allow_html=True)
        
        render_standard_metric(
            "Dig Compliance (%)",
            data["dig_compliance"]["actual"],
            data["dig_compliance"]["target"],
            data["dig_compliance"]["projected"],
            data["dig_compliance"]["trend"],
        )
        
        render_standard_metric(
            "Dig Rate (TPRH)",
            data["dig_rate"]["actual"],
            data["dig_rate"]["target"],
            data["dig_rate"]["projected"],
            data["dig_rate"]["trend"],
            unit="",
        )
        
        render_priority_shovels(data["priority_shovels"])
    
    # --------------------------------------------------------------------------
    # HAULAGE SECTION
    # --------------------------------------------------------------------------
    with col_haulage:
        st.markdown('<div class="section-haulage">🚚 HAULAGE</div>', unsafe_allow_html=True)
        
        render_cycle_time(data["cycle_time"])
        
        render_standard_metric(
            "Dump Plan Compliance (%)",
            data["dump_compliance"]["actual"],
            data["dump_compliance"]["target"],
            data["dump_compliance"]["projected"],
            data["dump_compliance"]["trend"],
        )
        
        render_truck_count(data["truck_count"])
        
        render_standard_metric(
            "Asset Efficiency (%)",
            data["asset_efficiency"]["actual"],
            data["asset_efficiency"]["target"],
            data["asset_efficiency"]["projected"],
            data["asset_efficiency"]["trend"],
        )
    
    # --------------------------------------------------------------------------
    # LBS ON GROUND SECTION
    # --------------------------------------------------------------------------
    with col_lbs:
        st.markdown('<div class="section-lbs">📊 LBS ON GROUND</div>', unsafe_allow_html=True)
        
        # Throughput (2x2 grid)
        st.markdown("<div style='color: #6b7280; font-size: 10px; margin-bottom: 4px;'>Throughput (TPH)</div>", unsafe_allow_html=True)
        
        t_col1, t_col2 = st.columns(2)
        with t_col1:
            render_throughput("Mill Crusher (TPOH)", data["mill_crusher"]["actual"], data["mill_crusher"]["plan"], data["mill_crusher"]["trend"])
            render_throughput("MFL Crusher (TPOH)", data["mfl_crusher"]["actual"], data["mfl_crusher"]["plan"], data["mfl_crusher"]["trend"])
        with t_col2:
            render_throughput("Mill Feed (TPOH)", data["mill_feed"]["actual"], data["mill_feed"]["plan"], data["mill_feed"]["trend"])
            render_throughput("FCP (TPOH)", data["fcp"]["actual"], data["fcp"]["plan"], data["fcp"]["trend"])
        
        st.markdown("<hr style='border-color: #333; margin: 8px 0;'>", unsafe_allow_html=True)
        
        # Material Delivered (3 columns)
        m_col1, m_col2, m_col3 = st.columns(3)
        with m_col1:
            render_material_delivered("Mill Material Delivered (tons)", data["mill_delivered"]["actual"], data["mill_delivered"]["target"], data["mill_delivered"]["projected"], data["mill_delivered"]["trend"])
        with m_col2:
            render_material_delivered("MFL Material Delivered (tons)", data["mfl_delivered"]["actual"], data["mfl_delivered"]["target"], data["mfl_delivered"]["projected"], data["mfl_delivered"]["trend"])
        with m_col3:
            render_material_delivered("ROM Material Delivered (tons)", data["rom_delivered"]["actual"], data["rom_delivered"]["target"], data["rom_delivered"]["projected"], data["rom_delivered"]["trend"])
        
        st.markdown("<hr style='border-color: #333; margin: 8px 0;'>", unsafe_allow_html=True)
        
        # IOS Level Strategy
        st.markdown("<div style='color: #6b7280; font-size: 10px; margin-bottom: 4px;'>IOS Level Strategy (TPH)</div>", unsafe_allow_html=True)
        render_ios_strategy(data["ios_stockpiles"])
    
    # --------------------------------------------------------------------------
    # PROCESSING SECTION
    # --------------------------------------------------------------------------
    with col_processing:
        st.markdown('<div class="section-processing">🏭 PROCESSING</div>', unsafe_allow_html=True)
        
        st.markdown("""
        <div class="metric-box" style="text-align: center; min-height: 200px; display: flex; align-items: center; justify-content: center;">
            <div>
                <div style="color: #6b7280; font-size: 12px;">Coming Soon</div>
                <div style="color: #374151; font-size: 10px; margin-top: 4px;">Processing metrics</div>
            </div>
        </div>
        """, unsafe_allow_html=True)


if __name__ == "__main__":
    main()
