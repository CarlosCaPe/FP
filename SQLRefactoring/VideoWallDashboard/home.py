"""
🏠 IROC Video Wall - Main Navigation
=====================================
Home page with navigation to:
1. Production Performance Dashboard
2. Mining Operations Chatbot

Run with: streamlit run home.py
"""

import streamlit as st
from datetime import datetime

# =============================================================================
# PAGE CONFIG
# =============================================================================
st.set_page_config(
    page_title="IROC Video Wall",
    page_icon="⛏️",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# =============================================================================
# STYLING
# =============================================================================
st.markdown("""
<style>
    .stApp {
        background: linear-gradient(135deg, #0d1117 0%, #1a1f2e 50%, #16213e 100%);
    }
    
    .block-container {
        padding: 2rem;
        max-width: 1000px;
    }
    
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    header {visibility: hidden;}
    
    .hero-title {
        text-align: center;
        color: #f97316;
        font-size: 48px;
        font-weight: bold;
        margin-bottom: 10px;
    }
    
    .hero-subtitle {
        text-align: center;
        color: #9ca3af;
        font-size: 18px;
        margin-bottom: 40px;
    }
    
    .nav-card {
        background: linear-gradient(145deg, #1e293b 0%, #0f172a 100%);
        border: 1px solid #334155;
        border-radius: 16px;
        padding: 30px;
        text-align: center;
        transition: all 0.3s ease;
        cursor: pointer;
        height: 280px;
    }
    
    .nav-card:hover {
        transform: translateY(-5px);
        border-color: #f97316;
        box-shadow: 0 10px 40px rgba(249, 115, 22, 0.2);
    }
    
    .nav-icon {
        font-size: 64px;
        margin-bottom: 16px;
    }
    
    .nav-title {
        color: white;
        font-size: 22px;
        font-weight: bold;
        margin-bottom: 12px;
    }
    
    .nav-desc {
        color: #9ca3af;
        font-size: 14px;
        line-height: 1.5;
    }
    
    .feature-tag {
        display: inline-block;
        background: #374151;
        color: #e5e7eb;
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 11px;
        margin: 4px 2px;
    }
    
    .feature-tag.new {
        background: #166534;
        color: #4ade80;
    }
    
    .footer-info {
        text-align: center;
        color: #6b7280;
        font-size: 12px;
        margin-top: 60px;
        padding-top: 20px;
        border-top: 1px solid #333;
    }
</style>
""", unsafe_allow_html=True)

# =============================================================================
# MAIN CONTENT
# =============================================================================

# Hero Section
st.markdown("""
<div class="hero-title">⛏️ IROC Video Wall</div>
<div class="hero-subtitle">Freeport Mining Operations Dashboard</div>
""", unsafe_allow_html=True)

# Navigation Cards
col1, col2 = st.columns(2, gap="large")

with col1:
    st.markdown("""
    <div class="nav-card">
        <div class="nav-icon">📊</div>
        <div class="nav-title">Production Performance</div>
        <div class="nav-desc">
            Real-time video wall dashboard showing Loading, Haulage, 
            LBS on Ground, and Processing metrics for CC6 IROC.
        </div>
        <div style="margin-top: 16px;">
            <span class="feature-tag">Rolling 60 min</span>
            <span class="feature-tag">Auto-refresh</span>
            <span class="feature-tag">Morenci</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    if st.button("Open Dashboard →", key="btn_dashboard", use_container_width=True):
        st.switch_page("pages/1_📊_Dashboard.py")

with col2:
    st.markdown("""
    <div class="nav-card">
        <div class="nav-icon">💬</div>
        <div class="nav-title">Mining Chatbot</div>
        <div class="nav-desc">
            Natural language interface to query ADX and Snowflake.
            Ask questions about any site in plain English or Spanish.
        </div>
        <div style="margin-top: 16px;">
            <span class="feature-tag new">NEW</span>
            <span class="feature-tag">7 Sites</span>
            <span class="feature-tag">ADX + Snowflake</span>
        </div>
    </div>
    """, unsafe_allow_html=True)
    
    if st.button("Open Chatbot →", key="btn_chatbot", use_container_width=True):
        st.switch_page("pages/2_💬_Chatbot.py")

# Info Section
st.markdown("<br><br>", unsafe_allow_html=True)

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("""
    <div style="text-align: center; padding: 20px;">
        <div style="color: #22c55e; font-size: 28px; font-weight: bold;">7</div>
        <div style="color: #9ca3af; font-size: 12px;">Mining Sites</div>
    </div>
    """, unsafe_allow_html=True)

with col2:
    st.markdown("""
    <div style="text-align: center; padding: 20px;">
        <div style="color: #3b82f6; font-size: 28px; font-weight: bold;">16</div>
        <div style="color: #9ca3af; font-size: 12px;">KPI Metrics</div>
    </div>
    """, unsafe_allow_html=True)

with col3:
    st.markdown("""
    <div style="text-align: center; padding: 20px;">
        <div style="color: #f97316; font-size: 28px; font-weight: bold;">2</div>
        <div style="color: #9ca3af; font-size: 12px;">Data Sources</div>
    </div>
    """, unsafe_allow_html=True)

# Footer
st.markdown(f"""
<div class="footer-info">
    <strong>FREEPORT</strong> - Foremost in Copper<br>
    IROC Video Wall v2.0 | {datetime.now().strftime('%Y-%m-%d %H:%M')}<br>
    ADX: fctsnaproddatexp02.westus2.kusto.windows.net | Snowflake: FCX-NA
</div>
""", unsafe_allow_html=True)
