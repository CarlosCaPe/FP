# LH_LOADING_CYCLE INCR Refactoring

## Overview
- **Source**: `PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE` (VIEW)
- **Target**: `DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR`
- **Assigned by**: M. Hidayath
- **Date**: 2026-01-20

## ⚠️ UPDATED: Source Changed
Per Hidayath's feedback (2026-01-20):
- **Old source**: `PROD_TARGET.COLLECTIONS.LH_LOADING_CYCLE_C` (table)
- **New source**: `PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE` (VIEW)
- **Old naming**: `_CT` → **New naming**: `_INCR`

## Requirements
| Requirement | Status |
|-------------|--------|
| Creation of INCR table | ✅ Complete |
| Creation of INCR procedure | ✅ Complete |
| Testing the Procedure | ✅ Complete |
| Schedule task (every 15 min) | ✅ Complete |

## Parameters
- **Business Key**: `LOADING_CYCLE_ID`
- **Incremental Column**: `CYCLE_START_TS_LOCAL`
- **Incremental window**: 3 days
- **Task frequency**: Every 15 minutes

## Reference
- Reference procedure: `DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P`
- Pattern: MERGE-driven upserts with hash-based conditional updates
- Language: JavaScript stored procedure

## Upstream Dependencies
- `LH_LOADING_CYCLE_C` → `PROD_TARGET.COLLECTIONS` (source table)
- `LH_BUCKET_CT` should be deployed first (LH_BUCKET references LOADING_CYCLE_ID)

## Files
- [refactor_ddl_v2.sql](refactor_ddl_v2.sql) - **CURRENT**: INCR table, procedure, task (using VIEW source)
- [refactor_ddl.sql](refactor_ddl.sql) - Deprecated: CT version using _C table
- [FINDINGS.md](FINDINGS.md) - Analysis and recommendations
- [config.yml](config.yml) - Configuration and status tracking

## Progress Log
| Date | Update |
|------|--------|
| 2026-01-19 | Ticket created |
| 2026-01-19 | CT table and procedure DDL completed (using _C table) |
| 2026-01-20 | **Source changed**: Now using `PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE` VIEW |
| 2026-01-20 | **Renamed**: `_CT` → `_INCR` per Hidayath |
| 2026-01-20 | INCR table, procedure, and task deployed |
| 2026-01-20 | Stress testing completed (1-90 days) |
| 2026-01-20 | Task enabled and running |

## Snowflake Objects Created
```sql
-- TABLE
DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR

-- PROCEDURE
DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_P(NUMBER_OF_DAYS VARCHAR DEFAULT '3')

-- TASK (every 15 minutes)
DEV_API_REF.FUSE.LH_LOADING_CYCLE_INCR_T
```

## Performance Results (Stress Test)
| Days | Duration | Rows |
|------|----------|------|
| 1 | 58.96s | 17,756 |
| 3 | 93.09s | 39,906 |
| 7 | 47.47s | 79,350 |
| 14 | 82.07s | 158,137 |
| 30 | 228.93s | 344,866 |
| 60 | 85.82s | 692,830 |
| 90 | 73.61s | 1,051,443 |

## What is a CT (Change Tracking) Table?

| Characteristic | Regular Table | CT Table |
|----------------|---------------|----------|
| **Purpose** | Store data | Track **changes** for sync |
| **Extra columns** | No | `DW_LOGICAL_DELETE_FLAG`, `DW_LOAD_TS`, `DW_MODIFY_TS` |
| **Soft deletes** | Physical DELETE | Flag `'Y'` (record stays) |
| **Updates** | Manual/batch | Task every **15 min** |
| **Change detection** | None | **HASH()** src vs tgt |

## Progress Log
| Date | Update |
|------|--------|
| 2026-01-19 | Ticket created |
| 2026-01-19 | Metadata extracted from Snowflake |
| 2026-01-19 | CT table and procedure DDL completed |
| 2026-01-19 | CT table, procedure, and task deployed |
| 2026-01-19 | Stress testing completed (1-90 days) |
| 2026-01-19 | Task enabled and running |
