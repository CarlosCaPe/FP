"""
UI Components for the Video Wall Dashboard.
Implements the visual specifications from requirements document.
"""
import streamlit as st
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum


class StatusColor(Enum):
    """Color palette for metric status."""
    GREEN = "#22c55e"
    ORANGE = "#f97316"
    RED = "#ef4444"
    BLUE = "#3b82f6"
    GRAY = "#6b7280"
    WHITE = "#ffffff"
    DARK_BG = "#1a1a2e"


@dataclass
class MetricDisplayData:
    """Data for rendering a metric card."""
    label: str
    actual: float
    target: float
    projected: float
    trend_value: float
    trend_direction: str  # ↑, ↓, →
    actual_status: str    # green, orange, red
    projected_status: str
    trend_status: str
    unit: str = ""
    show_target: bool = True


def get_status_color(status: str) -> str:
    """Get hex color for status."""
    colors = {
        "green": StatusColor.GREEN.value,
        "orange": StatusColor.ORANGE.value,
        "red": StatusColor.RED.value,
        "unknown": StatusColor.GRAY.value,
    }
    return colors.get(status.lower(), StatusColor.GRAY.value)


def render_section_header(name: str, status: str, has_upstream_constraint: bool = False, has_downstream_constraint: bool = False):
    """Render section header with color bar and constraint indicators."""
    color = get_status_color(status)
    
    # Build constraint arrows
    left_arrow = "◀" if has_upstream_constraint else ""
    right_arrow = "▶" if has_downstream_constraint else ""
    
    st.markdown(f"""
    <div style="
        background: linear-gradient(90deg, {color} 0%, {color} 100%);
        padding: 8px 16px;
        border-radius: 4px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
    ">
        <span style="color: {StatusColor.RED.value if has_upstream_constraint else 'transparent'}; font-size: 20px;">
            {left_arrow}
        </span>
        <span style="color: white; font-weight: bold; font-size: 14px; text-transform: uppercase;">
            {name}
        </span>
        <span style="color: {StatusColor.RED.value if has_downstream_constraint else 'transparent'}; font-size: 20px;">
            {right_arrow}
        </span>
    </div>
    """, unsafe_allow_html=True)


def render_metric_card(data: MetricDisplayData):
    """Render a standard metric card per requirements."""
    actual_color = get_status_color(data.actual_status)
    projected_color = get_status_color(data.projected_status)
    trend_color = get_status_color(data.trend_status)
    
    # Calculate bar width (ratio of actual to target)
    bar_width = min((data.actual / data.target * 100) if data.target > 0 else 0, 100)
    
    # Format trend with sign
    trend_sign = "+" if data.trend_value >= 0 else ""
    trend_text = f"{trend_sign}{data.trend_value:.2f}%"
    
    st.markdown(f"""
    <div style="
        background: {StatusColor.DARK_BG.value};
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 12px;
    ">
        <!-- Label and Target -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 12px;">{data.label}</span>
            <span style="color: {StatusColor.WHITE.value}; font-size: 12px;">{data.target:,.0f}</span>
        </div>
        
        <!-- Actual Value -->
        <div style="color: {actual_color}; font-size: 28px; font-weight: bold; margin-bottom: 4px;">
            {data.actual:,.0f}
        </div>
        
        <!-- Progress Bar -->
        <div style="
            background: {StatusColor.GRAY.value}40;
            border-radius: 4px;
            height: 8px;
            margin-bottom: 8px;
            position: relative;
        ">
            <div style="
                background: {actual_color};
                width: {bar_width}%;
                height: 100%;
                border-radius: 4px;
            "></div>
        </div>
        
        <!-- Projected and Trend -->
        <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="color: {projected_color}; font-size: 12px;">
                PROJECTED {data.projected:,.0f}
            </span>
            <span style="color: {trend_color}; font-size: 12px;">
                {data.trend_direction}{trend_text}
            </span>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_cycle_time_card(data: MetricDisplayData):
    """Render cycle time card with centered target visualization."""
    actual_color = get_status_color(data.actual_status)
    
    # Calculate position relative to target (center)
    target = data.target
    deviation = data.actual - target
    max_deviation = target * 0.25  # ±25% of target
    
    # Determine if actual is left or right of target
    if deviation >= 0:
        left_width = 50
        right_width = min(50 * (deviation / max_deviation), 50)
        bar_color = actual_color
    else:
        right_width = 50
        left_width = min(50 * (abs(deviation) / max_deviation), 50)
        bar_color = actual_color
    
    st.markdown(f"""
    <div style="
        background: {StatusColor.DARK_BG.value};
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 12px;
    ">
        <!-- Label -->
        <div style="text-align: center; margin-bottom: 8px;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 12px;">{data.label}</span>
        </div>
        
        <!-- Values Row -->
        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 14px;">{target * 0.75:.0f}</span>
            <span style="color: {StatusColor.WHITE.value}; font-size: 14px; font-weight: bold;">{target:.0f}</span>
            <span style="color: {actual_color}; font-size: 20px; font-weight: bold;">{data.actual:.1f}</span>
        </div>
        
        <!-- Centered Bar Visualization -->
        <div style="
            background: {StatusColor.GRAY.value}40;
            border-radius: 4px;
            height: 12px;
            margin-bottom: 8px;
            position: relative;
        ">
            <!-- Target marker (center) -->
            <div style="
                position: absolute;
                left: 50%;
                top: 0;
                bottom: 0;
                width: 2px;
                background: {StatusColor.WHITE.value};
            "></div>
            <!-- Actual indicator -->
            <div style="
                position: absolute;
                left: {50 + (deviation / max_deviation * 50)}%;
                top: -2px;
                width: 4px;
                height: 16px;
                background: {actual_color};
                border-radius: 2px;
            "></div>
        </div>
        
        <!-- Projected and Trend -->
        <div style="display: flex; justify-content: center; gap: 16px;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 12px;">
                PROJECTED {data.projected:.1f}
            </span>
            <span style="color: {get_status_color(data.trend_status)}; font-size: 12px;">
                {data.trend_direction}{'+' if data.trend_value >= 0 else ''}{data.trend_value:.2f}%
            </span>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_priority_shovels_table(shovels: List[Dict]):
    """Render priority shovels table."""
    st.markdown(f"""
    <div style="
        background: {StatusColor.DARK_BG.value};
        border-radius: 8px;
        padding: 16px;
        margin-bottom: 12px;
    ">
        <div style="color: {StatusColor.GRAY.value}; font-size: 12px; margin-bottom: 12px;">
            Priority Shovels
        </div>
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="color: {StatusColor.GRAY.value}; font-size: 11px; text-align: left;">
                    <th style="padding: 4px;">ID</th>
                    <th style="padding: 4px;">Material</th>
                    <th style="padding: 4px;">Compliance</th>
                    <th style="padding: 4px;">Rate</th>
                </tr>
            </thead>
            <tbody style="color: {StatusColor.WHITE.value}; font-size: 12px;">
    """, unsafe_allow_html=True)
    
    for shovel in shovels[:5]:
        compliance = shovel.get("compliance", 85)
        rate = shovel.get("rate", 4100)
        compliance_color = StatusColor.GREEN.value if compliance >= 90 else (StatusColor.ORANGE.value if compliance >= 80 else StatusColor.RED.value)
        rate_trend = shovel.get("trend", "↑")
        trend_color = StatusColor.GREEN.value if rate_trend == "↑" else StatusColor.RED.value
        
        st.markdown(f"""
                <tr>
                    <td style="padding: 4px;">{shovel.get('id', 'S12')}</td>
                    <td style="padding: 4px;">{shovel.get('material', 'Mill')}</td>
                    <td style="padding: 4px; color: {compliance_color};">{compliance}%<span style="color: {trend_color};">{rate_trend}</span></td>
                    <td style="padding: 4px;">{rate:,}<span style="color: {trend_color};">{rate_trend}</span></td>
                </tr>
        """, unsafe_allow_html=True)
    
    st.markdown("</tbody></table></div>", unsafe_allow_html=True)


def render_throughput_group(metrics: List[MetricDisplayData]):
    """Render grouped throughput metrics (2x2 grid)."""
    cols = st.columns(2)
    
    for i, metric in enumerate(metrics[:4]):
        with cols[i % 2]:
            actual_color = get_status_color(metric.actual_status)
            trend_color = get_status_color(metric.trend_status)
            trend_sign = "+" if metric.trend_value >= 0 else ""
            
            st.markdown(f"""
            <div style="
                background: {StatusColor.DARK_BG.value};
                border-radius: 8px;
                padding: 12px;
                margin-bottom: 8px;
            ">
                <div style="color: {StatusColor.GRAY.value}; font-size: 11px;">{metric.label}</div>
                <div style="color: {actual_color}; font-size: 20px; font-weight: bold;">{metric.actual:,.0f}</div>
                <div style="color: {StatusColor.GRAY.value}; font-size: 11px;">PLAN {metric.target:,.0f}</div>
                <div style="color: {trend_color}; font-size: 11px;">{metric.trend_direction}{trend_sign}{metric.trend_value:.2f}%</div>
            </div>
            """, unsafe_allow_html=True)


def render_material_delivered(label: str, actual: float, target: float, projected: float, trend: float, status: str):
    """Render material delivered metric with full-width bar."""
    color = get_status_color(status)
    bar_width = min((actual / target * 100) if target > 0 else 0, 100)
    trend_sign = "+" if trend >= 0 else ""
    trend_color = StatusColor.GREEN.value if trend >= 0 else StatusColor.RED.value
    
    st.markdown(f"""
    <div style="
        background: {StatusColor.DARK_BG.value};
        border-radius: 8px;
        padding: 12px;
        margin-bottom: 8px;
    ">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 11px;">{label}</span>
            <span style="color: {StatusColor.WHITE.value}; font-size: 11px;">{target:,.0f}</span>
        </div>
        <div style="color: {color}; font-size: 18px; font-weight: bold;">{actual:,.0f}</div>
        <div style="
            background: {StatusColor.GRAY.value}40;
            border-radius: 4px;
            height: 6px;
            margin: 8px 0;
        ">
            <div style="
                background: {color};
                width: {bar_width}%;
                height: 100%;
                border-radius: 4px;
            "></div>
        </div>
        <div style="display: flex; justify-content: space-between;">
            <span style="color: {StatusColor.GRAY.value}; font-size: 11px;">PROJECTED {projected:,.0f}</span>
            <span style="color: {trend_color}; font-size: 11px;">{trend_sign}{trend:.2f}%</span>
        </div>
    </div>
    """, unsafe_allow_html=True)


def render_ios_strategy(stockpiles: List[Dict]):
    """Render IOS strategy visualization with triangular stockpile indicators."""
    cols = st.columns(3)
    
    for i, pile in enumerate(stockpiles[:6]):
        with cols[i % 3]:
            rate = pile.get("rate", 115)
            capacity_hours = pile.get("capacity_hours", 8)
            direction = pile.get("direction", "up")  # up, down
            level_pct = pile.get("level_pct", 50)
            
            # Determine colors based on level proximity to limits
            if level_pct > 90 or level_pct < 10:
                level_color = StatusColor.RED.value
            elif level_pct > 80 or level_pct < 20:
                level_color = StatusColor.ORANGE.value
            else:
                level_color = StatusColor.GREEN.value
            
            arrow = "▲" if direction == "up" else "▼"
            arrow_color = StatusColor.GREEN.value if direction == "up" else StatusColor.ORANGE.value
            
            st.markdown(f"""
            <div style="
                background: {StatusColor.DARK_BG.value};
                border-radius: 8px;
                padding: 12px;
                margin-bottom: 8px;
                text-align: center;
            ">
                <div style="font-size: 24px; color: {arrow_color};">{arrow}</div>
                <div style="color: {StatusColor.WHITE.value}; font-size: 14px; font-weight: bold;">{rate} TPH</div>
                <div style="color: {StatusColor.GRAY.value}; font-size: 11px;">Capacity: {capacity_hours}hrs</div>
                <div style="
                    background: {StatusColor.GRAY.value}40;
                    border-radius: 4px;
                    height: 6px;
                    margin-top: 8px;
                ">
                    <div style="
                        background: {level_color};
                        width: {level_pct}%;
                        height: 100%;
                        border-radius: 4px;
                    "></div>
                </div>
            </div>
            """, unsafe_allow_html=True)


def apply_dashboard_style():
    """Apply global dashboard styling."""
    st.markdown("""
    <style>
        /* Dark theme */
        .stApp {
            background-color: #0a0a0f;
        }
        
        /* Remove default padding */
        .block-container {
            padding-top: 1rem;
            padding-bottom: 0rem;
            padding-left: 1rem;
            padding-right: 1rem;
        }
        
        /* Hide streamlit branding */
        #MainMenu {visibility: hidden;}
        footer {visibility: hidden;}
        header {visibility: hidden;}
        
        /* Custom scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        ::-webkit-scrollbar-track {
            background: #1a1a2e;
        }
        ::-webkit-scrollbar-thumb {
            background: #4a4a6a;
            border-radius: 4px;
        }
    </style>
    """, unsafe_allow_html=True)
