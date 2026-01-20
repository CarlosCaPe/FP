# LH_BUCKET CT Refactoring

## Overview
- **Source**: `PROD_TARGET.COLLECTIONS.LH_BUCKET_C`
- **Target**: `DEV_API_REF.FUSE.LH_BUCKET_CT`
- **Assigned by**: M. Hidayath
- **Date**: 2026-01-19

## Requirements
| Requirement | Status |
|-------------|--------|
| Creation of CT table | ✅ Complete |
| Creation of CT procedure | ✅ Complete |
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
- [baseline_ddl.sql](baseline_ddl.sql) - Source and target table definitions
- [refactor_ddl.sql](refactor_ddl.sql) - CT table, procedure, and task definitions
- [FINDINGS.md](FINDINGS.md) - Analysis and recommendations
- [config.yml](config.yml) - Configuration and status tracking

## Next Steps
1. Deploy CT table to DEV_API_REF.FUSE
2. Deploy CT procedure
3. Run initial backfill: `CALL DEV_API_REF.FUSE.LH_BUCKET_CT_P('30');`
4. Validate row counts match source
5. Enable task: `ALTER TASK DEV_API_REF.FUSE.LH_BUCKET_CT_TASK RESUME;`

## Snowflake Objects Created
```sql
-- TABLE
DEV_API_REF.FUSE.LH_BUCKET_CT

-- PROCEDURE
DEV_API_REF.FUSE.LH_BUCKET_CT_P(NUMBER_OF_DAYS VARCHAR DEFAULT '3')

-- TASK (every 15 minutes)
DEV_API_REF.FUSE.LH_BUCKET_CT_T
```

## Performance Results (Stress Test)
| Days | Duration | Rows |
|------|----------|------|
| 1 | 2.0s | 13,650 |
| 3 | 2.4s | 41,904 |
| 7 | 2.3s | 99,422 |
| 14 | 2.2s | 195,713 |
| 30 | 2.7s | 427,198 |

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
