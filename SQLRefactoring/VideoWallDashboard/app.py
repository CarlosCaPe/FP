"""
IROC Video Wall - Production Performance Dashboard
Main Streamlit Application

Based on: IROC Video Wall Production Performance Section Requirements Definition
Purpose: LH&IOS Production Performance Section of the Morenci video wall dashboard for CC6 IROC
"""
import streamlit as st
from datetime import datetime
from typing import Dict, List, Optional
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from ui.components import (
    apply_dashboard_style,
    render_section_header,
    render_metric_card,
    render_cycle_time_card,
    render_priority_shovels_table,
    render_throughput_group,
    render_material_delivered,
    render_ios_strategy,
    MetricDisplayData,
)
from data.connectors import data_service
from models.metrics import business_rules, ALL_METRICS, MetricStatus, TrendDirection


# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="IROC Video Wall - Production Performance",
    page_icon="⛏️",
    layout="wide",
    initial_sidebar_state="collapsed",
)

apply_dashboard_style()


# =============================================================================
# DATA SERVICE INITIALIZATION
# =============================================================================
@st.cache_resource
def init_data_service():
    """Initialize data service (cached)."""
    data_service.initialize()
    return data_service


# =============================================================================
# MOCK DATA GENERATION (For Demo)
# =============================================================================
def get_mock_loading_data() -> Dict:
    """Generate mock data for Loading section."""
    import random
    return {
        "dig_compliance": MetricDisplayData(
            label="Dig Compliance (%)",
            actual=random.uniform(83, 92),
            target=100,
            projected=random.uniform(85, 95),
            trend_value=random.uniform(-5, 5),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green" if random.random() > 0.3 else "orange",
            unit="%",
        ),
        "dig_rate": MetricDisplayData(
            label="Dig Rate (TPRH)",
            actual=random.uniform(27000, 35000),
            target=35000,
            projected=random.uniform(30000, 36000),
            trend_value=random.uniform(-3, 5),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green" if random.random() > 0.3 else "orange",
            unit="TPH",
        ),
        "priority_shovels": [
            {"id": "S12", "material": "Mill", "compliance": 64 + random.randint(0, 20), "rate": 4100 + random.randint(-200, 200), "trend": "↓"},
            {"id": "S12", "material": "MFL", "compliance": 72 + random.randint(0, 15), "rate": 4100 + random.randint(-200, 200), "trend": "↑"},
            {"id": "S12", "material": "MFL", "compliance": 79 + random.randint(0, 10), "rate": 4100 + random.randint(-200, 200), "trend": "↑"},
            {"id": "S12", "material": "ROM", "compliance": 82 + random.randint(0, 10), "rate": 4100 + random.randint(-200, 200), "trend": "↑"},
            {"id": "S12", "material": "ROM", "compliance": 87 + random.randint(0, 5), "rate": 4100 + random.randint(-200, 200), "trend": "↓"},
        ],
    }


def get_mock_haulage_data() -> Dict:
    """Generate mock data for Haulage section."""
    import random
    return {
        "cycle_time": MetricDisplayData(
            label="Cycle Time (min)",
            actual=random.uniform(40, 55),
            target=45,
            projected=random.uniform(42, 50),
            trend_value=random.uniform(-5, 5),
            trend_direction="↑" if random.random() > 0.5 else "↓",
            actual_status="green" if random.random() > 0.4 else "orange",
            projected_status="green",
            trend_status="green" if random.random() > 0.4 else "orange",
            unit="min",
        ),
        "truck_count": MetricDisplayData(
            label="# of Trucks (Qty)",
            actual=random.randint(68, 85),
            target=76,
            projected=random.randint(70, 80),
            trend_value=random.uniform(-3, 3),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green",
            projected_status="green",
            trend_status="green",
            unit="",
        ),
        "dump_compliance": MetricDisplayData(
            label="Dump Plan Compliance (%)",
            actual=random.uniform(83, 95),
            target=100,
            projected=random.uniform(85, 96),
            trend_value=random.uniform(-2, 3),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green",
            unit="%",
        ),
        "asset_efficiency": MetricDisplayData(
            label="Asset Efficiency (%)",
            actual=random.uniform(78, 92),
            target=100,
            projected=random.uniform(80, 95),
            trend_value=random.uniform(-3, 4),
            trend_direction="↑" if random.random() > 0.4 else "↓",
            actual_status="green" if random.random() > 0.3 else "orange",
            projected_status="green",
            trend_status="green",
            unit="%",
        ),
    }


def get_mock_lbs_on_ground_data() -> Dict:
    """Generate mock data for Lbs on Ground section."""
    import random
    return {
        "throughput": [
            MetricDisplayData(
                label="Mill Crusher (TPOH)",
                actual=random.uniform(4000, 4500),
                target=4350,
                projected=random.uniform(4100, 4400),
                trend_value=random.uniform(-3, 5),
                trend_direction="↑",
                actual_status="orange",
                projected_status="green",
                trend_status="green",
                unit="TPH",
            ),
            MetricDisplayData(
                label="Mill Feed (TPOH)",
                actual=random.uniform(4100, 4400),
                target=4350,
                projected=random.uniform(4150, 4450),
                trend_value=random.uniform(-2, 4),
                trend_direction="↑",
                actual_status="green",
                projected_status="green",
                trend_status="green",
                unit="TPH",
            ),
            MetricDisplayData(
                label="MFL Crusher (TPOH)",
                actual=random.uniform(4000, 4400),
                target=4350,
                projected=random.uniform(4050, 4350),
                trend_value=random.uniform(-4, 3),
                trend_direction="↑",
                actual_status="green",
                projected_status="green",
                trend_status="orange",
                unit="TPH",
            ),
            MetricDisplayData(
                label="FCP (TPOH)",
                actual=random.uniform(4100, 4400),
                target=4350,
                projected=random.uniform(4100, 4400),
                trend_value=random.uniform(-2, 4),
                trend_direction="↑",
                actual_status="green",
                projected_status="green",
                trend_status="green",
                unit="TPH",
            ),
        ],
        "material_delivered": {
            "mill": {"actual": 37100, "target": 40000, "projected": 43000, "trend": 6.12},
            "mfl": {"actual": 37100, "target": 40000, "projected": 43000, "trend": 6.12},
            "rom": {"actual": 33100, "target": 35000, "projected": 36000, "trend": 6.12},
        },
        "ios_stockpiles": [
            {"rate": 300, "capacity_hours": 12, "direction": "up", "level_pct": 75},
            {"rate": 300, "capacity_hours": 12, "direction": "up", "level_pct": 70},
            {"rate": 300, "capacity_hours": 12, "direction": "up", "level_pct": 65},
            {"rate": 50, "capacity_hours": 6, "direction": "up", "level_pct": 55},
            {"rate": 50, "capacity_hours": 6, "direction": "down", "level_pct": 45},
            {"rate": 50, "capacity_hours": 6, "direction": "up", "level_pct": 60},
        ],
    }


# =============================================================================
# MAIN DASHBOARD LAYOUT
# =============================================================================
def render_header():
    """Render dashboard header."""
    col1, col2, col3 = st.columns([2, 4, 2])
    
    with col1:
        st.markdown(f"""
        <div style="color: #6b7280; font-size: 12px;">
            Site: <span style="color: white; font-weight: bold;">Morenci</span>
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        st.markdown("""
        <div style="text-align: center;">
            <span style="color: #f97316; font-size: 16px; font-weight: bold;">PRODUCTION PERFORMANCE</span>
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        now = datetime.now()
        st.markdown(f"""
        <div style="text-align: right; color: #6b7280; font-size: 12px;">
            {now.strftime('%Y-%m-%d %H:%M:%S')}
        </div>
        """, unsafe_allow_html=True)


def render_loading_section(data: Dict):
    """Render the Loading section."""
    render_section_header("Loading", "green")
    
    col1, col2 = st.columns(2)
    
    with col1:
        render_metric_card(data["dig_compliance"])
        render_metric_card(data["dig_rate"])
    
    with col2:
        render_priority_shovels_table(data["priority_shovels"])


def render_haulage_section(data: Dict):
    """Render the Haulage section."""
    render_section_header("Haulage", "orange", has_downstream_constraint=True)
    
    col1, col2 = st.columns(2)
    
    with col1:
        render_cycle_time_card(data["cycle_time"])
        render_metric_card(data["truck_count"])
    
    with col2:
        render_metric_card(data["dump_compliance"])
        render_metric_card(data["asset_efficiency"])


def render_lbs_on_ground_section(data: Dict):
    """Render the Lbs on Ground section."""
    render_section_header("Lbs on Ground", "green")
    
    # Throughput metrics (2x2 grid)
    st.markdown("<div style='color: #6b7280; font-size: 11px; margin-bottom: 8px;'>Throughput (TPH)</div>", unsafe_allow_html=True)
    render_throughput_group(data["throughput"])
    
    st.markdown("<hr style='border-color: #333; margin: 16px 0;'>", unsafe_allow_html=True)
    
    # Material Delivered
    cols = st.columns(3)
    with cols[0]:
        m = data["material_delivered"]["mill"]
        render_material_delivered("Mill Material Delivered (tons)", m["actual"], m["target"], m["projected"], m["trend"], "green")
    with cols[1]:
        m = data["material_delivered"]["mfl"]
        render_material_delivered("MFL Material Delivered (tons)", m["actual"], m["target"], m["projected"], m["trend"], "green")
    with cols[2]:
        m = data["material_delivered"]["rom"]
        render_material_delivered("ROM Material Delivered (tons)", m["actual"], m["target"], m["projected"], m["trend"], "green")
    
    st.markdown("<hr style='border-color: #333; margin: 16px 0;'>", unsafe_allow_html=True)
    
    # IOS Strategy
    st.markdown("<div style='color: #6b7280; font-size: 11px; margin-bottom: 8px;'>IOS Level Strategy (TPH)</div>", unsafe_allow_html=True)
    render_ios_strategy(data["ios_stockpiles"])


def main():
    """Main application entry point."""
    # Initialize data service
    init_data_service()
    
    # Render header
    render_header()
    
    st.markdown("<hr style='border-color: #333; margin: 8px 0;'>", unsafe_allow_html=True)
    
    # Get data (using mock for demo)
    loading_data = get_mock_loading_data()
    haulage_data = get_mock_haulage_data()
    lbs_data = get_mock_lbs_on_ground_data()
    
    # Main layout - 4 columns matching the requirements
    col_loading, col_haulage, col_lbs, col_processing = st.columns([1.2, 1.2, 1.8, 0.8])
    
    with col_loading:
        render_loading_section(loading_data)
    
    with col_haulage:
        render_haulage_section(haulage_data)
    
    with col_lbs:
        render_lbs_on_ground_section(lbs_data)
    
    with col_processing:
        render_section_header("Processing", "green")
        st.markdown("""
        <div style="
            background: #1a1a2e;
            border-radius: 8px;
            padding: 16px;
            text-align: center;
            color: #6b7280;
        ">
            <div style="font-size: 14px;">Processing Section</div>
            <div style="font-size: 11px; margin-top: 8px;">Coming Soon</div>
        </div>
        """, unsafe_allow_html=True)
    
    # Auto-refresh
    st.markdown("""
    <script>
        setTimeout(function(){
            window.location.reload();
        }, 30000);  // Refresh every 30 seconds
    </script>
    """, unsafe_allow_html=True)


if __name__ == "__main__":
    main()
