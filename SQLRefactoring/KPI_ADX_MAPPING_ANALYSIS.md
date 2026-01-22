# KPI to ADX Data Source Mapping Analysis

## Executive Summary

This document analyzes the business KPIs defined in `knowledge_base.json` and maps them to available ADX data sources. The goal is to determine which metrics can be served from ADX vs other sources (Snowflake, manual entry, etc.).

> **📌 Related:** See [ADX_UNIFIED.semantic.yaml](adx_semantic_models/ADX_UNIFIED.semantic.yaml) for the complete semantic model with 7 sites × 16 outcomes validated with real data.

---

## 🎯 PRIORITY CLASSIFICATION

| Priority | Value Chain Step | ADX Feasibility |
|----------|------------------|-----------------|
| 🔴 **HIGHEST** | Mill IOS (In-Ore Stockpile) | ✅ **FULLY AVAILABLE** |
| 🟠 HIGH | Mill Crusher Rate | ✅ **FULLY AVAILABLE** |
| 🟡 MEDIUM | Processing Metrics | ✅ **MOSTLY AVAILABLE** |
| 🟢 LOWER | Drilling/Blasting | ⚠️ **SNOWFLAKE ONLY** |
| 🟢 LOWER | Loading/Haulage | ⚠️ **PARTIAL (SAP Integration)** |

---

## 🔴 MILL IOS - HIGHEST PRIORITY

**Business Requirement:** "Current level of IOS + direction of change. Design to focus on this!"

### ADX Availability: ✅ FULLY AVAILABLE

| KPI | PI Tag | ADX Source | KQL Pattern |
|-----|--------|------------|-------------|
| **Main IOS Level** | `mor-cc06_li00601_pv` | `database("Morenci").FCTS` | `sensor_id =~ "MOR-CC06_LI00601_PV"` |
| **Small IOS Level** | `mor-cc10_li0102_pv` | `database("Morenci").FCTS` | `sensor_id =~ "MOR-CC10_LI0102_PV"` |
| **Current Snapshot** | Same tags | `database("Morenci").FCTSCURRENT()` | Latest value |
| **Trend Direction** | Same tags | `database("Morenci").FCTS` | Use `prev()` function for delta |

### Recommended KQL Query:
```kql
// Mill IOS Level with Direction of Change
let lookback = 1h;
database("Morenci").FCTS
| where sensor_id in~ ("MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV")
| where timestamp > ago(lookback)
| summarize 
    current_level = arg_max(timestamp, value),
    previous_level = arg_min(timestamp, value)
    by sensor_id
| extend direction = case(
    toreal(current_level_value) > toreal(previous_level_value), "↑ INCREASING",
    toreal(current_level_value) < toreal(previous_level_value), "↓ DECREASING",
    "→ STABLE"
)
| project sensor_id, current_level = current_level_value, direction, timestamp = current_level_timestamp
```

---

## 🟠 MILL CRUSHER RATE - HIGH PRIORITY

**Business Requirement:** Target 8,500-9,000 tph, PI tag: `mor-cr03_wi00317_pv`

### ADX Availability: ✅ FULLY AVAILABLE

| KPI | PI Tag | ADX Source | KQL Pattern |
|-----|--------|------------|-------------|
| **Crusher #3 Rate** | `mor-cr03_wi00317_pv` | `database("Morenci").FCTS` | `sensor_id =~ "MOR-CR03_WI00317_PV"` |
| **Crushed Leach Rate** | `mor-cr02_wi01203_pv` | `database("Morenci").FCTS` | `sensor_id =~ "MOR-CR02_WI01203_PV"` |

### Target Ranges:
- **Mill Crusher:** 8,500-9,000 tph
- **Crushed Leach:** 4,500-6,000 tph

### Recommended KQL Query:
```kql
// Mill Crusher Rates with Target Comparison
database("Morenci").FCTS
| where sensor_id in~ ("MOR-CR03_WI00317_PV", "MOR-CR02_WI01203_PV")
| where timestamp > ago(1h)
| summarize arg_max(timestamp, value) by sensor_id
| extend 
    metric_name = case(
        sensor_id =~ "MOR-CR03_WI00317_PV", "Mill Crusher Rate",
        sensor_id =~ "MOR-CR02_WI01203_PV", "Crushed Leach Rate",
        sensor_id
    ),
    target_min = case(
        sensor_id =~ "MOR-CR03_WI00317_PV", 8500.0,
        sensor_id =~ "MOR-CR02_WI01203_PV", 4500.0,
        0.0
    ),
    target_max = case(
        sensor_id =~ "MOR-CR03_WI00317_PV", 9000.0,
        sensor_id =~ "MOR-CR02_WI01203_PV", 6000.0,
        0.0
    )
| extend 
    current_value = toreal(value),
    status = case(
        toreal(value) >= target_min and toreal(value) <= target_max, "✅ ON TARGET",
        toreal(value) < target_min, "⚠️ BELOW TARGET",
        "🔴 ABOVE TARGET"
    )
| project metric_name, current_value, target_min, target_max, status, timestamp
```

---

## 🟡 PROCESSING METRICS

### ADX Availability: ✅ MOSTLY AVAILABLE via FCTS

The AppIntegration database contains `Morenci_Batman_BallMill_Aggregates` function which provides:
- **32 Ball Mills** with individual metrics
- **TPH (tons per hour)** per mill
- **Mill Power** readings
- **Classifier pH and Amps**
- **Wet Grind percentages**

### Available PI Tags from BallMill Function:
```
Section 1-4, Ball Mills 1-32:
- MOR-WIC01XX_PV (TPH per mill)
- MOR-JIC32XX_PV (Mill Power)
- MOR-IIC31XX_PV (Classifier Amps)
- MOR-AIC91XX_PV (Classifier pH)
- MOR-LI03XX_PV (Front Launder)
- MOR-LI09XX_PV (Back Launder)
```

### ADX Function Available:
```kql
// Use pre-built function for Ball Mill aggregates
database("AppIntegration").Morenci_Batman_BallMill_Aggregates()
| project section, ballmill, tph_now, mill_power, classifier_ph
```

---

## 🟢 DRILLING METRICS

**Business Requirement:** Drilling rate, cycle times, penetration rate

### ADX Availability: ⚠️ SNOWFLAKE ONLY

| KPI | Current Source | ADX Available? | Notes |
|-----|----------------|----------------|-------|
| `AVG_PNTRTN_RATE_FEET_PER_MIN` | Snowflake PROD_WG.DRILL_BLAST.DRILL_CYCLE | ❌ NO | Fleet data, not sensor |
| `DRILL_CYCLE_HRS_CYCLE` | Snowflake | ❌ NO | Computed from dispatch system |
| `PROPEL_HOURS` | Snowflake | ❌ NO | Equipment telematics |
| `WEIGHT_ON_BIT_RANGE_LBS` | Snowflake | ❌ NO | Target: 50,000-70,000 lbs |

### Migration Path:
1. Drilling data comes from fleet dispatch systems (Modular, Wenco, etc.)
2. Would require new IoT sensors or fleet integration to ADX
3. Current path: Continue using Snowflake for drill metrics

---

## 🟢 BLASTING METRICS

**Business Requirement:** Blast patterns, powder factor, fragmentation

### ADX Availability: ⚠️ SNOWFLAKE ONLY

| KPI | Current Source | ADX Available? | Notes |
|-----|----------------|----------------|-------|
| LBS_ON_GROUND | Snowflake | ❌ NO | Explosives inventory |
| POWDER_FACTOR | Snowflake | ❌ NO | Calculated metric |
| FRAGMENTATION | Snowflake | ❌ NO | Usually manual entry |

### Why Not in ADX:
- Blasting is event-based, not continuous sensor data
- Explosives tracking is inventory/compliance focused
- Data sources: Blast design software, manual entry

---

## 🟢 LOADING METRICS (LHD/Shovel)

### ADX Availability: ⚠️ PARTIAL - SAP Integration Available

The `HaulTruck` function in AppIntegration shows SAP integration:

| KPI | ADX Available? | Source |
|-----|----------------|--------|
| Equipment Status | ✅ Partial | `HaulTruck()` function - SAP data |
| Fuel Consumption | ✅ Yes | Via SAP Measurement |
| Operating Hours | ✅ Yes | Via SAP Measurement |
| Tons Loaded | ⚠️ Limited | Not directly in ADX |
| Cycle Time | ❌ No | Dispatch system only |

### Recommended KQL:
```kql
// Haul Truck metrics from SAP integration
database("AppIntegration").HaulTruck()
| project SAPEquipmentID, SAPMeasurementID, SAPMeasurementType, timestamp, value, uom
| where SAPMeasurementID contains "Fuel" or SAPMeasurementID contains "Hours"
```

---

## 🟢 HAULAGE METRICS

### ADX Availability: ⚠️ PARTIAL

| KPI | Business Target | ADX Available? | Source |
|-----|-----------------|----------------|--------|
| Cycle Time | < 25 min | ⚠️ Via SAP | HaulTruck function |
| Dump Compliance | N/A | ❌ No | Dispatch system |
| Tons/Hour | Per truck targets | ⚠️ Limited | Computed, not sensor |
| Fuel Rate | N/A | ✅ Yes | SAP Integration |

---

## 📊 COMPLETE KPI AVAILABILITY MATRIX

| # | Value Chain | KPI Name | PI Tag / Sensor | ADX? | Confidence |
|---|-------------|----------|-----------------|------|------------|
| 1 | **Mill IOS** | IOS Level | MOR-CC06_LI00601_PV | ✅ YES | 100% |
| 2 | **Mill IOS** | Small IOS Level | MOR-CC10_LI0102_PV | ✅ YES | 100% |
| 3 | **Mill Crusher** | Crusher #3 Rate | MOR-CR03_WI00317_PV | ✅ YES | 100% |
| 4 | **Mill Crusher** | Crushed Leach | MOR-CR02_WI01203_PV | ✅ YES | 100% |
| 5 | **Processing** | Ball Mill TPH | MOR-WIC01XX_PV | ✅ YES | 100% |
| 6 | **Processing** | Mill Power | MOR-JIC32XX_PV | ✅ YES | 100% |
| 7 | **Processing** | Classifier pH | MOR-AIC91XX_PV | ✅ YES | 100% |
| 8 | **Processing** | Bin Levels | MOR-MS01_LIC215XX_PV | ✅ YES | 100% |
| 9 | **Drilling** | Penetration Rate | PROD_WG.DRILL_BLAST | ❌ NO | 0% |
| 10 | **Drilling** | Drill Cycle Time | PROD_WG.DRILL_BLAST | ❌ NO | 0% |
| 11 | **Blasting** | LBS on Ground | PROD_WG.DRILL_BLAST | ❌ NO | 0% |
| 12 | **Blasting** | Powder Factor | PROD_WG.DRILL_BLAST | ❌ NO | 0% |
| 13 | **Loading** | Equipment Hours | SAP via HaulTruck() | ⚠️ PARTIAL | 70% |
| 14 | **Haulage** | Fuel Consumption | SAP via HaulTruck() | ✅ YES | 90% |
| 15 | **Haulage** | Cycle Time | Dispatch System | ❌ NO | 0% |

---

## 🏗️ RECOMMENDED ADX FUNCTIONS TO CREATE

### 1. MillIOS_Current() - HIGHEST PRIORITY
```kql
// Function: MillIOS_Current
// Returns: Current IOS levels with trend direction
.create-or-alter function MillIOS_Current() {
    let ios_sensors = dynamic(["MOR-CC06_LI00601_PV", "MOR-CC10_LI0102_PV"]);
    database("Morenci").FCTS
    | where sensor_id in~ (ios_sensors)
    | where timestamp > ago(2h)
    | order by sensor_id, timestamp asc
    | serialize 
    | extend prev_value = prev(value, 1), prev_sensor = prev(sensor_id, 1)
    | where sensor_id == prev_sensor or isnull(prev_sensor)
    | summarize arg_max(timestamp, value, prev_value) by sensor_id
    | extend 
        current = toreal(value),
        previous = toreal(prev_value),
        direction = case(
            toreal(value) > toreal(prev_value), "INCREASING",
            toreal(value) < toreal(prev_value), "DECREASING",
            "STABLE"
        )
    | project sensor_id, level = current, direction, timestamp
}
```

### 2. MiningKPIs_Summary() - Dashboard View
```kql
// Function: MiningKPIs_Summary
// Returns: All key processing KPIs for dashboard
.create-or-alter function MiningKPIs_Summary() {
    let kpi_sensors = dynamic([
        "MOR-CC06_LI00601_PV",  // Main IOS
        "MOR-CC10_LI0102_PV",   // Small IOS  
        "MOR-CR03_WI00317_PV",  // Crusher Rate
        "MOR-CR02_WI01203_PV"   // Leach Rate
    ]);
    database("Morenci").FCTSCURRENT()
    | where sensor_id in~ (kpi_sensors)
    | extend kpi_name = case(
        sensor_id =~ "MOR-CC06_LI00601_PV", "IOS_Level_Main",
        sensor_id =~ "MOR-CC10_LI0102_PV", "IOS_Level_Small",
        sensor_id =~ "MOR-CR03_WI00317_PV", "Crusher_Rate_TPH",
        sensor_id =~ "MOR-CR02_WI01203_PV", "Leach_Rate_TPH",
        sensor_id
    )
    | project kpi_name, value = toreal(value), timestamp
}
```

---

## 📈 GAP ANALYSIS SUMMARY

### ✅ ADX CAN PROVIDE (Focus Development Here):
1. **Mill IOS Levels** - Real-time with trend
2. **Crusher Rates** - TPH monitoring
3. **Ball Mill Operations** - 32 mills detailed metrics
4. **Conveyor/Bin Levels** - Full coverage
5. **Equipment Telemetry** - Via SAP integration

### ❌ REQUIRES SNOWFLAKE (No ADX Path):
1. **Drill Cycle Metrics** - Fleet dispatch data
2. **Blast Patterns** - Event-based, not sensor
3. **LBS on Ground** - Inventory system
4. **Haulage Dispatch** - Cycle times, assignments

### ⚠️ HYBRID APPROACH NEEDED:
1. **Equipment Hours** - SAP in ADX, dispatch in Snowflake
2. **Productivity Metrics** - Calculated from both sources

---

## 🎯 IMPLEMENTATION RECOMMENDATIONS

### Phase 1: Mill IOS Dashboard (HIGHEST PRIORITY)
1. Create `MillIOS_Current()` function in Global database
2. Build ADX dashboard for IOS levels + direction
3. Alert on rapid changes (>5% in 15 min)

### Phase 2: Processing Metrics
1. Leverage existing `Morenci_Batman_*` functions
2. Add target thresholds to queries
3. Build section-by-section monitoring

### Phase 3: Unified Mining Dashboard
1. ADX for sensor data (IOS, crusher, mills)
2. Snowflake for computed metrics (drilling, haulage cycles)
3. Federated queries where needed

---

## 📁 RELATED FILES

| File | Description |
|------|-------------|
| [ADX_UNIFIED.semantic.yaml](adx_semantic_models/ADX_UNIFIED.semantic.yaml) | **THE** unified semantic model - 7 sites × 16 outcomes |
| [knowledge_base.json](knowledge_base.json) | Business KPI definitions |
| [adx_snapshots/](adx_snapshots/) | Database structure snapshots |
| [validate_semantic_model.py](tools/scripts/validate_semantic_model.py) | Model validation script |

## 📊 SEMANTIC MODEL VALIDATION SUMMARY

| Site | Snowflake | ADX | Total | Notes |
|------|-----------|-----|-------|-------|
| **MOR** | 9/10 | 6/6 | **15/16** | Full coverage |
| **BAG** | 9/10 | 6/6 | **15/16** | Full coverage |
| **SIE** | 7/10 | 6/6 | **13/16** | Good coverage |
| **SAM** | 0/10 | 6/6 | **6/16** | No Load/Haul - processing only |
| **CMX** | 0/10 | 5/6 | **5/16** | Molybdenum operation |
| **NMO** | 0/10 | 6/6 | **6/16** | Different dispatch system |
| **CVE** | 0/10 | 6/6 | **6/16** | Peru - separate systems |

---

*Generated: 2026-01-22*
*Author: ADX Analysis Tool*
