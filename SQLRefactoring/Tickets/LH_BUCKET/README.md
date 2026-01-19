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
| Testing the Procedure | ⬜ Pending |
| Schedule task (every 15 min) | ⬜ Pending |

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

## Progress Log
| Date | Update |
|------|--------|
| 2026-01-19 | Ticket created |
| 2026-01-19 | Metadata extracted from Snowflake |
| 2026-01-19 | CT table and procedure DDL completed |
