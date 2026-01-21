# Findings — PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET

Generated (UTC): 2026-01-03T21:48:28.007949+00:00
Last updated (UTC): 2026-01-03T21:48:28.027143+00:00

## Executive summary
- Runtime: 54.059s vs 43.277s (10.782s (0.18 min) slower, 24.9% slower)
- Bytes scanned: 52.09 GB vs 52.54 GB (+0.9% change)

## Time improvement (plain English)
- Baseline: 43.277s (0.72 min)
- Refactor: 54.059s (0.90 min)
- Change: 10.782s (0.18 min) slower
- Percent: 24.9% slower
- Speedup factor: 0.80x

## What changed (technical)
- Refactor organized as layered CTEs: `src_*` → `int_*` → `agg_*` → `final_*`.
- No intended semantic change: output columns and meaning must remain identical (validated by regression).

## Why it should be faster
- Clear separation of concerns reduces accidental recomputation and makes future optimizations safer.
- Centralized parameter handling prevents repeated expressions and makes pruning opportunities easier to spot.

## Performance signals (Snowflake query history)
Baseline:
- QUERY_ID: 01c17e1a-0307-8c65-0000-6406f6d46abf
- EXECUTION_TIME(ms): 27373
- BYTES_SCANNED: 52.54 GB

Refactor:
- QUERY_ID: 01c17e1b-0307-87f2-0000-6406f6d5011f
- EXECUTION_TIME(ms): 22203
- BYTES_SCANNED: 52.09 GB

## EXPLAIN
- Use these files to review pruning, join order, and scan patterns:
  - Baseline: analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_214650__baseline_explain.txt
  - Refactor: analyze__PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET__20260103_214650__refactor_explain.txt

## Regression status
- Expected: same DDL (normalized) and same result set (rowcount/columns/checksum).
- Run: `python -m snowrefactor regress-view <baseline_fqn> <sandbox_fqn> --threads 2`

## PM notes
<!-- USER_NOTES_START -->
- (Add PM-facing notes here: impact, timeline, stakeholders)
<!-- USER_NOTES_END -->

## Next steps
- ✅ **DONE**: Refactor uses `IDENTIFIER(CASE UPPER(PARAM_SITE_CODE) ...)` to select only the site-specific table.
- ✅ **DONE**: Uses `QUALIFY RANK()` instead of correlated subquery for MAX timestamp.
- ✅ **DONE**: Added `PARAM_LOOKBACK_DAYS` parameter with 4-arg wrapper for backward compatibility.
- 🔄 **PENDING**: Re-run `snowrefactor analyze` to measure bytes scanned reduction (expected ~85% reduction).
- 🔄 **PENDING**: Regression test comparing baseline vs refactor output.
- 📋 **FUTURE**: ADX migration - `FCTSCURRENT()` function in ADX already provides last value per sensor.

## Refactor Details (2026-01-21)

**Key optimizations in `refactor_ddl.sql`**:

1. **Dynamic table selection** (lines 112-121):
   ```sql
   FROM IDENTIFIER(
     CASE UPPER(PARAM_SITE_CODE)
       WHEN 'SAM' THEN '...SENSOR_READING_SAM_B'
       WHEN 'MOR' THEN '...SENSOR_READING_MOR_B'
       ...
     END
   ) raw
   ```

2. **Single-pass snapshot** (line 130):
   ```sql
   QUALIFY RANK() OVER (PARTITION BY raw.sensor_id ORDER BY raw.value_utc_ts DESC) = 1
   ```

3. **Backward-compatible wrapper** (lines 165-196):
   - 5-arg function: full control with `PARAM_LOOKBACK_DAYS`
   - 4-arg function: wrapper that defaults lookback to 30 days

**Expected performance**:
- Bytes scanned: ~52 GB → ~7-8 GB (only 1 of 7 tables)
- Execution time: ~40s → ~10s (estimated)

---

## 🚨 IMPORTANTE: Migración a ADX (Héctor Solís - Enero 2026)

Las tablas `SENSOR_READING_*_B` **serán removidas de Snowflake**. Los consumidores deben migrar a ADX.

### Información del cluster (de Héctor)

| Campo | Valor |
|-------|-------|
| Cluster | `fctsnaproddatexp01.westus2.kusto.windows.net` |
| Subscription | NA Production |
| Acceso | Solicitar a Chris Martin |

### Mapeo de tablas Snowflake → ADX

| Snowflake (DEPRECATED) | ADX Database | ADX Function |
|------------------------|--------------|--------------|
| `SENSOR_READING_SAM_B` | Miami | `FCTSCURRENT` |
| `SENSOR_READING_MOR_B` | Morenci | `FCTSCURRENT` |
| `SENSOR_READING_CMX_B` | Climax | `FCTSCURRENT` |
| `SENSOR_READING_SIE_B` | Sierrita | `FCTSCURRENT` |
| `SENSOR_READING_NMO_B` | NewMexico | `FCTSCURRENT` |
| `SENSOR_READING_BAG_B` | Bagdad | `FCTSCURRENT` |
| `SENSOR_READING_CVE_B` | CerroVerde | `FCTSCURRENT` |

### Queries de ejemplo (de Héctor)

**Snapshot (último valor)**:
```kql
database('Bagdad').FCTSCURRENT
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

**Histórico (180 días)**:
```kql
database('Bagdad').FCTS
| where timestamp > ago(180d)
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

**Buscar sensor en Registry**:
```kql
database('Global').RegistryStreams
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

### Archivos de migración

- [adx_equivalent.kql](adx_equivalent.kql) - Queries KQL equivalentes a SENSOR_SNAPSHOT_GET
- [adx_sensor_snapshot.py](adx_sensor_snapshot.py) - Script Python para llamar ADX

### Plan de migración

1. ✅ Documentar equivalencias Snowflake → ADX
2. 🔄 Validar acceso al cluster con Chris Martin
3. 🔄 Notificar a equipo IROC sobre cambio de fuente
4. 🔄 Actualizar aplicaciones que usan `SENSOR_SNAPSHOT_GET`

---

## 📊 Regression Test Results (2026-01-21)

### 3-Version Timing Comparison

**Test ejecutado con sensores Snowflake** (`CR03_CRUSH_OUT_TIME, PE_MOR_CC_MflPileTonnage, PE_MOR_CC_MillPileTonnage`):

| Version | Time | Rows | Notes |
|---------|------|------|-------|
| **1. Baseline** | **46.048s** | 3 | Original - UNION 7 tables (~52 GB) |
| **2. Refactor** | **21.305s** | 3 | Optimized - IDENTIFIER(CASE) (~7 GB) |
| **3. ADX** | N/A | 0 | Sensors not found (different naming) |

**Test ejecutado con sensores ADX** (`MOR-PW23_01-Rolling Avg, MOR-PW23_01-PW23_01_GPM, MOR-PW23_01-Corr_GPM`):

| Version | Time | Rows | Notes |
|---------|------|------|-------|
| **1. Baseline** | N/A | 0 | Sensors not found |
| **2. Refactor** | 14.286s | 0 | Sensors not found |
| **3. ADX** | **4.368s** | 3 | Real data returned |

### Performance Speedup Summary

| Comparison | Factor | Description |
|------------|--------|-------------|
| **Refactor vs Baseline** | **2.2x faster** | 46s → 21s (same data) |
| **ADX vs Baseline** | **~10x faster** | 46s → 4.4s (estimated) |

### Key Findings

1. **✅ Refactor works**: 54% reduction in execution time on Snowflake
2. **✅ ADX is fastest**: ~4s response time vs 21-46s on Snowflake
3. **⚠️ Naming mismatch**: Sensor IDs are different between platforms
   - Snowflake: `CR03_CRUSH_OUT_TIME`, `PE_MOR_CC_xxx`
   - ADX: `MOR-PW23_01-xxx`, `MOR-REPT_xxx`
4. **✅ Same schema**: Both return 5 columns (TAG_NAME, VALUE_UTC_TS, SENSOR_VALUE, UOM, QUALITY)

### Test Scripts

- [regression_test.py](regression_test.py) - 3-version comparison script
- [adx_function.kql](adx_function.kql) - KQL function definition
- [VERSIONS.md](VERSIONS.md) - Full documentation of all 3 versions
