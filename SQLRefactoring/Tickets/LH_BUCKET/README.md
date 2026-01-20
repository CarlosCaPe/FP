# LH_BUCKET INCR Refactoring

## Overview
- **Source**: `PROD_WG.LOAD_HAUL.LH_BUCKET` (VIEW)
- **Target**: `DEV_API_REF.FUSE.LH_BUCKET_INCR`
- **Assigned by**: M. Hidayath
- **Date**: 2026-01-20

## ⚠️ UPDATED: Source Changed
Per Hidayath's feedback (2026-01-20):
- **Old source**: `PROD_TARGET.COLLECTIONS.LH_BUCKET_C` (table)
- **New source**: `PROD_WG.LOAD_HAUL.LH_BUCKET` (VIEW)
- **Old naming**: `_CT` → **New naming**: `_INCR`
- **Column change**: `EXCAV_ID` → `LH_EQUIP_ID` (per VIEW structure)

## Requirements
| Requirement | Status |
|-------------|--------|
| Creation of INCR table | ✅ Complete |
| Creation of INCR procedure | ✅ Complete |
| Testing the Procedure | ✅ Complete |
| Schedule task (every 15 min) | ✅ Complete |

## Parameters
- **Business Key**: `BUCKET_ID`
- **Incremental Column**: `TRIP_TS_LOCAL`
- **Incremental window**: 3 days
- **Task frequency**: Every 15 minutes

## Reference
- Reference procedure: `DEV_API_REF.FUSE.DRILLBLAST_DRILL_CYCLE_CT_P`
- Pattern: MERGE-driven upserts with hash-based conditional updates
- Language: JavaScript stored procedure

## Upstream Dependencies
- `LH_BUCKET_C` → `PROD_TARGET.COLLECTIONS` (source table)

## Downstream Dependencies
- `LH_LOADING_CYCLE_CT` depends on `LOADING_CYCLE_ID` from this table

## Files
- [refactor_ddl_v2.sql](refactor_ddl_v2.sql) - **CURRENT**: INCR table, procedure, task (using VIEW source)
- [refactor_ddl.sql](refactor_ddl.sql) - Deprecated: CT version using _C table
- [FINDINGS.md](FINDINGS.md) - Analysis and recommendations
- [config.yml](config.yml) - Configuration and status tracking

## Snowflake Objects Created
```sql
-- TABLE
DEV_API_REF.FUSE.LH_BUCKET_INCR

-- PROCEDURE
DEV_API_REF.FUSE.LH_BUCKET_INCR_P(NUMBER_OF_DAYS VARCHAR DEFAULT '3')

-- TASK (every 15 minutes)
DEV_API_REF.FUSE.LH_BUCKET_INCR_T
```

## Performance Results (Stress Test)
| Days | Duration | Rows |
|------|----------|------|
| 3 | ~30s | 53,589 |

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
| 2026-01-19 | CT table, procedure, and task deployed |
| 2026-01-19 | Stress testing completed (1-90 days) |
| 2026-01-19 | Task enabled and running |
| 2026-01-19 | Metadata extracted from Snowflake |
| 2026-01-19 | CT table and procedure DDL completed |
