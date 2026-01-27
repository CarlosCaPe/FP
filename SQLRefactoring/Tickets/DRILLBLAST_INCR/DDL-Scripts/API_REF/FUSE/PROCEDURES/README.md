# INCR Stored Procedures - API_REF.FUSE

## Contenido

11 stored procedures para sincronización incremental de datos DRILL_BLAST y LOAD_HAUL.

| # | Archivo | Source Table | Business Key |
|---|---------|--------------|--------------|
| 1 | R__BLAST_PLAN_EXECUTION_INCR_P.sql | DRILL_BLAST.BLAST_PLAN_EXECUTION | ORIG_SRC_ID, SITE_CODE, BENCH, PUSHBACK, PATTERN_NAME, BLAST_NAME, DRILLED_HOLE_ID |
| 2 | R__BLAST_PLAN_INCR_P.sql | DRILL_BLAST.BLAST_PLAN | BLAST_PLAN_SK |
| 3 | R__BL_DW_BLASTPROPERTYVALUE_INCR_P.sql | DRILL_BLAST.BL_DW_BLASTPROPERTYVALUE | ORIG_SRC_ID, SITE_CODE, BLASTID |
| 4 | R__BL_DW_BLAST_INCR_P.sql | DRILL_BLAST.BL_DW_BLAST | ORIG_SRC_ID, SITE_CODE, ID |
| 5 | R__BL_DW_HOLE_INCR_P.sql | DRILL_BLAST.BL_DW_HOLE | ORIG_SRC_ID, SITE_CODE, ID |
| 6 | R__DRILL_CYCLE_INCR_P.sql | DRILL_BLAST.DRILL_CYCLE | DRILL_CYCLE_SK |
| 7 | R__DRILL_PLAN_INCR_P.sql | DRILL_BLAST.DRILL_PLAN | DRILL_PLAN_SK |
| 8 | R__DRILLBLAST_EQUIPMENT_INCR_P.sql | DRILL_BLAST.DRILLBLAST_EQUIPMENT | ORIG_SRC_ID, SITE_CODE, DRILL_ID |
| 9 | R__DRILLBLAST_OPERATOR_INCR_P.sql | DRILL_BLAST.DRILLBLAST_OPERATOR | SYSTEM_OPERATOR_ID, SITE_CODE |
| 10 | R__DRILLBLAST_SHIFT_INCR_P.sql | DRILL_BLAST.DRILLBLAST_SHIFT | SITE_CODE, SHIFT_ID |
| 11 | R__LH_HAUL_CYCLE_INCR_P.sql | LOAD_HAUL.LH_HAUL_CYCLE | HAUL_CYCLE_ID |

---

## Estructura Estándar (OBLIGATORIA)

Todos los procedures DEBEN seguir esta estructura:

```sql
CREATE OR REPLACE PROCEDURE {{ envi }}_API_REF.FUSE.{TABLE}_INCR_P(
    "NUMBER_OF_DAYS" VARCHAR(16777216) DEFAULT '3'
)
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '
/*****************************************************************************************
* PURPOSE   : Merge data from {TABLE} into {TABLE}_INCR
* SOURCE    : {{ RO_PROD }}_WG.{SCHEMA}.{TABLE}
* TARGET    : {{ envi }}_API_REF.FUSE.{TABLE}_INCR
* BUSINESS KEY: {PRIMARY_KEY_COLUMNS}
* INCREMENTAL COLUMN: DW_MODIFY_TS
* DATE: YYYY-MM-DD | AUTHOR: {NOMBRE}
******************************************************************************************/

var sp_result="";
var sql_count_incr, sql_delete_incr, sql_merge, sql_delete;
var rs_count_incr, rs_delete_incr, rs_merge, rs_delete;
var rs_records_incr, rs_deleted_records_incr, rs_merged_records, rs_delete_records;

// 1. COUNT - Contar registros a purgar
sql_count_incr = `SELECT COUNT(*) AS count_check_1 
                  FROM {{ envi }}_API_REF.fuse.{table}_incr 
                  WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// 2. DELETE - Purgar registros viejos (controla crecimiento de tabla)
sql_delete_incr = `DELETE FROM {{ envi }}_API_REF.fuse.{table}_incr 
                   WHERE dw_modify_ts::date < DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_DATE);`;

// 3. MERGE - Upsert de nuevos/actualizados
sql_merge = `MERGE INTO {{ envi }}_API_REF.fuse.{table}_incr tgt
USING (
    SELECT columns...,
           ''N'' AS dw_logical_delete_flag,
           CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ AS dw_load_ts,
           dw_modify_ts
    FROM {{ RO_PROD }}_WG.{schema}.{table}
    WHERE dw_modify_ts >= DATEADD(day, -` + NUMBER_OF_DAYS + `, CURRENT_TIMESTAMP())
) AS src
ON tgt.{pk} = src.{pk}
WHEN MATCHED AND HASH(src.cols) <> HASH(tgt.cols)
THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT (...) VALUES (...);`;

// 4. UPDATE - Soft delete (marcar eliminados en origen)
sql_delete = `UPDATE {{ envi }}_API_REF.fuse.{table}_incr tgt
              SET dw_logical_delete_flag = ''Y'', 
                  dw_modify_ts = CURRENT_TIMESTAMP(0)::TIMESTAMP_NTZ
              WHERE tgt.dw_logical_delete_flag = ''N''
              AND NOT EXISTS (SELECT 1 FROM {{ RO_PROD }}_WG.{schema}.{table} src
                  WHERE src.{pk} = tgt.{pk});`;

try {
    snowflake.execute({sqlText: "BEGIN WORK;"});
    
    rs_count_incr = snowflake.execute({sqlText: sql_count_incr});
    rs_count_incr.next();
    rs_records_incr = rs_count_incr.getColumnValue(''COUNT_CHECK_1'');
    
    rs_deleted_records_incr = rs_records_incr > 0 
        ? snowflake.execute({sqlText: sql_delete_incr}).getNumRowsAffected() 
        : 0;
    
    rs_merge = snowflake.execute({sqlText: sql_merge});
    rs_merged_records = rs_merge.getNumRowsAffected();
    
    rs_delete = snowflake.execute({sqlText: sql_delete});
    rs_delete_records = rs_delete.getNumRowsAffected();
    
    sp_result = "Deleted: " + rs_deleted_records_incr + 
                ", Merged: " + rs_merged_records + 
                ", Archived: " + rs_delete_records;
    
    snowflake.execute({sqlText: "COMMIT WORK;"});
    return sp_result;
} catch (err) { 
    snowflake.execute({sqlText: "ROLLBACK WORK;"}); 
    throw err; 
}
';
```

---

## Template Variables

| Variable | Descripción | Valores |
|----------|-------------|---------|
| `{{ envi }}` | Ambiente destino | DEV, TEST, PROD |
| `{{ RO_PROD }}` | Ambiente origen (read-only PROD) | PROD |

---

## Flujo de Ejecución

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROCEDURE EXECUTION FLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. BEGIN TRANSACTION                                            │
│     │                                                            │
│  2. COUNT registros > NUMBER_OF_DAYS                             │
│     │                                                            │
│  3. DELETE (PURGE) registros viejos ──► Controla crecimiento     │
│     │                                                            │
│  4. MERGE nuevos/actualizados ──► Upsert con HASH comparison     │
│     │                                                            │
│  5. UPDATE soft-delete ──► Marca DW_LOGICAL_DELETE_FLAG = 'Y'    │
│     │                                                            │
│  6. COMMIT / ROLLBACK                                            │
│     │                                                            │
│  7. RETURN "Deleted: X, Merged: Y, Archived: Z"                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Uso

```sql
-- Ejecutar con default (3 días)
CALL DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P();

-- Ejecutar con 7 días
CALL DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P('7');

-- Ejecutar con 30 días (carga inicial)
CALL DEV_API_REF.FUSE.DRILL_CYCLE_INCR_P('30');
```

---

## Author

Carlos Carrillo | 2026-01-23
