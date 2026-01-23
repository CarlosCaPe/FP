# DRILLBLAST_INCR - Incremental Tables for IROC Project

## Overview

This folder contains DDL scripts to create incremental (_INCR) tables and stored procedures for the IROC project. These tables sync data from Snowflake to SQL Azure using a high watermark strategy.

## Pattern

Following the pattern established by Hidayath for `DRILLBLAST_DRILL_CYCLE_CT_P`:

- **Suffix**: `_INCR` (not `_CT` per Vikas)
- **Objects**: TABLE + PROCEDURE only (no TASK per Vikas)
- **Target Schema**: `DEV_API_REF.FUSE`
- **Merge Strategy**: HASH-based conditional updates
- **Incremental Window**: 3 days (default), max 30 days
- **Soft Deletes**: `DW_LOGICAL_DELETE_FLAG = 'Y'`

## Tables to Create

| # | Table Name | Source Path | Primary Key | Max Rows (30d) | Status |
|---|------------|-------------|-------------|----------------|--------|
| 1 | **LH_HAUL_CYCLE_INCR** | PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE | HAUL_CYCLE_ID | 528,156 | ✅ Verified |
| 2 | BL_DW_BLAST_INCR | PROD_WG.DRILL_BLAST.BL_DW_BLAST | ORIG_SRC_ID, SITE_CODE, ID | 84 | ✅ Verified |
| 3 | BL_DW_BLASTPROPERTYVALUE_INCR | PROD_WG.DRILL_BLAST.BL_DW_BLASTPROPERTYVALUE | ORIG_SRC_ID, SITE_CODE, BLASTID | 84 | ✅ Verified |
| 4 | BL_DW_HOLE_INCR | PROD_WG.DRILL_BLAST.BL_DW_HOLE | ORIG_SRC_ID, SITE_CODE, ID | 20,945 | ✅ Verified |
| 5 | BLAST_PLAN_INCR | PROD_WG.DRILL_BLAST.BLAST_PLAN | BLAST_PLAN_SK | 39,277 | ✅ Verified |
| 6 | BLAST_PLAN_EXECUTION_INCR | PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION | Composite (7 cols) | 149,489 | ✅ Verified |
| 7 | DRILL_CYCLE_INCR | PROD_WG.DRILL_BLAST.DRILL_CYCLE | DRILL_CYCLE_SK | 45,985 | ✅ Verified |
| 8 | DRILL_PLAN_INCR | PROD_WG.DRILL_BLAST.DRILL_PLAN | DRILL_PLAN_SK | 56,723 | ✅ Verified |
| 9 | DRILLBLAST_EQUIPMENT_INCR | PROD_WG.DRILL_BLAST.DRILLBLAST_EQUIPMENT | ORIG_SRC_ID, SITE_CODE, DRILL_ID | 62 | ✅ Verified |
| 10 | DRILLBLAST_OPERATOR_INCR | PROD_WG.DRILL_BLAST.DRILLBLAST_OPERATOR | SYSTEM_OPERATOR_ID, SITE_CODE | 5,263 | ✅ Verified |
| 11 | DRILLBLAST_SHIFT_INCR | PROD_WG.DRILL_BLAST.DRILLBLAST_SHIFT | SITE_CODE, SHIFT_ID | 30,390 | ✅ Verified |

**Total Verified: 11/11 tables ✅ (Stress test 2026-01-23)**

## Files

| File | Description |
|------|-------------|
| `LH_HAUL_CYCLE_INCR.sql` | First priority - Haul cycle data (340+ columns) |
| `BL_DW_BLAST_INCR.sql` | Blast data (18 columns) |
| `BL_DW_BLASTPROPERTYVALUE_INCR.sql` | Blast property values (13 columns) |
| `BL_DW_HOLE_INCR.sql` | Drill hole details (72 columns) |
| `BLAST_PLAN_INCR.sql` | Blast planning data (66 columns) |
| `BLAST_PLAN_EXECUTION_INCR.sql` | Blast execution data (61 columns) |
| `DRILL_CYCLE_INCR.sql` | Drill cycle data (107 columns) |
| `DRILL_PLAN_INCR.sql` | Drill plan data (40 columns) |
| `DRILLBLAST_EQUIPMENT_INCR.sql` | Equipment master data (14 columns) |
| `DRILLBLAST_OPERATOR_INCR.sql` | Operator master data (14 columns) |
| `DRILLBLAST_SHIFT_INCR.sql` | Shift definitions (17 columns) |
| `generate_incr_ddl.py` | Python script to generate DDL for all tables |

## Usage

### Deploy to Snowflake

```sql
-- Run the DDL in Snowflake
-- Step 1: Create the INCR table
-- Step 2: Create the INCR procedure
-- Step 3: Initial load with 30-day lookback
CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('30');

-- Step 4: Verify data
SELECT COUNT(*) FROM DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR;
```

### Regular Refresh

```sql
-- Called by task or manually every 15 minutes
CALL DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P('3');
```

### Generate DDL for All Tables

```powershell
cd C:\Users\Lenovo\dataqbs\FP
.\.venv\Scripts\python.exe SQLRefactoring\Tickets\generate_incr_ddl.py
```

## Procedure Logic

1. **Count** records outside the lookback window
2. **Delete** old records from INCR table (sliding window)
3. **MERGE** new/updated records using HASH comparison
4. **Soft Delete** records no longer in source (DW_LOGICAL_DELETE_FLAG = 'Y')

## Audit Columns

All INCR tables include:

| Column | Type | Description |
|--------|------|-------------|
| DW_LOGICAL_DELETE_FLAG | VARCHAR(1) | 'N' = active, 'Y' = deleted |
| DW_LOAD_TS | TIMESTAMP_NTZ | First load timestamp |
| DW_MODIFY_TS | TIMESTAMP_NTZ | Last update timestamp |

## Notes

- LH_HAUL_CYCLE has 340+ columns - DDL shows key columns, full list needed for production
- Use `INFORMATION_SCHEMA.COLUMNS` to extract full column list from source views
- No TASK objects - Vikas confirmed tasks are not needed

## Related

- Pattern reference: `LH_BUCKET/refactor_ddl_v2.sql`
- Pattern reference: `LH_LOADING_CYCLE/refactor_ddl_v2.sql`
- Original pattern: Hidayath's `DRILLBLAST_DRILL_CYCLE_CT_P`

---
*Created: 2026-01-23 | Author: Carlos Carrillo*
