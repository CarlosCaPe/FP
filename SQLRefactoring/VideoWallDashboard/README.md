# IROC Video Wall - Production Performance Dashboard

## Overview

Real-time production performance dashboard for the CC6 IROC Video Wall at Morenci mining operations. This dashboard displays LH&IOS (Load-Haul & In-Ore Stockpile) metrics following strict requirements for display format, calculations, and color coding.

## 📋 Requirements Source

Based on: **IROC Video Wall Production Performance Section - Requirements Definition (January 2026)**

### Review History
| Date | Purpose | Status |
|------|---------|--------|
| 12-10-2025 | Layout concept definition | ✅ Approved |
| 12-17-2025 | Production performance metrics definition | ✅ Approved |
| 01-06-2026 | Review of concept design | ✅ Approved |
| 01-13-2026 | Final deliverable rev. 0 | ✅ Approved |

## 🏗️ Architecture

```
VideoWallDashboard/
├── app.py                      # Main Streamlit application
├── requirements.txt            # Python dependencies
├── config/
│   └── settings.py            # Configuration and site definitions
├── data/
│   ├── connectors.py          # Snowflake & ADX data connectors
│   └── queries.py             # SQL/KQL query templates
├── models/
│   └── metrics.py             # Business rules and metric definitions
├── ui/
│   └── components.py          # Reusable UI components
└── knowledge_base/
    └── semantic_model.yaml    # Complete semantic model
```

## 📊 Dashboard Sections

### 1. Loading Section
| Metric | Time Window | Source |
|--------|-------------|--------|
| Dig Compliance (%) | Rolling 60 min | Snowflake |
| Dig Rate (TPRH) | Rolling 60 min | Snowflake |
| Priority Shovels (Top 5) | Rolling 60 min | Snowflake |

### 2. Haulage Section
| Metric | Time Window | Source |
|--------|-------------|--------|
| Cycle Time (min) | Rolling 60 min | Snowflake |
| # of Trucks (Qty) | Rolling 60 min | Snowflake |
| Dump Plan Compliance (%) | Rolling 60 min | Snowflake |
| Asset Efficiency (%) | Rolling 60 min | Snowflake |

### 3. Lbs on Ground Section
| Metric | Time Window | Source |
|--------|-------------|--------|
| Mill/MFL/FCP Crusher (TPOH) | Rolling 60 min | ADX |
| Material Delivered (tons) | 12 Hours (Shift) | Snowflake |
| IOS Level Strategy | Rolling 60 min | ADX |

## 📐 Display Standards

### Color Coding (Actual vs Target)
- 🟢 **Green**: ≥ 90%
- 🟠 **Orange**: 80% - 90%
- 🔴 **Red**: < 80%

### Trend Indicators
- ↑ **Green**: Increase from 1 hour ago
- → **Stable**: No change
- ↓ **Orange**: Decrease < 10%
- ↓ **Red**: Decrease > 10%

### Value Definitions
| Element | Definition |
|---------|------------|
| **Actual** | Rolling 60 min performance |
| **Target** | Rolling 60 min weighted avg from 36H plan |
| **Projected** | Predicted avg hourly performance for entire shift |
| **Trend** | Ratio of current to 1 hour ago (always show sign) |

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd VideoWallDashboard
pip install -r requirements.txt
```

### 2. Run Dashboard
```bash
streamlit run app.py
```

### 3. Access Dashboard
Open browser to `http://localhost:8501`

## ⚙️ Configuration

### Data Sources

**Snowflake:**
- Account: `FCX-NA`
- Database: `PROD_WG`
- Schema: `LOAD_HAUL`
- Auth: External Browser

**Azure Data Explorer:**
- Cluster: `https://fctsnaproddatexp02.westus2.kusto.windows.net`
- Databases: Morenci, Bagdad, Miami, Climax, Sierrita, NewMexico, CerroVerde
- Functions: `FCTSCURRENT()`, `FCTS()`

### Key PI Tags (Morenci)
| Metric | PI Tag |
|--------|--------|
| Mill Crusher | `MOR-CR03_WI00317_PV` |
| MFL Crusher | `MOR-CR02_WI01203_PV` |
| IOS Main | `MOR-CC06_LI00601_PV` |
| IOS Small | `MOR-CC10_LI0102_PV` |

## 📁 Knowledge Base

The complete semantic model is in `knowledge_base/semantic_model.yaml` containing:
- All 16 business outcomes
- Business rules for calculations
- Display element specifications
- Data source mappings
- Query templates

## 🎯 Design Principles

1. **Focus on driving compliance to plan** – current and for entire shift
2. **Actionable information** – clear status indicators
3. **Consistency across all metrics** – same time scales, calculations
4. **No mental math required** – viewers understand display at a glance

## 👥 Stakeholders

- **Project Team**: Robert Catron, Fio Giana, Rohit Khatter, Ethan Kircher, Charlie Krug, Ravikanth Malladi, Chloe Sweatman, Sasha Warren, Robert Yao
- **Morenci SMEs**: Mark Dwyer, Frederique-Audrey Germain, Anup Mistry, Asad Ul-Haq

## 📝 License

Internal Freeport-McMoRan use only.
