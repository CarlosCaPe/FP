# 🏭 Mining Operations Chatbot

Chat interface to query ADX and Snowflake using natural language.

## 📋 Features

- **Dark Theme (ChatGPT-like)** - Modern UI with dark theme
- **Single Authentication** - Authenticate once per session
- **Natural Language** - Understands natural language queries
- **Formatted Output** - Query + explanation + results table
- **Reference Sidebar** - Shows available sites and outcomes

## 🚀 Quick Start

```powershell
# Navigate to directory
cd c:\Users\Lenovo\dataqbs\FP

# Activate venv
.\.venv\Scripts\Activate

# Run the app
streamlit run chatbot/mining_chatbot.py
```

The app will automatically open at `http://localhost:8501`

## 💬 Query Examples

| Input | Description |
|-------|-------------|
| `ios level morenci` | Stockpile level at Morenci |
| `crusher rate MOR` | Crusher rate at Morenci |
| `truck count bagdad` | Active trucks at Bagdad |
| `dig rate sierrita` | Excavation rate at Sierrita |
| `top shovels MOR` | Top 5 productive shovels |
| `cycle time BAG` | Average cycle time |
| `mill tons morenci` | Tons delivered to Mill |

## 🌍 Supported Sites

| Code | Name | Data Availability |
|------|------|-------------------|
| MOR | Morenci | ✅ Full (ADX + Snowflake) |
| BAG | Bagdad | ✅ Full |
| SIE | Sierrita | ✅ Partial |
| SAM | Miami | ⚠️ ADX Only |
| CMX | Climax | ⚠️ ADX Only |
| NMO | NewMexico | ⚠️ ADX Only |
| CVE | CerroVerde | ⚠️ ADX Only |

## 📊 Outcomes (KPIs)

### Loading
- **dig compliance** - % excavation compliance
- **dig rate** - TPOH (tons per operating hour)
- **priority shovels** - Top 5 shovels

### Haulage
- **truck count** - Active trucks
- **cycle time** - Cycle time
- **dump compliance** - % dump compliance

### Mill
- **mill tons** - Tons delivered
- **crusher rate** - Crusher TPH
- **mill rate** - Milling TPH
- **ios level** - In-Ore Stockpile level ⭐

## 🔐 Authentication

### ADX
- Uses `InteractiveBrowserCredential` from Azure Identity
- Browser will automatically open for SSO
- Credentials are cached in `st.session_state`

### Snowflake
- Uses `externalbrowser` authenticator
- Requires FCX-NA account configured
- Connects to PROD_WG.LOAD_HAUL

## 📁 Structure

```
chatbot/
├── mining_chatbot.py    # Main app
└── README.md            # This documentation
```

## 🔧 Dependencies

```
streamlit
pyyaml
azure-identity
azure-kusto-data
snowflake-connector-python
pandas
tabulate
```

## 📚 Semantic Model

The chatbot uses the semantic model located at:
```
SQLRefactoring/adx_semantic_models/ADX_UNIFIED.semantic.yaml
```

This file contains the definition of:
- 7 mining sites
- 16 business outcomes per site
- ADX sensor mappings
- Snowflake queries

## 🎨 Customization

### Change colors
Edit the CSS section in `mining_chatbot.py`:

```python
.stApp {
    background-color: #1a1a2e;  # Main background
}
[data-testid="stSidebar"] {
    background-color: #16213e;  # Sidebar
}
```

### Add more outcomes
1. Edit the `interpret_query()` function
2. Add keyword detection
3. Define the corresponding query

## 🐛 Troubleshooting

### "Semantic model not found"
Verify the file exists:
```
SQLRefactoring/adx_semantic_models/ADX_UNIFIED.semantic.yaml
```

### ADX Auth Error
1. Verify Azure CLI is installed
2. Run `az login` first
3. Verify cluster access

### Snowflake Auth Error
1. Verify FCX-NA account
2. Open Snowflake web to verify credentials
3. Verify VPN if applicable

---

*Created for the DataQBS project - Mining Operations Analytics*
