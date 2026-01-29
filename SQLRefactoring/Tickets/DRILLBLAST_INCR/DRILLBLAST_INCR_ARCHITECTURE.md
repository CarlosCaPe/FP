# DRILLBLAST INCR Pipeline Architecture

## Official Technical Documentation

| Document Info | |
|---------------|---|
| **Version** | 2.0.0 |
| **Last Updated** | 2026-01-29 |
| **Author** | Carlos Carrillo |
| **Status** | ✅ Production Ready |
| **Environment** | DEV_API_REF → TEST_API_REF → PROD_API_REF |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Architecture Overview](#2-architecture-overview)
3. [Pipeline Inventory](#3-pipeline-inventory)
4. [Technical Specifications](#4-technical-specifications)
5. [Data Flow Architecture](#5-data-flow-architecture)
6. [Stored Procedure Design](#6-stored-procedure-design)
7. [SQL Server Integration](#7-sql-server-integration)
8. [Testing Strategy](#8-testing-strategy)
9. [Deployment Guide](#9-deployment-guide)
10. [Operational Runbook](#10-operational-runbook)

---

## 1. Executive Summary

### 1.1 Purpose

The DRILLBLAST INCR Pipeline is a high-performance incremental data synchronization system designed to replicate operational mining data from Snowflake production tables to Azure SQL Server for real-time dashboard consumption by the **ConOps (Connected Operations)** application.

### 1.2 Business Value

| Metric | Value |
|--------|-------|
| **Data Latency** | < 5 minutes |
| **Data Volume** | ~567,000 rows across 14 tables |
| **Refresh Frequency** | Every 15 minutes (configurable) |
| **Data Retention** | 3 days (configurable) |

### 1.3 Key Features

- ✅ **Incremental Loading**: Only modified records are synchronized
- ✅ **HASH-Based Delta Detection**: True change detection using column hashing
- ✅ **Soft Delete Support**: Tracks deleted records for audit compliance
- ✅ **Auto-Purging**: Automatic data retention management
- ✅ **Idempotent Operations**: Safe to re-run without side effects
- ✅ **Transaction Safety**: Full ACID compliance with rollback support

---

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    SYSTEM ARCHITECTURE                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌───────────────────────┐                                                                  │
│  │   DISPATCH SYSTEMS    │     MineStar, Modular Mining, Jigsaw                            │
│  │   (Source of Truth)   │     Drill/Blast/Load/Haul Operations                            │
│  └───────────┬───────────┘                                                                  │
│              │                                                                              │
│              ▼                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                           SNOWFLAKE - PROD_WG                                         │  │
│  │  ┌─────────────────────────────────┐  ┌─────────────────────────────────┐             │  │
│  │  │      DRILL_BLAST Schema         │  │       LOAD_HAUL Schema          │             │  │
│  │  │  (10 Source Tables)             │  │  (4 Source Tables)              │             │  │
│  │  └─────────────────────────────────┘  └─────────────────────────────────┘             │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
│              │                                                                              │
│              │ Incremental Read (DW_MODIFY_TS filter)                                       │
│              ▼                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                      SNOWFLAKE - {ENV}_API_REF.FUSE                                   │  │
│  │                                                                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    14 INCR Stored Procedures                                    │  │  │
│  │  │  • HASH-based delta detection                                                   │  │  │
│  │  │  • MERGE (UPSERT) operations                                                    │  │  │
│  │  │  • Soft delete tracking                                                         │  │  │
│  │  │  • Auto-purging                                                                 │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘  │  │
│  │                                          │                                            │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │                       14 INCR Tables                                            │  │  │
│  │  │  Rolling 3-day window of operational data                                       │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
│              │                                                                              │
│              │ Azure Function (Timer Trigger)                                               │
│              ▼                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                    AZURE FUNCTION APP                                                 │  │
│  │                    DI-SNFLK-AzureFunction-MSSQL                                       │  │
│  │                                                                                       │  │
│  │  • Calls Snowflake INCR_P procedures                                                  │  │
│  │  • Bulk inserts to SQL Server using Table-Valued Parameters                           │  │
│  │  • Configurable via JSON                                                              │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
│              │                                                                              │
│              │ Bulk Insert (TVP)                                                            │
│              ▼                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                    AZURE SQL SERVER - SNOWFLAKE_WG                                    │  │
│  │                                                                                       │  │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐  │  │
│  │  │  14 INCR Tables + 14 Archival Stored Procedures                                 │  │  │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
│              │                                                                              │
│              │ Direct Query                                                                 │
│              ▼                                                                              │
│  ┌───────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                    ConOps APPLICATION                                                 │  │
│  │                    Real-Time Operations Dashboard                                     │  │
│  └───────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Source** | Snowflake Enterprise | Data Warehouse |
| **Processing** | Snowflake JavaScript SP | ETL Logic |
| **Orchestration** | Azure Functions (Python) | Scheduling & Integration |
| **Target** | Azure SQL Server | Application Database |
| **Consumption** | ConOps Dashboard | Real-time Visualization |

---

## 3. Pipeline Inventory

### 3.1 Complete Pipeline Listing

```
╔═════╦═══════════════════════════════════════╦═══════════════════════════════╦═════════════╦═══════════════╗
║  #  ║ Pipeline Name                         ║ Primary Key                   ║ Rows (DEV)  ║ Avg Time (s)  ║
╠═════╬═══════════════════════════════════════╬═══════════════════════════════╬═════════════╬═══════════════╣
║     ║                    DRILL_BLAST DOMAIN (10 Pipelines)                                                ║
╠═════╬═══════════════════════════════════════╬═══════════════════════════════╬═════════════╬═══════════════╣
║  1  ║ BL_DW_BLAST_INCR                      ║ ORIG_SRC_ID, SITE_CODE, ID    ║          27 ║           2.8 ║
║  2  ║ BL_DW_BLASTPROPERTYVALUE_INCR         ║ ORIG_SRC_ID, SITE_CODE,       ║          27 ║           2.2 ║
║     ║                                       ║ BLASTID                       ║             ║               ║
║  3  ║ BL_DW_HOLE_INCR                       ║ ORIG_SRC_ID, SITE_CODE, ID    ║       7,599 ║         147.3 ║
║  4  ║ BLAST_PLAN_INCR                       ║ BLAST_PLAN_SK                 ║      45,941 ║         272.2 ║
║  5  ║ BLAST_PLAN_EXECUTION_INCR             ║ Composite (7 columns)         ║     155,974 ║          10.0 ║
║  6  ║ DRILL_CYCLE_INCR                      ║ DRILL_CYCLE_SK                ║       5,192 ║          14.4 ║
║  7  ║ DRILL_PLAN_INCR                       ║ DRILL_PLAN_SK                 ║       5,717 ║          22.3 ║
║  8  ║ DRILLBLAST_EQUIPMENT_INCR             ║ ORIG_SRC_ID, SITE_CODE,       ║          58 ║           3.1 ║
║     ║                                       ║ DRILL_ID                      ║             ║               ║
║  9  ║ DRILLBLAST_OPERATOR_INCR              ║ SYSTEM_OPERATOR_ID, SITE_CODE ║       3,061 ║           2.2 ║
║ 10  ║ DRILLBLAST_SHIFT_INCR                 ║ SITE_CODE, SHIFT_ID           ║      30,421 ║          36.4 ║
╠═════╬═══════════════════════════════════════╬═══════════════════════════════╬═════════════╬═══════════════╣
║     ║                    LOAD_HAUL DOMAIN (4 Pipelines)                                                   ║
╠═════╬═══════════════════════════════════════╬═══════════════════════════════╬═════════════╬═══════════════╣
║ 11  ║ LH_BUCKET_INCR                        ║ BUCKET_ID                     ║      49,543 ║          22.6 ║
║ 12  ║ LH_EQUIPMENT_STATUS_EVENT_INCR        ║ EQUIP_STATUS_EVENT_SK         ║     166,728 ║         328.4 ║
║ 13  ║ LH_HAUL_CYCLE_INCR                    ║ HAUL_CYCLE_ID                 ║      63,299 ║         536.3 ║
║ 14  ║ LH_LOADING_CYCLE_INCR                 ║ LOADING_CYCLE_ID              ║      38,572 ║         116.3 ║
╠═════╬═══════════════════════════════════════╬═══════════════════════════════╬═════════════╬═══════════════╣
║     ║ TOTALS                                ║                               ║     567,159 ║       1,494.1 ║
╚═════╩═══════════════════════════════════════╩═══════════════════════════════╩═════════════╩═══════════════╝
```

### 3.2 Domain Classification

```
┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   DOMAIN MAPPING                                           │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│   DRILL_BLAST Domain (10 Tables)                LOAD_HAUL Domain (4 Tables)               │
│   ════════════════════════════════              ════════════════════════════              │
│                                                                                            │
│   ┌─────────────────────────────┐              ┌─────────────────────────────┐            │
│   │  Blast Operations           │              │  Bucket Operations          │            │
│   │  • BL_DW_BLAST              │              │  • LH_BUCKET                │            │
│   │  • BL_DW_BLASTPROPERTYVALUE │              └─────────────────────────────┘            │
│   │  • BL_DW_HOLE               │                                                         │
│   │  • BLAST_PLAN               │              ┌─────────────────────────────┐            │
│   │  • BLAST_PLAN_EXECUTION     │              │  Equipment Tracking         │            │
│   └─────────────────────────────┘              │  • LH_EQUIPMENT_STATUS_EVENT│            │
│                                                └─────────────────────────────┘            │
│   ┌─────────────────────────────┐                                                         │
│   │  Drill Operations           │              ┌─────────────────────────────┐            │
│   │  • DRILL_CYCLE              │              │  Cycle Operations           │            │
│   │  • DRILL_PLAN               │              │  • LH_HAUL_CYCLE            │            │
│   └─────────────────────────────┘              │  • LH_LOADING_CYCLE         │            │
│                                                └─────────────────────────────┘            │
│   ┌─────────────────────────────┐                                                         │
│   │  Reference Data             │                                                         │
│   │  • DRILLBLAST_EQUIPMENT     │                                                         │
│   │  • DRILLBLAST_OPERATOR      │                                                         │
│   │  • DRILLBLAST_SHIFT         │                                                         │
│   └─────────────────────────────┘                                                         │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Technical Specifications

### 4.1 Snowflake Objects

#### 4.1.1 Table Structure

All INCR tables follow a standardized structure:

```sql
CREATE TABLE {ENV}_API_REF.FUSE.{TABLE_NAME}_INCR (
    -- Business Columns (from source)
    {PRIMARY_KEY_COLUMNS},
    {BUSINESS_COLUMNS},
    
    -- Audit Columns (standardized)
    DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
    DW_LOAD_TS TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    DW_MODIFY_TS TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
```

#### 4.1.2 Procedure Signature

All INCR procedures follow a standardized signature:

```sql
CREATE OR REPLACE PROCEDURE {ENV}_API_REF.FUSE.{TABLE_NAME}_INCR_P(
    "NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3'
)
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
```

### 4.2 Incremental Logic

| Table | Incremental Column | Business Rationale |
|-------|-------------------|-------------------|
| BL_DW_BLAST_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| BL_DW_BLASTPROPERTYVALUE_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| BL_DW_HOLE_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| BLAST_PLAN_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| BLAST_PLAN_EXECUTION_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| DRILL_CYCLE_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| DRILL_PLAN_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| DRILLBLAST_EQUIPMENT_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| DRILLBLAST_OPERATOR_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| DRILLBLAST_SHIFT_INCR | DW_MODIFY_TS | Standard ETL timestamp |
| LH_BUCKET_INCR | TRIP_TS_LOCAL | Business timestamp |
| LH_EQUIPMENT_STATUS_EVENT_INCR | START_TS_LOCAL | Business timestamp |
| LH_HAUL_CYCLE_INCR | CYCLE_START_TS_LOCAL | Business timestamp |
| LH_LOADING_CYCLE_INCR | CYCLE_START_TS_LOCAL | Business timestamp |

### 4.3 HASH-Based Delta Detection

Each procedure uses HASH comparison to detect true data changes:

```
┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                              HASH DELTA DETECTION                                          │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│   WHEN MATCHED AND HASH(src.col1, src.col2, src.col3, ...)                                 │
│                    <> HASH(tgt.col1, tgt.col2, tgt.col3, ...)                              │
│   THEN UPDATE SET ...                                                                      │
│                                                                                            │
│   Benefits:                                                                                │
│   ✅ Only updates rows with actual data changes                                            │
│   ✅ Reduces write amplification                                                           │
│   ✅ Improves query performance (fewer micro-partitions modified)                          │
│   ✅ Lowers Snowflake credit consumption                                                   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### HASH Columns by Table

| Table | HASH Columns (Change Detection) |
|-------|--------------------------------|
| DRILL_CYCLE_INCR | ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, DRILL_HOLE_STATUS, ACTUAL_DRILL_HOLE_DEPTH_FEET, DRILL_DURATION, END_HOLE_TS_LOCAL, DRILL_HOLE_PENETRATION_RATE_AVG_FEET_HOUR, DRILL_ID, DRILL_BIT_ID, SYSTEM_OPERATOR_ID, DRILL_PLAN_SK (14 cols) |
| DRILL_PLAN_INCR | ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, HOLE_NAME, HOLE_DEPTH_FEET, HOLE_DIAMETER_INCHES, BURDEN, SPACING, DESIGN_BY, HOLE_START_FEET_X/Y/Z, HOLE_END_FEET_X/Y/Z (17 cols) |
| DRILLBLAST_SHIFT_INCR | orig_src_id, shift_date, shift_name, shift_date_name, attributed_crew_id, crew_name, shift_no, shift_start_ts_utc, shift_end_ts_utc, shift_start_ts_local, shift_end_ts_local, system_version (12 cols) |
| LH_HAUL_CYCLE_INCR | site_code, material_id, report_payload_short_tons, cycle_end_ts_local, loading_loc_id, dump_loc_id, truck_id, excav_id, loading_duration_mins, full_travel_duration_mins, dumping_duration_mins (11 cols) |

---

## 5. Data Flow Architecture

### 5.1 Procedure Execution Flow

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           PROCEDURE EXECUTION FLOW                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   CALL {TABLE}_INCR_P('3')                                                                  │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  BEGIN TRANSACTION                                                      │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  STEP 1: COUNT OLD RECORDS                                              │              │
│   │  ────────────────────────────────────────────────────────────────────── │              │
│   │                                                                         │              │
│   │  SELECT COUNT(*) AS count_check_1                                       │              │
│   │  FROM {ENV}_API_REF.FUSE.{TABLE}_INCR                                   │              │
│   │  WHERE DW_MODIFY_TS::date < DATEADD(day, -NUMBER_OF_DAYS, CURRENT_DATE) │              │
│   │                                                                         │              │
│   │  Purpose: Determine if purging is needed                                │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  STEP 2: PURGE OLD RECORDS (if count > 0)                               │              │
│   │  ────────────────────────────────────────────────────────────────────── │              │
│   │                                                                         │              │
│   │  DELETE FROM {ENV}_API_REF.FUSE.{TABLE}_INCR                            │              │
│   │  WHERE DW_MODIFY_TS::date < DATEADD(day, -NUMBER_OF_DAYS, CURRENT_DATE) │              │
│   │                                                                         │              │
│   │  Purpose: Control table growth, maintain rolling window                 │              │
│   │  Output: rs_deleted_records_incr                                        │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  STEP 3: MERGE (UPSERT with HASH-based delta)                           │              │
│   │  ────────────────────────────────────────────────────────────────────── │              │
│   │                                                                         │              │
│   │  MERGE INTO {ENV}_API_REF.FUSE.{TABLE}_INCR tgt                         │              │
│   │  USING (                                                                │              │
│   │      SELECT {explicit_columns}                                          │              │
│   │      FROM PROD_WG.{SCHEMA}.{TABLE}                                      │              │
│   │      WHERE DW_MODIFY_TS >= DATEADD(day, -NUMBER_OF_DAYS, NOW())         │              │
│   │  ) AS src                                                               │              │
│   │  ON tgt.{PK} = src.{PK}                                                 │              │
│   │                                                                         │              │
│   │  WHEN MATCHED AND HASH(src.col1, src.col2, ...)                         │              │
│   │                    <> HASH(tgt.col1, tgt.col2, ...)                     │              │
│   │  THEN UPDATE SET tgt.col1 = src.col1, tgt.col2 = src.col2, ...          │              │
│   │                                                                         │              │
│   │  WHEN NOT MATCHED                                                       │              │
│   │  THEN INSERT (col1, col2, ...) VALUES (src.col1, src.col2, ...)         │              │
│   │                                                                         │              │
│   │  Purpose: Synchronize new and modified records                          │              │
│   │  Output: rs_merged_records                                              │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  STEP 4: SOFT DELETE (Mark deleted records)                             │              │
│   │  ────────────────────────────────────────────────────────────────────── │              │
│   │                                                                         │              │
│   │  UPDATE {ENV}_API_REF.FUSE.{TABLE}_INCR tgt                             │              │
│   │  SET DW_LOGICAL_DELETE_FLAG = 'Y',                                      │              │
│   │      DW_MODIFY_TS = CURRENT_TIMESTAMP()                                 │              │
│   │  WHERE DW_LOGICAL_DELETE_FLAG = 'N'                                     │              │
│   │  AND NOT EXISTS (                                                       │              │
│   │      SELECT 1 FROM PROD_WG.{SCHEMA}.{TABLE} src                         │              │
│   │      WHERE src.{PK} = tgt.{PK}                                          │              │
│   │  )                                                                      │              │
│   │                                                                         │              │
│   │  Purpose: Track records deleted from source (audit trail)               │              │
│   │  Output: rs_delete_records                                              │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐              │
│   │  COMMIT TRANSACTION                                                     │              │
│   └─────────────────────────────────────────────────────────────────────────┘              │
│            │                                                                                │
│            ▼                                                                                │
│   RETURN "Deleted: X, Merged: Y, Archived: Z"                                               │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Error Handling

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              ERROR HANDLING FLOW                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   try {                                                                                     │
│       snowflake.execute({sqlText: "BEGIN WORK;"});                                          │
│       // ... execute steps 1-4 ...                                                          │
│       snowflake.execute({sqlText: "COMMIT WORK;"});                                         │
│       return sp_result;                                                                     │
│   }                                                                                         │
│   catch (err) {                                                                             │
│       snowflake.execute({sqlText: "ROLLBACK WORK;"});  ← Full rollback on any error        │
│       throw err;                                        ← Re-throw for logging             │
│   }                                                                                         │
│                                                                                             │
│   Guarantees:                                                                               │
│   ✅ ACID Compliance                                                                        │
│   ✅ No partial updates                                                                     │
│   ✅ Idempotent (safe to retry)                                                             │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Stored Procedure Design

### 6.1 Naming Conventions

| Object Type | Pattern | Example |
|-------------|---------|---------|
| Snowflake Table | `{ENV}_API_REF.FUSE.{TABLE}_INCR` | `DEV_API_REF.FUSE.DRILL_CYCLE_INCR` |
| Snowflake Procedure | `{ENV}_API_REF.FUSE.{TABLE}_INCR_P` | `DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P` |
| SQL Server Table | `[dbo].[{SCHEMA}__{TABLE}_INCR]` | `[dbo].[DRILL_BLAST__DRILL_CYCLE_INCR]` |
| SQL Server Archival SP | `[dbo].[usp_Archive_{TABLE}_INCR]` | `[dbo].[usp_Archive_DRILL_CYCLE_INCR]` |
| Table Type (IMO) | `[dbo].[{SCHEMA}__{TABLE}_IMO]` | `[dbo].[DRILL_BLAST__DRILL_CYCLE_IMO]` |

### 6.2 Parameter Specification

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `NUMBER_OF_DAYS` | VARCHAR | '3' | Lookback window in days |

### 6.3 Return Value Format

```
"Deleted: {purged_count}, Merged: {upsert_count}, Archived: {soft_delete_count}"
```

Example: `"Deleted: 1250, Merged: 4036, Archived: 12"`

---

## 7. SQL Server Integration

### 7.1 Table Structure

SQL Server tables mirror Snowflake INCR tables with naming convention:
`[dbo].[{SCHEMA}__{TABLE}_INCR]`

### 7.2 Archival Stored Procedures

Each SQL Server table has a corresponding archival procedure:

```sql
CREATE OR ALTER PROCEDURE [dbo].[usp_Archive_{TABLE}_INCR]
    @NumberOfDays INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RowsDeleted INT = 0;
    DECLARE @CutoffDate DATETIME2 = DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM [dbo].[{SCHEMA}__{TABLE}_INCR]
        WHERE CAST([DW_MODIFY_TS] AS DATE) < @CutoffDate;
        
        SET @RowsDeleted = @@ROWCOUNT;
        COMMIT TRANSACTION;
        
        SELECT 'SUCCESS' AS Status, @RowsDeleted AS RowsDeleted;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

### 7.3 Complete SQL Server Object Inventory

| Object Type | Count | Pattern |
|-------------|-------|---------|
| INCR Tables | 14 | `[dbo].[{SCHEMA}__{TABLE}_INCR]` |
| Archival Procedures | 14 | `[dbo].[usp_Archive_{TABLE}_INCR]` |
| Table Types (IMO) | 14 | `[dbo].[{SCHEMA}__{TABLE}_IMO]` |

---

## 8. Testing Strategy

### 8.1 Testing Pyramid

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              TESTING PYRAMID                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│                            ┌───────────────┐                                                │
│                            │   E2E Tests   │  ← Integration with ConOps                    │
│                            │   (Manual)    │                                                │
│                            └───────────────┘                                                │
│                          ┌───────────────────┐                                              │
│                          │  Integration Tests │  ← Snowflake + SQL Server                  │
│                          │   (Automated)      │                                             │
│                          └───────────────────┘                                              │
│                        ┌───────────────────────┐                                            │
│                        │    Procedure Tests    │  ← Each INCR_P procedure                  │
│                        │    (14 procedures)    │                                            │
│                        └───────────────────────┘                                            │
│                      ┌───────────────────────────┐                                          │
│                      │     Unit Tests (DDL)      │  ← Syntax validation                    │
│                      │  (28 Snowflake objects)   │                                          │
│                      └───────────────────────────┘                                          │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Test Types Applied

#### 8.2.1 Syntax Validation Tests

| Test | Description | Tool |
|------|-------------|------|
| DDL Syntax Check | Verify all CREATE statements compile | Snowflake Worksheet |
| Template Variable Check | Verify `{{ envi }}` and `{{ RO_PROD }}` substitution | Python Script |
| Naming Convention Check | Verify R__ prefix for ADO | validate_naming.py |

#### 8.2.2 Unit Tests (Per Procedure)

```python
# Test execution for each procedure
CALL {TABLE}_INCR_P('3');

# Assertions:
# ✅ Returns VARCHAR with format "Deleted: X, Merged: Y, Archived: Z"
# ✅ No exceptions thrown
# ✅ Transaction commits successfully
```

#### 8.2.3 Functional Tests

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| **Initial Load** | Run on empty INCR table | All source records inserted |
| **Incremental Load** | Run on populated table | Only changed records updated |
| **Idempotency** | Run same procedure twice | Second run has fewer merges |
| **Purge Logic** | Data older than N days | Deleted from INCR table |
| **Soft Delete** | Source record deleted | DW_LOGICAL_DELETE_FLAG = 'Y' |
| **HASH Delta** | No data changes | No updates performed |

#### 8.2.4 Data Integrity Tests

| Test | Validation Query |
|------|-----------------|
| **Row Count** | `SELECT COUNT(*) FROM {TABLE}_INCR` |
| **NULL Check** | `SELECT COUNT(*) WHERE {REQUIRED_COL} IS NULL` |
| **PK Uniqueness** | `SELECT {PK}, COUNT(*) GROUP BY {PK} HAVING COUNT(*) > 1` |
| **Date Range** | `SELECT MIN/MAX(DW_MODIFY_TS)` should be within N days |

#### 8.2.5 Performance Tests

| Metric | Target | Actual (DEV) |
|--------|--------|--------------|
| BL_DW_BLAST_INCR_P | < 10s | 2.8s ✅ |
| BLAST_PLAN_INCR_P | < 300s | 272.2s ✅ |
| LH_HAUL_CYCLE_INCR_P | < 600s | 536.3s ✅ |
| Total (all 14) | < 30 min | 24.9 min ✅ |

#### 8.2.6 Stress Tests

```
┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                              STRESS TEST RESULTS                                           │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│   Test Duration: 24.1 minutes (1,447 seconds)                                              │
│   Test Coverage: 11 tables × 30 days = 330 iterations                                      │
│   Success Rate: 100% (330/330)                                                             │
│                                                                                            │
│   ┌───────────────────────────────────────────────────────────────────────────────────┐   │
│   │  Table                    │ Max Rows (30d) │ Avg Query Time │ Status              │   │
│   ├───────────────────────────┼────────────────┼────────────────┼─────────────────────│   │
│   │  LH_HAUL_CYCLE            │       528,144  │        11.38s  │ ✅ 30/30            │   │
│   │  BLAST_PLAN_EXECUTION     │       149,489  │         0.55s  │ ✅ 30/30            │   │
│   │  DRILL_PLAN               │        56,723  │         0.56s  │ ✅ 30/30            │   │
│   │  DRILL_CYCLE              │        45,989  │         0.50s  │ ✅ 30/30            │   │
│   │  BLAST_PLAN               │        39,277  │        30.92s  │ ✅ 30/30            │   │
│   │  DRILLBLAST_SHIFT         │        30,390  │         2.37s  │ ✅ 30/30            │   │
│   │  BL_DW_HOLE               │        20,945  │         0.51s  │ ✅ 30/30            │   │
│   │  DRILLBLAST_OPERATOR      │         5,263  │         0.38s  │ ✅ 30/30            │   │
│   │  BL_DW_BLAST              │            84  │         0.33s  │ ✅ 30/30            │   │
│   │  BL_DW_BLASTPROPERTYVALUE │            84  │         0.40s  │ ✅ 30/30            │   │
│   │  DRILLBLAST_EQUIPMENT     │            62  │         0.33s  │ ✅ 30/30            │   │
│   └───────────────────────────┴────────────────┴────────────────┴─────────────────────┘   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 E2E Test Results (2026-01-29)

```
╔═════════════════════════════════════════════════════════════════════════════════════════════╗
║                           E2E TEST RESULTS - 2026-01-29                                     ║
╠═══╦═══════════════════════════════════════════╦════════════╦═════════════╦══════════════════╣
║ # ║ Procedure                                 ║ Status     ║ Merged Rows ║ Execution Time   ║
╠═══╬═══════════════════════════════════════════╬════════════╬═════════════╬══════════════════╣
║ 1 ║ BL_DW_BLAST_INCR_P                        ║ ✅ PASS    ║           0 ║            2.8s  ║
║ 2 ║ BL_DW_BLASTPROPERTYVALUE_INCR_P           ║ ✅ PASS    ║           0 ║            2.2s  ║
║ 3 ║ BL_DW_HOLE_INCR_P                         ║ ✅ PASS    ║       6,751 ║          147.3s  ║
║ 4 ║ BLAST_PLAN_INCR_P                         ║ ✅ PASS    ║      45,941 ║          272.2s  ║
║ 5 ║ BLAST_PLAN_EXECUTION_INCR_P               ║ ✅ PASS    ║           4 ║           10.0s  ║
║ 6 ║ DRILL_CYCLE_INCR_P                        ║ ✅ PASS    ║       4,036 ║           14.4s  ║
║ 7 ║ DRILL_PLAN_INCR_P                         ║ ✅ PASS    ║       3,999 ║           22.3s  ║
║ 8 ║ DRILLBLAST_EQUIPMENT_INCR_P               ║ ✅ PASS    ║           0 ║            3.1s  ║
║ 9 ║ DRILLBLAST_OPERATOR_INCR_P                ║ ✅ PASS    ║           0 ║            2.2s  ║
║10 ║ DRILLBLAST_SHIFT_INCR_P                   ║ ✅ PASS    ║           0 ║           36.4s  ║
║11 ║ LH_BUCKET_INCR_P                          ║ ✅ PASS    ║           0 ║           22.6s  ║
║12 ║ LH_EQUIPMENT_STATUS_EVENT_INCR_P          ║ ✅ PASS    ║           0 ║          328.4s  ║
║13 ║ LH_HAUL_CYCLE_INCR_P                      ║ ✅ PASS    ║           0 ║          536.3s  ║
║14 ║ LH_LOADING_CYCLE_INCR_P                   ║ ✅ PASS    ║           0 ║          116.3s  ║
╠═══╩═══════════════════════════════════════════╩════════════╩═════════════╩══════════════════╣
║                              SUCCESS RATE: 14/14 (100%)                                     ║
╚═════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 9. Deployment Guide

### 9.1 Pre-Deployment Checklist

- [ ] All DDL files validated for syntax
- [ ] Template variables verified (`{{ envi }}`, `{{ RO_PROD }}`)
- [ ] Naming conventions validated (R__ prefix)
- [ ] E2E tests passed in DEV
- [ ] SQL Server tables and archival procedures created
- [ ] Azure Function configuration ready

### 9.2 ADO Deployment Package

```
DDL-Scripts-FINAL-2026-01-29.zip
│
├── API_REF/FUSE/
│   ├── TABLES/                          (14 files)
│   │   └── R__{TABLE}_INCR.sql
│   │
│   └── PROCEDURES/                      (14 files)
│       └── R__{TABLE}_INCR_P.sql
│
└── SQL_SERVER/
    ├── TABLES/                          (14 files)
    │   └── {SCHEMA}__{TABLE}_INCR.sql
    │
    └── PROCEDURES/                      (15 files)
        └── usp_Archive_{TABLE}_INCR.sql

TOTAL: 57 files
```

### 9.3 Deployment Steps

#### Step 1: Snowflake Tables

```bash
# Via ADO Pipeline
flyway migrate -url="jdbc:snowflake://..." -locations="filesystem:API_REF/FUSE/TABLES"
```

#### Step 2: Snowflake Procedures

```bash
# Via ADO Pipeline
flyway migrate -url="jdbc:snowflake://..." -locations="filesystem:API_REF/FUSE/PROCEDURES"
```

#### Step 3: SQL Server Objects

```sql
-- Deploy tables first, then archival procedures
sqlcmd -S server -d SNOWFLAKE_WG -i SQL_SERVER/TABLES/*.sql
sqlcmd -S server -d SNOWFLAKE_WG -i SQL_SERVER/PROCEDURES/*.sql
```

#### Step 4: Validation

```sql
-- Snowflake: Verify all 14 procedures exist
SELECT PROCEDURE_NAME 
FROM DEV_API_REF.INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'FUSE' 
AND PROCEDURE_NAME LIKE '%_INCR_P';

-- SQL Server: Verify all 14 tables exist
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%_INCR';
```

---

## 10. Operational Runbook

### 10.1 Monitoring Queries

#### Check Recent Execution Results

```sql
-- Snowflake: Check INCR table freshness
SELECT 
    'DRILL_CYCLE_INCR' AS table_name,
    COUNT(*) AS row_count,
    MAX(DW_MODIFY_TS) AS latest_data,
    DATEDIFF('hour', MAX(DW_MODIFY_TS), CURRENT_TIMESTAMP()) AS hours_ago
FROM DEV_API_REF.FUSE.DRILL_CYCLE_INCR;
```

#### Check for Soft Deleted Records

```sql
SELECT COUNT(*) AS soft_deleted_count
FROM DEV_API_REF.FUSE.DRILL_CYCLE_INCR
WHERE DW_LOGICAL_DELETE_FLAG = 'Y';
```

### 10.2 Troubleshooting

| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Procedure returns 0 merged | No new data in source | Check source table DW_MODIFY_TS |
| Timeout error | Large data volume | Increase NUMBER_OF_DAYS window |
| Duplicate key error | Source has duplicates | Add QUALIFY ROW_NUMBER() |
| NULL in non-nullable column | Source data quality | Add COALESCE in SELECT |

### 10.3 Emergency Procedures

#### Force Full Reload

```sql
-- 1. Truncate INCR table
TRUNCATE TABLE DEV_API_REF.FUSE.{TABLE}_INCR;

-- 2. Run procedure with large window
CALL DEV_API_REF.FUSE.{TABLE}_INCR_P('30');
```

#### Rollback Procedure Change

```sql
-- Use Snowflake Time Travel to restore previous version
CREATE OR REPLACE PROCEDURE ... AS 
(SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())));
```

---

## Appendix A: File Inventory

| File | Purpose |
|------|---------|
| `full_e2e_test.py` | Runs all 14 procedures and validates results |
| `fix_all_hash_procedures.py` | Fixes HASH comparison in 4 procedures |
| `deploy_sql_server_archival.py` | Deploys all SQL Server archival procedures |
| `generate_final_ddl_zip.py` | Creates DDL package for ADO deployment |
| `e2e_test_results.json` | JSON output of E2E test results |

---

## Appendix B: Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-01-23 | Carlos Carrillo | Initial 11 INCR pipelines |
| 1.1.0 | 2026-01-24 | Carlos Carrillo | Added 3 LOAD_HAUL pipelines |
| 1.2.0 | 2026-01-26 | Carlos Carrillo | Added purging logic |
| 1.3.0 | 2026-01-28 | Carlos Carrillo | Fixed column mapping issues |
| 2.0.0 | 2026-01-29 | Carlos Carrillo | Fixed HASH comparison, complete documentation |

---

## Appendix C: Contact Information

| Role | Name | Contact |
|------|------|---------|
| Developer | Carlos Carrillo | ccarrill2@fmi.com |
| Tech Lead | Vikas Uttam | via Teams |
| Product Owner | Rohit Khatter | via Teams |

---

*End of Document*
