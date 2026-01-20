# LH_BUCKET Findings

## Analysis Date
2026-01-19

## Source Investigation
- [x] Identify business keys: **BUCKET_ID**
- [x] Identify timestamp columns for incremental logic: **TRIP_TS_LOCAL**
- [x] Review upstream dependencies: `PROD_TARGET.COLLECTIONS.LH_BUCKET_C`
- [x] Check current refresh patterns: Existing procs `DISPATCH_LH_BUCKET_C_P`, `FLEET_LH_BUCKET_C_P`

## Schema Analysis

### Source: `PROD_TARGET.COLLECTIONS.LH_BUCKET_C`
- **Type**: TRANSIENT TABLE
- **Clustering**: `(ORIG_SRC_ID, SITE_CODE, TRIP_TS_LOCAL::DATE)`
- **Row Count**: ~335M+ rows (based on sample BUCKET_IDs)
- **Columns**: 40 columns

### Key Columns
| Column | Type | Purpose |
|--------|------|--------|
| BUCKET_ID | NUMBER(19,0) | **Business Key** |
| TRIP_TS_LOCAL | TIMESTAMP_NTZ(3) | **Incremental filter** |
| LOADING_CYCLE_ID | NUMBER(19,0) | FK to LH_LOADING_CYCLE |
| EXCAV_ID | VARCHAR(30) | Equipment identifier |
| DW_LOGICAL_DELETE_FLAG | VARCHAR(1) | Soft delete marker |

### Target Differences (PROD_WG.LOAD_HAUL.LH_BUCKET)
- Uses `LH_EQUIP_ID` (NUMBER) instead of `EXCAV_ID` (VARCHAR)
- Missing `BUCKET_MATERIAL_ID` and `DW_LOGICAL_DELETE_FLAG`

## Performance Observations
- Source clustered on `TRIP_TS_LOCAL::DATE` enables efficient micro-partition pruning
- Existing procs use 8-parameter signature (legacy ETL pattern)

## Recommendations
1. Use BUCKET_ID as sole business key for MERGE
2. Filter on `TRIP_TS_LOCAL::DATE` for incremental loads (matches clustering)
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
LH_BUCKET_C                             LH_BUCKET_CT
                                              ↓
                                     DW_MODIFY_TS > last_sync
                                     (only sends changes)
```
