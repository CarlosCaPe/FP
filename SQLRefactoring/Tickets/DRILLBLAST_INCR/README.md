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

### Pre-Deployment Validation (REQUIRED)

```powershell
# Run naming convention validator BEFORE deploying
cd C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR
py -3.12 validate_naming.py
```

This will catch any naming convention issues (like SP_ prefix instead of _P suffix) BEFORE deployment.

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

### Post-Deployment Verification (REQUIRED)

```powershell
# Run this to verify all 22 objects exist with correct names
cd C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR
py -3.12 verify_all_objects.py
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

## ⚠️ NAMING CONVENTIONS (CRITICAL)

> **Lesson Learned (2026-01-23):** Deployment failed because 4 SQL files had incorrect procedure names with `SP_` prefix instead of `_P` suffix. This caused Vikas's Function Apps to fail finding the expected procedures.

### Required Naming Pattern

| Object Type | Pattern | Example |
|-------------|---------|---------|
| Tables | `{NAME}_INCR` | `BLAST_PLAN_INCR` |
| Procedures | `{NAME}_INCR_P` | `BLAST_PLAN_INCR_P(VARCHAR DEFAULT '3')` |

### ❌ INCORRECT (Do NOT use)
```sql
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.SP_BLAST_PLAN_INCR(...)  -- WRONG: SP_ prefix
```

### ✅ CORRECT (Always use this)
```sql
CREATE OR REPLACE PROCEDURE DEV_API_REF.FUSE.BLAST_PLAN_INCR_P(...)  -- CORRECT: _P suffix
```

### Deployment Checklist

Before deploying to Snowflake, verify:

- [ ] **All procedures end with `_P` suffix** (not `SP_` prefix)
- [ ] **Parameter signature matches**: `(VARCHAR DEFAULT '3')`
- [ ] **Run `verify_all_objects.py`** to confirm all 22 objects exist with correct names
- [ ] **Test each procedure** with: `CALL DEV_API_REF.FUSE.{NAME}_INCR_P('3');`

### Expected Objects (Reference for Vikas's Function Apps)

```
Tables (11):
  DEV_API_REF.FUSE.BL_DW_BLAST_INCR
  DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR
  DEV_API_REF.FUSE.BL_DW_HOLE_INCR
  DEV_API_REF.FUSE.BLAST_PLAN_INCR
  DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR
  DEV_API_REF.FUSE.DRILL_CYCLE_INCR
  DEV_API_REF.FUSE.DRILL_PLAN_INCR
  DEV_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR
  DEV_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR
  DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR
  DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR

Procedures (11):
  DEV_API_REF.FUSE.BL_DW_BLAST_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.BL_DW_BLASTPROPERTYVALUE_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.BL_DW_HOLE_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.BLAST_PLAN_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.DRILL_PLAN_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.DRILLBLAST_EQUIPMENT_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.DRILLBLAST_OPERATOR_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.DRILLBLAST_SHIFT_INCR_P(VARCHAR DEFAULT '3')
  DEV_API_REF.FUSE.LH_HAUL_CYCLE_INCR_P(VARCHAR DEFAULT '3')
```

---
*Created: 2026-01-23 | Updated: 2026-01-26 | Author: Carlos Carrillo*

---

## 🐛 Known Issues & Fixes

### Issue: BLAST_PLAN_EXECUTION_INCR_P - Duplicate Row Error (2026-01-26)

**Symptom:** Procedure fails with error:
```
Execution error in store procedure BLAST_PLAN_EXECUTION_INCR_P
Duplicate row detected during DML action
nRow Values: [443, "MOR", 4700, "SHA", ...]
```

**Root Cause:** The source table `PROD_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION` contains duplicate rows for the same composite business key (`ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID`). Snowflake MERGE statements fail when the source contains multiple rows that match the same target key.

**Fixes Applied:**
1. **Added `QUALIFY ROW_NUMBER()` clause** to the source query in the MERGE statement to deduplicate rows, keeping only the latest record per business key based on `DW_MODIFY_TS`.
2. **Changed procedure signature** from `(P_DAYS_BACK FLOAT, P_MAX_DAYS FLOAT)` to `("NUMBER_OF_DAYS" VARCHAR)` for API compatibility with Vikas's Function Apps.
3. **Simplified JavaScript** to match the pattern used in other INCR procedures.
4. **Added COALESCE for NULL-safe joins** on PUSHBACK and PATTERN_NAME columns to prevent duplicate inserts when these fields are NULL.

```sql
-- Fix 1: Deduplicate source
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID
    ORDER BY DW_MODIFY_TS DESC NULLS LAST
) = 1

-- Fix 4: NULL-safe joins
AND COALESCE(tgt.PUSHBACK, '') = COALESCE(src.PUSHBACK, '')
AND COALESCE(tgt.PATTERN_NAME, '') = COALESCE(src.PATTERN_NAME, '')
```

**Test Result (2026-01-26):**
```
SUCCESS: Merged 150,751 records, Soft deleted 230 records
No duplicates found on business key ✅
```

**Important:** When creating new INCR procedures, always consider adding `QUALIFY` deduplication if the source table may have duplicate business keys.
---

## ADO Deployment Standards (MANDATORY)

### Folder Structure for Snowflake_NA Repository

All DDL scripts for ADO deployment **MUST** follow this structure:

```
DDL-Scripts/
  API_REF/
    FUSE/
      TABLES/
        R__<TABLE_NAME>.sql
      PROCEDURES/
        R__<PROCEDURE_NAME>.sql
```

### File Naming Convention

- Prefix: `R__` (double underscore)
- Name: Exact object name in uppercase
- Extension: `.sql`
- Example: `R__BLAST_PLAN_EXECUTION_INCR.sql`, `R__BLAST_PLAN_EXECUTION_INCR_P.sql`

### CREATE Statement Format (CRITICAL)

**ALL CREATE statements MUST include full qualified name with Jinja2 template:**

```sql
-- Tables
create or replace TABLE {{ envi }}_API_REF.FUSE.<TABLE_NAME> (
    ...
);

-- Procedures
CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.<PROCEDURE_NAME>(...)
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
...
```

### Template Variables (Jinja2)

| Variable | Purpose | Replaced by ADO Pipeline |
|----------|---------|--------------------------|
| `{{ envi }}` | Target environment | DEV, TEST, PROD |
| `{{ RO_PROD }}` | Read-only PROD source | Always PROD |
| `{{ RO_DEV }}` | Read-only DEV source | Always DEV |
| `{{ RO_TEST }}` | Read-only TEST source | Always TEST |

### Example Usage

```sql
-- Target table (environment-dependent)
SELECT * FROM {{ envi }}_API_REF.FUSE.BLAST_PLAN_EXECUTION_INCR;

-- Source table (always read from PROD)
SELECT * FROM {{ RO_PROD }}_WG.DRILL_BLAST.BLAST_PLAN_EXECUTION;
```

### Generation Script

Use `split_ddl_for_ado.py` to generate ADO-compatible DDL files:

```powershell
cd C:\Users\ccarrill2\Documents\repos\FP\SQLRefactoring\Tickets\DRILLBLAST_INCR
py -3.12 split_ddl_for_ado.py
```

This script:
1. Extracts DDL from Snowflake using `GET_DDL()`
2. Replaces hardcoded database names with `{{ envi }}` template
3. Replaces `PROD_WG` with `{{ RO_PROD }}_WG`
4. Adds full qualified name to CREATE statements
5. Splits into individual files per object

### Validation Checklist Before Sending to ADO

- [ ] File names start with `R__`
- [ ] CREATE statements include `{{ envi }}_API_REF.FUSE.<NAME>`
- [ ] Source references use `{{ RO_PROD }}_WG` (not hardcoded PROD_WG)
- [ ] No hardcoded DEV_API_REF, TEST_API_REF, or PROD_API_REF
- [ ] Files are in correct folder: TABLES/ or PROCEDURES/

---