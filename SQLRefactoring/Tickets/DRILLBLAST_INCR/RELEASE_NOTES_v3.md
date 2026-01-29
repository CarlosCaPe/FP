# DRILLBLAST INCR Pipeline - Release Notes v3

## 📦 Artifact: DDL-Scripts-FINAL-2026-01-29-v3.zip

| Info | Value |
|------|-------|
| **Version** | 3.0 |
| **Release Date** | 2026-01-29 |
| **Author** | Carlos Carrillo |
| **Size** | 65 KB |
| **Files** | 56 SQL scripts |

---

## 🔴 CRITICAL FIXES

### Issue: Missing Columns in INSERT/UPDATE Statements

**SEVERITY: CRITICAL**

Several procedures were discovered to have incomplete column coverage, causing data loss in the INCR tables.

### Procedures Fixed

| Procedure | Before | After | Columns Added |
|-----------|--------|-------|---------------|
| **DRILL_CYCLE_INCR_P** | 29 | 108 | +79 columns |
| **BLAST_PLAN_INCR_P** | 11 | 67 | +56 columns |
| **BL_DW_HOLE_INCR_P** | 16 | 74 | +58 columns |
| **DRILL_PLAN_INCR_P** | 33 | 41 | +8 columns |

### Root Cause

Procedures were created with arbitrary column subsets instead of including ALL columns from the source tables. This resulted in:
- NULL values in omitted columns
- Data integrity violations
- Missing critical operational data

### Resolution

All 14 procedures now have **COMPLETE** column coverage:

| # | Pipeline | Table Cols | INSERT Cols | ✓ |
|---|----------|------------|-------------|---|
| 1 | BL_DW_BLAST_INCR | 19 | 19 | ✅ |
| 2 | BL_DW_BLASTPROPERTYVALUE_INCR | 13 | 13 | ✅ |
| 3 | BL_DW_HOLE_INCR | 74 | 74 | ✅ |
| 4 | BLAST_PLAN_INCR | 66 | 67 | ✅ |
| 5 | BLAST_PLAN_EXECUTION_INCR | 62 | 62 | ✅ |
| 6 | DRILL_CYCLE_INCR | 108 | 108 | ✅ |
| 7 | DRILL_PLAN_INCR | 40 | 41 | ✅ |
| 8 | DRILLBLAST_EQUIPMENT_INCR | 14 | 14 | ✅ |
| 9 | DRILLBLAST_OPERATOR_INCR | 14 | 14 | ✅ |
| 10 | DRILLBLAST_SHIFT_INCR | 16 | 17 | ✅ |
| 11 | LH_BUCKET_INCR | 39 | 39 | ✅ |
| 12 | LH_EQUIPMENT_STATUS_EVENT_INCR | 21 | 21 | ✅ |
| 13 | LH_HAUL_CYCLE_INCR | 68 | 68 | ✅ |
| 14 | LH_LOADING_CYCLE_INCR | 33 | 33 | ✅ |

---

## 📋 Changes Included (vs v2)

### Snowflake Procedures

1. **R__DRILL_CYCLE_INCR_P.sql**
   - Added 79 missing columns including:
     - OPERATOR_LOGIN/LOGOUT timestamps (UTC & LOCAL)
     - PROPEL_START/END timestamps
     - PARK_POSITION timestamps
     - LEVEL_START/END timestamps
     - DRILL_START/END timestamps
     - RETRACT_START/END timestamps
     - MWD columns: AIR_PRESSURE_PSI, FEED_FORCE_NEWTONS, etc.
     - GPS_ACCURACY, BEARING, etc.
   - Complete UPDATE SET clause with all 104 non-key columns

2. **R__BLAST_PLAN_INCR_P.sql**
   - Added 56 missing columns including:
     - PLAN_CREATION_TS_UTC/LOCAL
     - DESIGN_BY, DRILL_CYCLE_SK, BLAST_ID
     - All EXPLOSIVE_PRODUCT_* columns
     - All STEMMING_LENGTH_* columns
     - All AIR_* columns
     - BURDEN, SPACING, TONS_PER_HOLE
     - KCALS_PER_TON, POWDER_FACTOR, etc.
   - Changed filter from DW_MODIFY_TS to PLAN_CREATION_TS_LOCAL

3. **R__BL_DW_HOLE_INCR_P.sql**
   - Added 58 missing columns including:
     - All temperature columns
     - All design columns (DESIGNCOLLAR*, DESIGNANGLE, etc.)
     - All actual columns (ACTUALCOLLAR*)
     - All explosive/stemming columns
     - All flag columns
   - Changed filter from DW_MODIFY_TS to FIREDTIME

4. **R__DRILL_PLAN_INCR_P.sql**
   - Added 8 missing columns:
     - TONS_PER_HOLE
     - BLASTABILITY_INDEX
     - RQD
     - UCS
     - PREDICTED_PENRATE
     - PROJECTED_MECHANICAL_SPECIFIC_ENERGY
     - TARGET_P80
     - SHOT_GOAL

---

## 🚀 Deployment Instructions

### 1. Backup Existing Objects
```sql
-- Create backup copies
CREATE TABLE DEV_API_REF.FUSE.DRILL_CYCLE_INCR_BKP_20260129 
CLONE DEV_API_REF.FUSE.DRILL_CYCLE_INCR;
```

### 2. Deploy New Procedures
```bash
# Extract ZIP to deployment folder
unzip DDL-Scripts-FINAL-2026-01-29-v3.zip -d /deploy

# Deploy via Flyway or manual execution
```

### 3. Truncate and Re-populate Tables
```sql
-- Due to missing columns, existing data is incomplete
TRUNCATE TABLE DEV_API_REF.FUSE.DRILL_CYCLE_INCR;
TRUNCATE TABLE DEV_API_REF.FUSE.BLAST_PLAN_INCR;
TRUNCATE TABLE DEV_API_REF.FUSE.BL_DW_HOLE_INCR;
TRUNCATE TABLE DEV_API_REF.FUSE.DRILL_PLAN_INCR;

-- Re-run procedures with extended range
CALL DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P('7');
CALL DEV_API_REF.FUSE.BLAST_PLAN_INCR_P('7');
CALL DEV_API_REF.FUSE.BL_DW_HOLE_INCR_P('7');
CALL DEV_API_REF.FUSE.DRILL_PLAN_INCR_P('7');
```

### 4. Validate Column Coverage
```sql
-- Verify all columns have data
SELECT 
    COUNT(*) AS total_rows,
    COUNT(GPS_ACCURACY) AS gps_accuracy_non_null,
    COUNT(AIR_PRESSURE_PSI) AS air_pressure_non_null
FROM DEV_API_REF.FUSE.DRILL_CYCLE_INCR;
```

---

## 📁 ZIP Contents

```
DDL-Scripts-FINAL-2026-01-29-v3.zip
├── API_REF/
│   └── FUSE/
│       ├── PROCEDURES/    (14 files)
│       │   ├── R__BLAST_PLAN_EXECUTION_INCR_P.sql
│       │   ├── R__BLAST_PLAN_INCR_P.sql
│       │   ├── R__BL_DW_BLAST_INCR_P.sql
│       │   ├── R__BL_DW_BLASTPROPERTYVALUE_INCR_P.sql
│       │   ├── R__BL_DW_HOLE_INCR_P.sql
│       │   ├── R__DRILLBLAST_EQUIPMENT_INCR_P.sql
│       │   ├── R__DRILLBLAST_OPERATOR_INCR_P.sql
│       │   ├── R__DRILLBLAST_SHIFT_INCR_P.sql
│       │   ├── R__DRILL_CYCLE_INCR_P.sql
│       │   ├── R__DRILL_PLAN_INCR_P.sql
│       │   ├── R__LH_BUCKET_INCR_P.sql
│       │   ├── R__LH_EQUIPMENT_STATUS_EVENT_INCR_P.sql
│       │   ├── R__LH_HAUL_CYCLE_INCR_P.sql
│       │   └── R__LH_LOADING_CYCLE_INCR_P.sql
│       └── TABLES/        (14 files)
│
└── SQL_SERVER/
    ├── PROCEDURES/        (14 files)
    └── TABLES/            (14 files)
```

---

## ⚠️ Critical Rule Reminder

> **NEVER omit columns in INSERT/UPDATE statements!**
> 
> Tables with NULL values due to missing columns is a **FATAL ERROR**.
> 
> Always verify:
> - Table DDL column count
> - Procedure INSERT column count
> - 1:1 mapping between source and target columns

---

**End of Release Notes**
