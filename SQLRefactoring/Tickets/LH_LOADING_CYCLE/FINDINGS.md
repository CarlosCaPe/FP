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

## What is a CT (Change Tracking) Table?

| Characteristic | Regular Table | CT Table |
|----------------|---------------|----------|
| **Purpose** | Store data | Track **changes** for synchronization |
| **Extra columns** | No | `DW_LOGICAL_DELETE_FLAG`, `DW_LOAD_TS`, `DW_MODIFY_TS` |
| **Soft deletes** | Physical DELETE | Flag `'Y'` (record stays for sync) |
| **Updates** | Manual/batch ETL | Automated task every **15 min** |
| **History** | Full window | Rolling **N days** only |
| **Change detection** | None | **HASH()** compares src vs tgt |

### Key CT Columns:
```sql
DW_LOGICAL_DELETE_FLAG  VARCHAR(1)    -- 'N' = active, 'Y' = deleted (soft delete)
DW_LOAD_TS              TIMESTAMP     -- When record was inserted
DW_MODIFY_TS            TIMESTAMP     -- When record was last modified
```

### Data Flow:
```
[Source Table]  →  MERGE (every 15min)  →  [CT Table]  →  SYNC via IROC  →  [SQL Server]
     ↓                                         ↓
LH_LOADING_CYCLE_C                      LH_LOADING_CYCLE_CT
                                              ↓
                                     DW_MODIFY_TS > last_sync
                                     (only sends changes)
```
