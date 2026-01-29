# DRILLBLAST INCR Pipeline - Fixes Applied

## Date: 2026-01-28
## Author: Carlos Carrillo

---

## Summary

All 14 Snowflake INCR procedures have been fixed and tested successfully in DEV environment.

## E2E Test Results

| # | Procedure | Status | Records Merged |
|---|-----------|--------|----------------|
| 1 | BL_DW_BLAST_INCR_P | ✅ PASS | 0 |
| 2 | BL_DW_BLASTPROPERTYVALUE_INCR_P | ✅ PASS | 0 |
| 3 | BL_DW_HOLE_INCR_P | ✅ PASS | 6,756 |
| 4 | BLAST_PLAN_INCR_P | ✅ PASS | 45,492 |
| 5 | BLAST_PLAN_EXECUTION_INCR_P | ✅ PASS | 154,869 |
| 6 | DRILL_CYCLE_INCR_P | ✅ PASS | 4,157 |
| 7 | DRILL_PLAN_INCR_P | ✅ PASS | 3,781 |
| 8 | DRILLBLAST_EQUIPMENT_INCR_P | ✅ PASS | 0 |
| 9 | DRILLBLAST_OPERATOR_INCR_P | ✅ PASS | 0 |
| 10 | DRILLBLAST_SHIFT_INCR_P | ✅ PASS | 0 |
| 11 | LH_BUCKET_INCR_P | ✅ PASS | 0 |
| 12 | LH_EQUIPMENT_STATUS_EVENT_INCR_P | ✅ PASS | 20 |
| 13 | LH_HAUL_CYCLE_INCR_P | ✅ PASS | 0 |
| 14 | LH_LOADING_CYCLE_INCR_P | ✅ PASS | 4 |

**Total: 14/14 PASSED**

---

## Fixes Applied

### 1. BLAST_PLAN_INCR_P (Previously failing with "invalid identifier 'BLAST_STATUS'")

**Root Cause**: Procedure referenced columns that don't exist in source table:
- `BLAST_STATUS` ❌
- `EXPECTED_TONS` ❌
- `EXPECTED_BCM` ❌
- `DRILLED_HOLE_COUNT` ❌
- `SYSTEM_VERSION` ❌

**Fix Applied**:
- Simplified MERGE to use only columns that exist in both source and target
- Removed HASH comparison (now uses `WHEN MATCHED` directly)
- Changed DELETE/MERGE WHERE clause to use `DW_MODIFY_TS` instead of `BLAST_DT`

### 2. DRILL_CYCLE_INCR_P (Previously failing with "invalid identifier 'CYCLE_START_TS_LOCAL'")

**Root Cause**: `CYCLE_START_TS_LOCAL` doesn't exist in source table

**Fix Applied**:
- Changed DELETE WHERE clause: `CYCLE_START_TS_LOCAL` → `DW_MODIFY_TS`
- Changed MERGE WHERE clause: `CYCLE_START_TS_LOCAL` → `DW_MODIFY_TS`

### 3. DRILL_PLAN_INCR_P (Previously failing with "invalid identifier 'PLAN_DATE'")

**Root Cause**: `PLAN_DATE` doesn't exist in source table

**Fix Applied**:
- Changed DELETE WHERE clause: `PLAN_DATE` → `DW_MODIFY_TS`
- Changed MERGE WHERE clause: `PLAN_DATE` → `DW_MODIFY_TS`

### 4. BLAST_PLAN_EXECUTION_INCR_P (Previously failing with "NULL result in non-nullable column BENCH")

**Root Cause**: 
- Source table has NULL values in BENCH (227 rows), PATTERN_NAME (93,365 rows - 60%!)
- These columns are part of the PRIMARY KEY constraint
- PK columns cannot be NULL in Snowflake

**Fix Applied**:
- Added COALESCE in SELECT to convert NULLs to sentinel values:
  - `COALESCE(BENCH, -999999)` 
  - `COALESCE(PUSHBACK, 'N/A')`
  - `COALESCE(PATTERN_NAME, 'N/A')`
- Updated PARTITION BY clause to use same COALESCE logic for deduplication
- Simplified ON clause (no longer needs COALESCE since source already handles it)

---

## Files Modified

### Snowflake Procedures (DDL-Scripts/API_REF/FUSE/PROCEDURES/)
1. `R__BLAST_PLAN_INCR_P.sql`
2. `R__DRILL_CYCLE_INCR_P.sql`
3. `R__DRILL_PLAN_INCR_P.sql`
4. `R__BLAST_PLAN_EXECUTION_INCR_P.sql`

### DEV Deployed Versions (DEPLOY_DEV/PROCEDURES/)
Same 4 files - already deployed and tested in DEV_API_REF.FUSE

---

## Key Technical Findings

1. **Source Tables Only Have DW_MODIFY_TS**: The business timestamp columns (BLAST_DT, CYCLE_START_TS_LOCAL, PLAN_DATE) do NOT exist in PROD_WG.DRILL_BLAST.* source tables. All procedures must use `DW_MODIFY_TS` for incremental logic.

2. **BLAST_PLAN Column Mismatch**: Many columns in the original procedure don't exist in the actual BLAST_PLAN table. The procedure was simplified to use only verified columns.

3. **Primary Key Constraint Issue**: BLAST_PLAN_EXECUTION_INCR has a composite PK including BENCH, PUSHBACK, PATTERN_NAME. Since source has NULL values, we must use COALESCE to provide default values.

---

## Deployment Instructions

### DEV (Already Done)
```bash
py -3.12 test_all_pipelines_e2e.py
```

### TEST
1. Run the Jinja renderer with `envi=TEST`
2. Deploy tables and procedures to TEST_API_REF.FUSE
3. Run E2E test

### PROD
1. Run the Jinja renderer with `envi=PROD`
2. Deploy tables and procedures to PROD_API_REF.FUSE
3. Run E2E test

---

## SQL Server Archival Procedures

**Note**: The SQL Server archival procedures also need the same DW_MODIFY_TS fix for:
- `usp_Archive_BLAST_PLAN_INCR.sql`
- `usp_Archive_DRILL_CYCLE_INCR.sql`
- `usp_Archive_DRILL_PLAN_INCR.sql`

These were not fixed in this session but follow the same pattern.
