# SQL Server Archival Stored Procedures

## Overview

This folder contains SQL Server archival stored procedures for all 14 INCR tables. These procedures mirror the DELETE logic from the Snowflake stored procedures, removing records older than a specified number of days.

## Procedures

### DRILL_BLAST Tables (11 procedures)

| Procedure | Table | Incremental Column |
|-----------|-------|-------------------|
| `usp_Archive_BLAST_PLAN_INCR` | DRILL_BLAST__BLAST_PLAN_INCR | BLAST_DT |
| `usp_Archive_BLAST_PLAN_EXECUTION_INCR` | DRILL_BLAST__BLAST_PLAN_EXECUTION_INCR | DW_MODIFY_TS |
| `usp_Archive_BL_DW_BLAST_INCR` | DRILL_BLAST__BL_DW_BLAST_INCR | DW_MODIFY_TS |
| `usp_Archive_BL_DW_BLASTPROPERTYVALUE_INCR` | DRILL_BLAST__BL_DW_BLASTPROPERTYVALUE_INCR | DW_MODIFY_TS |
| `usp_Archive_BL_DW_HOLE_INCR` | DRILL_BLAST__BL_DW_HOLE_INCR | DW_MODIFY_TS |
| `usp_Archive_DRILLBLAST_EQUIPMENT_INCR` | DRILL_BLAST__DRILLBLAST_EQUIPMENT_INCR | DW_MODIFY_TS |
| `usp_Archive_DRILLBLAST_OPERATOR_INCR` | DRILL_BLAST__DRILLBLAST_OPERATOR_INCR | DW_MODIFY_TS |
| `usp_Archive_DRILLBLAST_SHIFT_INCR` | DRILL_BLAST__DRILLBLAST_SHIFT_INCR | SHIFT_START_TS_LOCAL |
| `usp_Archive_DRILL_CYCLE_INCR` | DRILL_BLAST__DRILL_CYCLE_INCR | CYCLE_START_TS_LOCAL |
| `usp_Archive_DRILL_PLAN_INCR` | DRILL_BLAST__DRILL_PLAN_INCR | PLAN_DATE |
| `usp_Archive_LH_HAUL_CYCLE_INCR` | LOAD_HAUL__LH_HAUL_CYCLE_INCR | CYCLE_START_TS_LOCAL |

### LOAD_HAUL Tables (3 procedures)

| Procedure | Table | Incremental Column |
|-----------|-------|-------------------|
| `usp_Archive_LH_EQUIPMENT_STATUS_EVENT_INCR` | LOAD_HAUL__LH_EQUIPMENT_STATUS_EVENT_INCR | START_TS_LOCAL |
| `usp_Archive_LH_LOADING_CYCLE_INCR` | LOAD_HAUL__LH_LOADING_CYCLE_INCR | CYCLE_START_TS_LOCAL |
| `usp_Archive_LH_BUCKET_INCR` | LOAD_HAUL__LH_BUCKET_INCR | TRIP_TS_LOCAL |

### Master Procedure

| Procedure | Description |
|-----------|-------------|
| `usp_Archive_All_INCR_Tables` | Calls all 14 archival procedures and returns summary |

## Usage

### Individual Procedure
```sql
-- Delete records older than 3 days (default)
EXEC [dbo].[usp_Archive_BLAST_PLAN_INCR];

-- Delete records older than 7 days
EXEC [dbo].[usp_Archive_BLAST_PLAN_INCR] @NumberOfDays = 7;
```

### Master Procedure
```sql
-- Archive all tables with 3-day retention
EXEC [dbo].[usp_Archive_All_INCR_Tables];

-- Archive all tables with 7-day retention
EXEC [dbo].[usp_Archive_All_INCR_Tables] @NumberOfDays = 7;

-- Archive without printing results
EXEC [dbo].[usp_Archive_All_INCR_Tables] @NumberOfDays = 3, @PrintResults = 0;
```

## Logic

Each procedure:
1. Calculates the cutoff date: `DATEADD(DAY, -@NumberOfDays, GETDATE())`
2. Deletes records where the incremental column date is before the cutoff
3. Uses transaction wrapping (BEGIN TRY/CATCH with ROLLBACK on error)
4. Returns status, rows deleted, cutoff date, and execution time

## Matching Snowflake Logic

These procedures match the DELETE logic in the Snowflake stored procedures:

**Snowflake:**
```sql
DELETE FROM table_incr 
WHERE column::date < DATEADD(day, -NUMBER_OF_DAYS, CURRENT_DATE);
```

**SQL Server:**
```sql
DELETE FROM table_incr 
WHERE CAST(column AS DATE) < DATEADD(DAY, -@NumberOfDays, CAST(GETDATE() AS DATE));
```

## Deployment

Deploy procedures to SQL Server:
```bash
sqlcmd -S server -d database -i usp_Archive_BLAST_PLAN_INCR.sql
# ... repeat for all procedures
```

Or deploy all at once using the deployment script.

## Author

Carlos Carrillo | 2026-01-28
