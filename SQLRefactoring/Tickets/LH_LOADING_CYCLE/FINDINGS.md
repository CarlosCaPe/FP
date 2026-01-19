# LH_LOADING_CYCLE Findings

## Analysis Date
2026-01-19

## Source Investigation
- [x] Identify business keys: **LOADING_CYCLE_ID**
- [x] Identify timestamp columns for incremental logic: **CYCLE_START_TS_LOCAL**
- [x] Review upstream dependencies: `PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C`
- [x] Check current refresh patterns: Existing procs `DISPATCH_LH_LOADING_CYCLE_C_P`, `FLEET_LH_LOADING_CYCLE_C_P`

## Schema Analysis

### Source: `PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C`
- **Type**: TRANSIENT TABLE
- **Clustering**: `(ORIG_SRC_ID, SITE_CODE, SHIFT_ID)`
- **Columns**: 33 columns

### Key Columns
| Column | Type | Purpose |
|--------|------|--------|
| LOADING_CYCLE_ID | NUMBER(19,0) | **Business Key** |
| CYCLE_START_TS_LOCAL | TIMESTAMP_NTZ(3) | **Incremental filter** |
| SHIFT_ID | VARCHAR(12) | Part of clustering key |
| EXCAV_ID | NUMBER(19,0) | Equipment FK |
| TRUCK_ID | NUMBER(19,0) | Equipment FK |
| HAUL_CYCLE_ID | NUMBER(19,0) | FK to haul cycle |
| DW_LOGICAL_DELETE_FLAG | VARCHAR(1) | Soft delete marker |

### Target Differences (PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE)
- Missing `EXCAV`, `TRUCK` VARCHAR columns
- Has `LOADING_CYCLE_DIG_ELEV_AVG_FEET`, `LOADING_CYCLE_DIG_ELEV_AVG_METERS` instead
- Missing `DW_LOGICAL_DELETE_FLAG`

## Dependency Notes
- **LH_BUCKET** references this via `LOADING_CYCLE_ID`
- Should be loaded AFTER LH_BUCKET_CT is complete (per diagram dependency)

## Performance Observations
- Source clustered on `SHIFT_ID` (not date-based) - may need different incremental strategy
- Using `CYCLE_START_TS_LOCAL::DATE` for date-range filtering

## Recommendations
1. Use LOADING_CYCLE_ID as sole business key for MERGE
2. Filter on `CYCLE_START_TS_LOCAL::DATE` for incremental loads
3. Include `DW_LOGICAL_DELETE_FLAG` in CT table for soft deletes
4. Hash-based update detection on all non-key columns
