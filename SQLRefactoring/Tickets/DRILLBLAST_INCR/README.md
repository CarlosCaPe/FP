# DRILLBLAST INCR Pipeline

## Overview

This folder contains the complete DDL scripts for the DRILLBLAST INCR (Incremental) Pipeline, which synchronizes operational mining data from Snowflake to SQL Server for the ConOps (Connected Operations) application.

## Quick Reference

| Item | Value |
|------|-------|
| **Version** | 3.0 (2026-01-29) |
| **Artifact** | `DDL-Scripts-FINAL-2026-01-29-v3.zip` |
| **Total Pipelines** | 14 (10 DRILL_BLAST + 4 LOAD_HAUL) |
| **Snowflake Schema** | DEV_API_REF.FUSE |
| **SQL Server Database** | SNOWFLAKE_WG |

---

## Folder Structure

```
DRILLBLAST_INCR/
├── DDL-Scripts-FINAL-2026-01-29/     # Source DDL scripts
│   ├── API_REF/FUSE/
│   │   ├── PROCEDURES/               # 14 Snowflake stored procedures
│   │   └── TABLES/                   # 14 Snowflake INCR tables
│   └── SQL_SERVER/
│       ├── PROCEDURES/               # 14 SQL Server archive procedures
│       └── TABLES/                   # 14 SQL Server INCR tables
├── semantic_model/                   # Semantic YAML definitions
├── DDL-Scripts-FINAL-2026-01-29-v3.zip  # Deployment artifact
├── DRILLBLAST_INCR_ARCHITECTURE.md   # Full technical documentation
├── E2E_VERIFICATION_TEST.sql         # E2E test script
├── RELEASE_NOTES_v3.md               # Version 3 release notes
└── README.md                         # This file
```

---

## Pipeline Inventory

### DRILL_BLAST Domain (10 Tables)

| # | Table | Columns | Business Key |
|---|-------|---------|--------------|
| 1 | BL_DW_BLAST_INCR | 19 | ORIG_SRC_ID, SITE_CODE, ID |
| 2 | BL_DW_BLASTPROPERTYVALUE_INCR | 13 | ORIG_SRC_ID, SITE_CODE, BLASTID |
| 3 | BL_DW_HOLE_INCR | 74 | ORIG_SRC_ID, SITE_CODE, ID |
| 4 | BLAST_PLAN_INCR | 66 | BLAST_PLAN_SK |
| 5 | BLAST_PLAN_EXECUTION_INCR | 62 | Composite (7 columns) |
| 6 | DRILL_CYCLE_INCR | 108 | DRILL_CYCLE_SK |
| 7 | DRILL_PLAN_INCR | 40 | DRILL_PLAN_SK |
| 8 | DRILLBLAST_EQUIPMENT_INCR | 14 | ORIG_SRC_ID, SITE_CODE, DRILL_ID |
| 9 | DRILLBLAST_OPERATOR_INCR | 14 | SYSTEM_OPERATOR_ID, SITE_CODE |
| 10 | DRILLBLAST_SHIFT_INCR | 16 | SITE_CODE, SHIFT_ID |

### LOAD_HAUL Domain (4 Tables)

| # | Table | Columns | Business Key |
|---|-------|---------|--------------|
| 11 | LH_BUCKET_INCR | 39 | BUCKET_ID |
| 12 | LH_EQUIPMENT_STATUS_EVENT_INCR | 21 | EQUIP_STATUS_EVENT_SK |
| 13 | LH_HAUL_CYCLE_INCR | 68 | HAUL_CYCLE_ID |
| 14 | LH_LOADING_CYCLE_INCR | 33 | LOADING_CYCLE_ID |

---

## Deployment

### Step 1: Extract ZIP
```bash
unzip DDL-Scripts-FINAL-2026-01-29-v3.zip -d /deploy
```

### Step 2: Deploy Snowflake Objects
Deploy tables first, then procedures using Flyway or direct execution.

### Step 3: Run E2E Test
Execute `E2E_VERIFICATION_TEST.sql` in Snowflake to verify all tables have data.

---

## Key Features

- **Incremental Loading**: Only modified records are synchronized
- **HASH-Based Delta Detection**: True change detection using column hashing
- **Business Timestamp Filters**: Uses meaningful timestamps (not DW_MODIFY_TS)
- **Complete Column Coverage**: All 14 procedures include 100% of table columns
- **Soft Delete Support**: Tracks deleted records via DW_LOGICAL_DELETE_FLAG
- **Auto-Purging**: Automatic data retention management (default: 3 days)

---

## Critical Rules

> ⚠️ **NEVER omit columns in INSERT/UPDATE statements!**
> 
> Tables with NULL values due to missing columns is a **FATAL ERROR**.

### Business Timestamp Mapping

| Table | Timestamp Column |
|-------|------------------|
| BL_DW_BLAST | FIREDTIME |
| BL_DW_BLASTPROPERTYVALUE | PLANNEDDATE |
| BLAST_PLAN_EXECUTION | SHOT_DATE_LOCAL |
| DRILL_CYCLE | END_HOLE_TS_LOCAL |
| DRILL_PLAN | PLAN_CREATION_TS_LOCAL |
| DRILLBLAST_SHIFT | SHIFT_DATE |
| LH_BUCKET | TRIP_TS_LOCAL |
| LH_EQUIPMENT_STATUS_EVENT | START_TS_LOCAL |
| LH_HAUL_CYCLE | CYCLE_START_TS_LOCAL |
| LH_LOADING_CYCLE | CYCLE_START_TS_LOCAL |

---

## Documentation

- **Architecture Guide**: [DRILLBLAST_INCR_ARCHITECTURE.md](DRILLBLAST_INCR_ARCHITECTURE.md)
- **Release Notes**: [RELEASE_NOTES_v3.md](RELEASE_NOTES_v3.md)
- **E2E Test**: [E2E_VERIFICATION_TEST.sql](E2E_VERIFICATION_TEST.sql)

---

## Author

**Carlos Carrillo** - 2026-01-29
