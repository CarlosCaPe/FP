# INCR Incremental Data Architecture
## Complete Data Flow Diagram

```
╔══════════════════════════════════════════════════════════════════════════════════════════════╗
║                           INCR INCREMENTAL DATA ARCHITECTURE                                  ║
║                                  Complete Data Flow Diagram                                   ║
╚══════════════════════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    SOURCE LAYER (PROD)                                       │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │   PROD_WG.DRILL_BLAST       │     │   PROD_WG.LOAD_HAUL         │                        │
│  │  ┌─────────────────────┐    │     │  ┌─────────────────────┐    │                        │
│  │  │ DRILL_CYCLE         │    │     │  │ LH_HAUL_CYCLE       │    │                        │
│  │  │ DRILL_PLAN          │    │     │  │ LH_LOADING_CYCLE    │    │                        │
│  │  │ BLAST_PLAN          │    │     │  │ LH_BUCKET           │    │                        │
│  │  │ BLAST_PLAN_EXECUTION│    │     │  │ LH_EQUIPMENT_STATUS │    │                        │
│  │  │ BL_DW_BLAST         │    │     │  └─────────────────────┘    │                        │
│  │  │ BL_DW_HOLE          │    │     │            4 tables         │                        │
│  │  │ BL_DW_BLASTPROPVAL  │    │     └─────────────────────────────┘                        │
│  │  │ DRILLBLAST_EQUIPMENT│    │                                                            │
│  │  │ DRILLBLAST_OPERATOR │    │                                                            │
│  │  │ DRILLBLAST_SHIFT    │    │                                                            │
│  │  └─────────────────────┘    │                                                            │
│  │          10 tables          │                                                            │
│  └─────────────────────────────┘                                                            │
└────────────────────────────────────────────┬────────────────────────────────────────────────┘
                                             │
                                             │ MERGE (3-day window)
                                             │ DW_MODIFY_TS > DATEADD(-3, CURRENT_DATE)
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SNOWFLAKE API LAYER (DEV_API_REF.FUSE)                          │
│                                                                                              │
│  ┌────────────────────────────────────────┐    ┌────────────────────────────────────────┐   │
│  │         14 INCR TABLES                 │    │        14 INCR PROCEDURES              │   │
│  │  ┌──────────────────────────────────┐  │    │  ┌──────────────────────────────────┐  │   │
│  │  │ DRILL_BLAST Tables (10):         │  │    │  │ Pattern: {TABLE}_INCR_P          │  │   │
│  │  │  • BLAST_PLAN_INCR               │  │    │  │                                  │  │   │
│  │  │  • BLAST_PLAN_EXECUTION_INCR     │  │    │  │ Logic:                           │  │   │
│  │  │  • BL_DW_BLAST_INCR              │  │    │  │  1. PURGE old data (DELETE)      │  │   │
│  │  │  • BL_DW_BLASTPROPERTYVALUE_INCR │  │    │  │  2. MERGE new data (UPSERT)      │  │   │
│  │  │  • BL_DW_HOLE_INCR               │  │    │  │  3. SOFT DELETE (flag 'Y')       │  │   │
│  │  │  • DRILLBLAST_EQUIPMENT_INCR     │  │    │  │                                  │  │   │
│  │  │  • DRILLBLAST_OPERATOR_INCR      │  │    │  │ Archive Columns:                 │  │   │
│  │  │  • DRILLBLAST_SHIFT_INCR         │  │    │  │  • Most: DW_MODIFY_TS            │  │   │
│  │  │  • DRILL_CYCLE_INCR              │  │    │  │  • LH_EQUIP: START_TS_LOCAL      │  │   │
│  │  │  • DRILL_PLAN_INCR               │  │    │  │  • LH_LOADING: CYCLE_START_TS    │  │   │
│  │  │                                  │  │    │  │  • LH_BUCKET: TRIP_TS_LOCAL      │  │   │
│  │  │ LOAD_HAUL Tables (4):            │  │    │  └──────────────────────────────────┘  │   │
│  │  │  • LH_HAUL_CYCLE_INCR            │  │    │                                        │   │
│  │  │  • LH_EQUIPMENT_STATUS_EVENT_INCR│  │    │                                        │   │
│  │  │  • LH_LOADING_CYCLE_INCR         │  │    │                                        │   │
│  │  │  • LH_BUCKET_INCR                │  │    │                                        │   │
│  │  └──────────────────────────────────┘  │    │                                        │   │
│  └────────────────────────────────────────┘    └────────────────────────────────────────┘   │
└────────────────────────────────────────────┬────────────────────────────────────────────────┘
                                             │
                                             │ AZURE FUNCTION SYNC
                                             │ (DI-SNFLK-AzureFunction-MSSQL)
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              SQL SERVER LAYER (SNOWFLAKE_WG)                                 │
│                                                                                              │
│  ┌────────────────────────────────────────┐    ┌────────────────────────────────────────┐   │
│  │         14 INCR TABLES                 │    │     15 ARCHIVAL PROCEDURES             │   │
│  │  ┌──────────────────────────────────┐  │    │  ┌──────────────────────────────────┐  │   │
│  │  │ DRILL_BLAST__ prefix (10):       │  │    │  │ Pattern: usp_Archive_{TABLE}_INCR│  │   │
│  │  │  • DRILL_BLAST__BLAST_PLAN_INCR  │  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__BLAST_PLAN_EXEC..│  │    │  │ 14 Individual Procedures +       │  │   │
│  │  │  • DRILL_BLAST__BL_DW_BLAST_INCR │  │    │  │ 1 Master Procedure               │  │   │
│  │  │  • DRILL_BLAST__BL_DW_BLASTPROP..│  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__BL_DW_HOLE_INCR  │  │    │  │ Logic:                           │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_EQUIP.│  │    │  │  DELETE WHERE archive_col <      │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_OPER..│  │    │  │    DATEADD(-N, GETDATE())        │  │   │
│  │  │  • DRILL_BLAST__DRILLBLAST_SHIFT.│  │    │  │                                  │  │   │
│  │  │  • DRILL_BLAST__DRILL_CYCLE_INCR │  │    │  │ usp_Archive_All_INCR_Tables:     │  │   │
│  │  │  • DRILL_BLAST__DRILL_PLAN_INCR  │  │    │  │  Calls all 14 procedures         │  │   │
│  │  │                                  │  │    │  │  Returns summary results         │  │   │
│  │  │ LOAD_HAUL__ prefix (4):          │  │    │  └──────────────────────────────────┘  │   │
│  │  │  • LOAD_HAUL__LH_HAUL_CYCLE_INCR │  │    │                                        │   │
│  │  │  • LOAD_HAUL__LH_EQUIPMENT_STAT..│  │    │  ┌──────────────────────────────────┐  │   │
│  │  │  • LOAD_HAUL__LH_LOADING_CYCLE.. │  │    │  │      13 ARCHIVAL INDEXES         │  │   │
│  │  │  • LOAD_HAUL__LH_BUCKET_INCR     │  │    │  │  IX_{TABLE}_INCR_{ARCHIVE_COL}   │  │   │
│  │  └──────────────────────────────────┘  │    │  │  Optimized for DELETE queries    │  │   │
│  └────────────────────────────────────────┘    │  └──────────────────────────────────┘  │   │
│                                                └────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Object Summary

| LAYER | TABLES | PROCEDURES | INDEXES | TOTAL |
|-------|--------|------------|---------|-------|
| PROD (Source) | 14 | - | - | 14 |
| Snowflake API | 14 | 14 | - | 28 |
| SQL Server | 14 | 15* | 13 | 42 |
| **TOTAL** | **42** | **29** | **13** | **84** |

> *15 = 14 individual + 1 master procedure (`usp_Archive_All_INCR_Tables`)

## Why 15 Procedures vs 14 Tables?

SQL Server has **15 archival procedures** because:
- **14 individual procedures** - one for each INCR table
- **1 master procedure** (`usp_Archive_All_INCR_Tables`) that calls all 14 procedures and returns a summary

## Special Archive Columns

| TABLE | ARCHIVE COLUMN | REASON |
|-------|----------------|--------|
| Most tables (11) | `DW_MODIFY_TS` | Standard warehouse timestamp |
| LH_EQUIPMENT_STATUS_EVENT_INCR | `START_TS_LOCAL` | Business event start time |
| LH_LOADING_CYCLE_INCR | `CYCLE_START_TS_LOCAL` | Loading cycle start time |
| LH_BUCKET_INCR | `TRIP_TS_LOCAL` | Bucket trip timestamp |

## Complete Object Mapping

| # | Snowflake Table | Snowflake Proc | SQL Server Table | SQL Server Proc | Archive Col |
|---|-----------------|----------------|------------------|-----------------|-------------|
| 1 | BLAST_PLAN_INCR | BLAST_PLAN_INCR_P | DRILL_BLAST__BLAST_PLAN_INCR | usp_Archive_BLAST_PLAN_INCR | DW_MODIFY_TS |
| 2 | BLAST_PLAN_EXECUTION_INCR | BLAST_PLAN_EXECUTION_INCR_P | DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR | usp_Archive_BLAST_PLAN_EXECUTION_INCR | DW_MODIFY_TS |
| 3 | BL_DW_BLAST_INCR | BL_DW_BLAST_INCR_P | DRILL_BLAST__BL_DW_BLAST_INCR | usp_Archive_BL_DW_BLAST_INCR | DW_MODIFY_TS |
| 4 | BL_DW_BLASTPROPERTYVALUE_INCR | BL_DW_BLASTPROPERTYVALUE_INCR_P | DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR | usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR | DW_MODIFY_TS |
| 5 | BL_DW_HOLE_INCR | BL_DW_HOLE_INCR_P | DRILL_BLAST__BL_DW_HOLE_INCR | usp_Archive_BL_DW_HOLE_INCR | DW_MODIFY_TS |
| 6 | DRILLBLAST_EQUIPMENT_INCR | DRILLBLAST_EQUIPMENT_INCR_P | DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR | usp_Archive_DRILLBLAST_EQUIPMENT_INCR | DW_MODIFY_TS |
| 7 | DRILLBLAST_OPERATOR_INCR | DRILLBLAST_OPERATOR_INCR_P | DRILL_BLAST__DRILLBLAST_OPERATOR_INCR | usp_Archive_DRILLBLAST_OPERATOR_INCR | DW_MODIFY_TS |
| 8 | DRILLBLAST_SHIFT_INCR | DRILLBLAST_SHIFT_INCR_P | DRILL_BLAST__DRILLBLAST_SHIFT_INCR | usp_Archive_DRILLBLAST_SHIFT_INCR | DW_MODIFY_TS |
| 9 | DRILL_CYCLE_INCR | DRILL_CYCLE_INCR_P | DRILL_BLAST__DRILL_CYCLE_INCR | usp_Archive_DRILL_CYCLE_INCR | DW_MODIFY_TS |
| 10 | DRILL_PLAN_INCR | DRILL_PLAN_INCR_P | DRILL_BLAST__DRILL_PLAN_INCR | usp_Archive_DRILL_PLAN_INCR | DW_MODIFY_TS |
| 11 | LH_HAUL_CYCLE_INCR | LH_HAUL_CYCLE_INCR_P | LOAD_HAUL__LH_HAUL_CYCLE_INCR | usp_Archive_LH_HAUL_CYCLE_INCR | DW_MODIFY_TS |
| 12 | LH_EQUIPMENT_STATUS_EVENT_INCR | LH_EQUIPMENT_STATUS_EVENT_INCR_P | LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR | usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR | **START_TS_LOCAL** |
| 13 | LH_LOADING_CYCLE_INCR | LH_LOADING_CYCLE_INCR_P | LOAD_HAUL__LH_LOADING_CYCLE_INCR | usp_Archive_LH_LOADING_CYCLE_INCR | **CYCLE_START_TS_LOCAL** |
| 14 | LH_BUCKET_INCR | LH_BUCKET_INCR_P | LOAD_HAUL__LH_BUCKET_INCR | usp_Archive_LH_BUCKET_INCR | **TRIP_TS_LOCAL** |

---

## Data Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW PIPELINE                               │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────┐                                                            │
│   │  PROD_WG    │  Source tables (14 total)                                  │
│   │  DRILL_BLAST│  - 10 Drill/Blast tables                                   │
│   │  LOAD_HAUL  │  - 4 Load/Haul tables                                      │
│   └──────┬──────┘                                                            │
│          │                                                                   │
│          │  ① MERGE (3-day incremental window)                               │
│          │     - Filters: DW_MODIFY_TS > CURRENT_DATE - 3                    │
│          │     - Scheduled: Every 15 minutes                                 │
│          ▼                                                                   │
│   ┌─────────────┐                                                            │
│   │ DEV_API_REF │  INCR tables (14 total)                                    │
│   │ FUSE schema │  - Rolling 3-day window maintained                         │
│   │             │  - PURGE → MERGE → SOFT DELETE pattern                     │
│   └──────┬──────┘                                                            │
│          │                                                                   │
│          │  ② AZURE FUNCTION SYNC                                            │
│          │     - DI-SNFLK-AzureFunction-MSSQL                                │
│          │     - Copies data to SQL Server                                   │
│          ▼                                                                   │
│   ┌─────────────┐                                                            │
│   │ SNOWFLAKE_WG│  INCR tables (14 total)                                    │
│   │ SQL Server  │  - Mirror of Snowflake INCR data                           │
│   │             │  - Archival procedures for data retention                  │
│   └──────┬──────┘                                                            │
│          │                                                                   │
│          │  ③ ARCHIVAL (Retention management)                                │
│          │     - DELETE WHERE archive_col < GETDATE() - N days               │
│          │     - Default: 3 days retention                                   │
│          ▼                                                                   │
│   ┌─────────────┐                                                            │
│   │   CLEANUP   │  Data older than retention window is deleted               │
│   └─────────────┘                                                            │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Author

Carlos Carrillo | 2026-01-28
