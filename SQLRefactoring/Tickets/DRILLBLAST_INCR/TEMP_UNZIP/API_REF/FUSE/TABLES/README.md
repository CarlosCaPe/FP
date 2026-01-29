# INCR Tables - API_REF.FUSE

## Contenido

11 tablas incrementales para sincronización de datos DRILL_BLAST y LOAD_HAUL hacia SQL Azure.

| # | Archivo | Source Table | Primary Key | Est. Rows/30d |
|---|---------|--------------|-------------|---------------|
| 1 | R__BLAST_PLAN_EXECUTION_INCR.sql | DRILL_BLAST.BLAST_PLAN_EXECUTION | Composite (7 cols) | 149,489 |
| 2 | R__BLAST_PLAN_INCR.sql | DRILL_BLAST.BLAST_PLAN | BLAST_PLAN_SK | 39,277 |
| 3 | R__BL_DW_BLASTPROPERTYVALUE_INCR.sql | DRILL_BLAST.BL_DW_BLASTPROPERTYVALUE | ORIG_SRC_ID, SITE_CODE, BLASTID | 84 |
| 4 | R__BL_DW_BLAST_INCR.sql | DRILL_BLAST.BL_DW_BLAST | ORIG_SRC_ID, SITE_CODE, ID | 84 |
| 5 | R__BL_DW_HOLE_INCR.sql | DRILL_BLAST.BL_DW_HOLE | ORIG_SRC_ID, SITE_CODE, ID | 20,945 |
| 6 | R__DRILL_CYCLE_INCR.sql | DRILL_BLAST.DRILL_CYCLE | DRILL_CYCLE_SK | 45,985 |
| 7 | R__DRILL_PLAN_INCR.sql | DRILL_BLAST.DRILL_PLAN | DRILL_PLAN_SK | 56,723 |
| 8 | R__DRILLBLAST_EQUIPMENT_INCR.sql | DRILL_BLAST.DRILLBLAST_EQUIPMENT | ORIG_SRC_ID, SITE_CODE, DRILL_ID | 62 |
| 9 | R__DRILLBLAST_OPERATOR_INCR.sql | DRILL_BLAST.DRILLBLAST_OPERATOR | SYSTEM_OPERATOR_ID, SITE_CODE | 5,263 |
| 10 | R__DRILLBLAST_SHIFT_INCR.sql | DRILL_BLAST.DRILLBLAST_SHIFT | SITE_CODE, SHIFT_ID | 30,390 |
| 11 | R__LH_HAUL_CYCLE_INCR.sql | LOAD_HAUL.LH_HAUL_CYCLE | HAUL_CYCLE_ID | 528,156 |

---

## Estructura Estándar (OBLIGATORIA)

Todas las tablas DEBEN tener este header:

```sql
/*****************************************************************************************
* TABLE     : {TABLE_NAME}_INCR
* SCHEMA    : {{ envi }}_API_REF.FUSE
* SOURCE    : {{ RO_PROD }}_WG.{SCHEMA}.{TABLE_NAME}
* DATE: YYYY-MM-DD | AUTHOR: {NOMBRE}
******************************************************************************************/
create or replace TABLE {{ envi }}_API_REF.FUSE.{TABLE_NAME}_INCR (
    -- ═══════════════════════════════════════════════════════════
    -- COLUMNAS DEL SOURCE (copiar estructura de tabla origen)
    -- ═══════════════════════════════════════════════════════════
    COLUMN1 DATATYPE,
    COLUMN2 DATATYPE,
    ...
    
    -- ═══════════════════════════════════════════════════════════
    -- COLUMNAS DE AUDITORÍA (OBLIGATORIAS)
    -- ═══════════════════════════════════════════════════════════
    DW_LOGICAL_DELETE_FLAG VARCHAR(1) DEFAULT 'N',
    DW_LOAD_TS TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP(),
    DW_MODIFY_TS TIMESTAMP_NTZ(9) DEFAULT CURRENT_TIMESTAMP(),
    DW_ROW_HASH NUMBER(38,0)  -- Opcional, para optimización de MERGE
);
```

---

## Columnas de Auditoría

| Columna | Tipo | Default | Descripción |
|---------|------|---------|-------------|
| `DW_LOGICAL_DELETE_FLAG` | VARCHAR(1) | 'N' | 'Y' si el registro fue eliminado en origen |
| `DW_LOAD_TS` | TIMESTAMP_NTZ | CURRENT_TIMESTAMP() | Fecha/hora de inserción inicial |
| `DW_MODIFY_TS` | TIMESTAMP_NTZ | CURRENT_TIMESTAMP() | Fecha/hora de última modificación |
| `DW_ROW_HASH` | NUMBER(38,0) | NULL | Hash de columnas para optimizar MERGE |

---

## Template Variables

| Variable | Descripción | Valores |
|----------|-------------|---------|
| `{{ envi }}` | Ambiente destino | DEV, TEST, PROD |
| `{{ RO_PROD }}` | Ambiente origen (siempre PROD) | PROD |

---

## Naming Convention

- **Prefijo archivo:** `R__` (Flyway repeatable migration)
- **Sufijo tabla:** `_INCR` (incremental)
- **Schema:** `{{ envi }}_API_REF.FUSE`

---

## Deployment

```powershell
# Desde la raíz del proyecto
cd SQLRefactoring\Tickets\DRILLBLAST_INCR
python run_all_incr_scripts.py
```

Esto reemplaza `{{ envi }}` con `DEV` y ejecuta los 22 scripts.

---

## Author

Carlos Carrillo | 2026-01-23
