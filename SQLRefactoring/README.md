# Snowflake Query Refactor Regression Harness (Snowrefactor)

Herramienta en Python para refactorizar SQL de Snowflake con validación de regresión (baseline vs refactor) y reportes “PM-friendly”.

Este repositorio tiene dos partes:

- `QUERIES/`: carpetas de trabajo por query/view (baseline/refactor/config).
- `tools/`: proyecto Python instalable que expone el CLI `snowrefactor`.

## Estructura de un query

Cada query/view vive en `QUERIES/<name>/`:

- `baseline.sql`  → query original (baseline)
- `refactor.sql`  → query refactorizada
- `config.yml`    → (opcional) metadata de comparación (PK, order_by, limits, tolerancias, ignore_columns, etc.)

Ejemplo: `QUERIES/example_query/`.

## Quickstart (Windows / PowerShell)

El CLI está definido en `tools/` (ver `tools/pyproject.toml`).

```powershell
cd .\tools
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -U pip
pip install -e .
cd ..
```

Notas:
- Recomendado: ejecuta `snowrefactor` desde `SQLRefactoring/` (este nivel). Así los defaults funcionan: `./QUERIES` y `./reports`.
- Si ejecutas desde `tools/`, entonces sí tendrás que pasar `--queries-dir ..\\QUERIES` y `--reports-dir ..\\reports`.

## Variables de entorno (Snowflake)

La conexión lee variables de entorno y también un archivo `.env` si existe.

- Recomendación: mantén tu `.env` en `SQLRefactoring/.env` (raíz de este subproyecto).
- `python-dotenv` busca `.env` desde el directorio actual hacia arriba.

Variables esperadas:

- `CONN_LIB_SNOWFLAKE_ACCOUNT`
- `CONN_LIB_SNOWFLAKE_USER`
- `CONN_LIB_SNOWFLAKE_ROLE`
- `CONN_LIB_SNOWFLAKE_WAREHOUSE`
- `CONN_LIB_SNOWFLAKE_DATABASE`
- `CONN_LIB_SNOWFLAKE_SCHEMA`

Opcionales:

- `CONN_LIB_SNOWFLAKE_PASSWORD` (si no usas SSO/externalbrowser)
- `CONN_LIB_SNOWFLAKE_AUTHENTICATOR` (ej. `externalbrowser`)

## Flujo recomendado (Producción vs Sandbox)

1) Genera baseline y edita `refactor.sql` para que sea equivalente pero más eficiente.

Guía de estilo (dbt-like): CTEs en capas `src_*` → `int_*` → `agg_*` → `final_*`.

2) Crea una NUEVA view en tu sandbox (no toca producción):

```powershell
snowrefactor deploy-view PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL
```

La view se crea/actualiza en el `CONN_LIB_SNOWFLAKE_DATABASE.CONN_LIB_SNOWFLAKE_SCHEMA` configurado en tus variables.

3) Compara resultados entre views (baseline vs sandbox):

```powershell
snowrefactor compare-views PROD_API_REF.CONNECTED_OPERATIONS.CR2_MILL SANDBOX_DATA_ENGINEER.CCARRILL2.CR2_MILL
```

Ignorar columnas volátiles (por ejemplo, timestamps):

```powershell
snowrefactor compare-views PROD_API_REF.CONNECTED_OPERATIONS.CR2_MILL SANDBOX_DATA_ENGINEER.CCARRILL2.CR2_MILL --ignore-columns UTC_CREATED_DATE
```

4) Regresión completa (DDL + DML):

```powershell
snowrefactor regress-view PROD_API_REF.CONNECTED_OPERATIONS.CR2_MILL SANDBOX_DATA_ENGINEER.CCARRILL2.CR2_MILL --ignore-columns UTC_CREATED_DATE
```

## Comandos útiles

### Scaffold de baseline desde una View (GET_DDL + SELECT *)

```powershell
snowrefactor pull-ddl PROD_API_REF.CONNECTED_OPERATIONS.CR2_MILL
```

Esto crea una carpeta con nombre “safe” reemplazando `.` con `__`, por ejemplo:
`PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL/`

Dentro típicamente:
- `baseline_ddl.sql` (GET_DDL)
- `baseline.sql` (SELECT * FROM la view actual)
- `refactor.sql` (arranca igual, luego lo editas)

### Comparar baseline.sql vs refactor.sql (por carpeta)

```powershell
snowrefactor compare PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL
```

### Analizar performance (EXPLAIN + métricas de query history)

```powershell
snowrefactor analyze PROD_API_REF__CONNECTED_OPERATIONS__CR2_MILL
```

### Buscar dependencias aguas abajo

```powershell
snowrefactor downstream "PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET"
```

## Funciones (opcional)

También hay soporte para functions:

- `snowrefactor pull-function <db>.<schema>.<function> --queries-dir ...`
- `snowrefactor deploy-function <folder> --queries-dir ...`

## Reportes

Por defecto (si ejecutas desde `SQLRefactoring/`), los reportes se escriben en `reports/` y se generan como `.md` / `.json` / `.txt` según el comando.

---

## 🔌 Conexiones y Credenciales

### Snowflake (.env)

El archivo `.env` en la raíz de `SQLRefactoring/` contiene las credenciales de Snowflake:

```bash
# Required
CONN_LIB_SNOWFLAKE_ACCOUNT=FCX-NA
CONN_LIB_SNOWFLAKE_USER=CCARRILL2@FMI.COM

# Recommended
CONN_LIB_SNOWFLAKE_ROLE=SG-AZW-SFLK-ENG-GENERAL
CONN_LIB_SNOWFLAKE_WAREHOUSE=WH_FCTS
CONN_LIB_SNOWFLAKE_DATABASE=SANDBOX_DATA_ENGINEER
CONN_LIB_SNOWFLAKE_SCHEMA=CCARRILL2

# Auth (SSO via browser)
CONN_LIB_SNOWFLAKE_AUTHENTICATOR=externalbrowser
```

> ⚠️ **NOTA**: Este archivo está en `.gitignore` y NO se commitea.

### SQL Azure (Scripts Python)

Los scripts en `../SQLAzure/scripts/` usan Azure AD authentication:

```python
from azure.identity import InteractiveBrowserCredential
import pyodbc, struct

# DEV
server = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
# TEST  
server = "azwt22midbx02.78e6dac10b16.database.windows.net"
# PROD
server = "azwp22midbx02.2a5d8efd6e55.database.windows.net"

# Databases disponibles:
# - ConnectedOperations  (para CONNECTED_OPERATIONS functions)
# - SNOWFLAKE_WG         (para DRILL_BLAST y LOAD_HAUL functions)
```

### Databases por Función

| Domain | Database | Connection String |
|--------|----------|-------------------|
| CONNECTED_OPERATIONS | ConnectedOperations | `CONOPS_CO_*_SQL_CONN_STR` |
| DRILL_BLAST | SNOWFLAKE_WG | `CONOPS_WG_DRILL_BLAST_SQL_CONN_STR` |
| LOAD_HAUL | SNOWFLAKE_WG | `CONOPS_WG_LOAD_HAUL_SQL_CONN_STR` |

### Notas Importantes

1. **Python 3.12 para Snowflake**: El connector `snowflake-connector-python` no tiene wheels para Python 3.14. Usar el venv312:
   ```powershell
   C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe <script.py>
   ```

2. **Python 3.14 para SQL Azure**: Los scripts de Azure funcionan con cualquier Python si tienen `azure-identity` y `pyodbc`.

3. **Autenticación**: Ambas plataformas usan browser SSO (externalbrowser para Snowflake, InteractiveBrowserCredential para Azure).

4. **Memory Optimized Tables (Vikas Uttam)**:
   - **DEV**: `MEMORY_OPTIMIZED = OFF` ❌
   - **PROD**: `MEMORY_OPTIMIZED = ON` ✅
   
   Al crear tablas en DEV, NO usar memory optimized. Solo habilitarlo en PROD.

---

## 📋 Patrones de Refactoring (Copilot Memory)

Esta sección documenta patrones comunes para que Copilot los recuerde en futuras sesiones.

### Table Functions que escanean múltiples tablas por sitio

**Problema típico**: Una table function recibe un parámetro `SITE_CODE` pero hace UNION de N tablas `*_SITE_B`, escaneando todas aunque solo una aplique.

**Ejemplo**: `SENSOR_SNAPSHOT_GET` escaneaba 7 tablas `SENSOR_READING_*_B` (~52 GB) aunque solo necesitara una (~7 GB).

**Solución Snowflake - IDENTIFIER() dinámico**:

```sql
-- Usar IDENTIFIER() con CASE para seleccionar dinámicamente la tabla
FROM IDENTIFIER(
  CASE UPPER(PARAM_SITE_CODE)
    WHEN 'SAM' THEN 'PROD_DATALAKE.FCTS.SENSOR_READING_SAM_B'
    WHEN 'MOR' THEN 'PROD_DATALAKE.FCTS.SENSOR_READING_MOR_B'
    WHEN 'CMX' THEN 'PROD_DATALAKE.FCTS.SENSOR_READING_CMX_B'
    -- ... etc
  END
) raw
```

**Beneficios**:
- Solo escanea la tabla del sitio solicitado
- Snowflake evalúa el CASE en tiempo de compilación
- Reducción de ~85% en bytes escaneados

### Obtener el último registro por entidad (snapshot)

**Problema típico**: Subquery correlacionado `WHERE (id, ts) IN (SELECT id, MAX(ts) FROM ... GROUP BY id)` que fuerza doble escaneo.

**Solución - QUALIFY con RANK/ROW_NUMBER**:

```sql
SELECT *
FROM readings
WHERE value_utc_ts > DATEADD('day', -30, CURRENT_TIMESTAMP())
QUALIFY RANK() OVER (PARTITION BY sensor_id ORDER BY value_utc_ts DESC) = 1
```

**Notas**:
- `RANK()` si hay ties y quieres todos los empates
- `ROW_NUMBER()` si quieres exactamente 1 registro por partición
- Una sola pasada sobre los datos vs doble escaneo

### Wrapper para compatibilidad hacia atrás

**Patrón**: Agregar parámetros opcionales sin romper callers existentes.

```sql
-- Función principal con nuevo parámetro
CREATE OR REPLACE FUNCTION my_func(param1, param2, new_param NUMBER)
RETURNS TABLE (...) AS '...';

-- Wrapper que mantiene la firma original
CREATE OR REPLACE FUNCTION my_func(param1, param2)
RETURNS TABLE (...) AS '
  SELECT * FROM TABLE(my_func(param1, param2, 30))  -- default value
';
```

### Guía de estilo CTEs (dbt-like)

```sql
WITH 
-- src_* : fuentes raw, parámetros parseados
src_params AS (...),
src_readings AS (...),

-- int_* : transformaciones intermedias, joins, filtros
int_filtered AS (...),
int_latest AS (...),

-- agg_* : agregaciones
agg_summary AS (...),

-- final : output limpio
final AS (...)

SELECT * FROM final;
```

---

## 🔍 Casos de Estudio

### SENSOR_SNAPSHOT_GET (PROD_API_REF.CONNECTED_OPERATIONS)

**Ubicación**: `QUERIES/PROD_API_REF__CONNECTED_OPERATIONS__SENSOR_SNAPSHOT_GET/`

**Baseline problems**:
1. UNION de 7 tablas `SENSOR_READING_*_B` (~52 GB escaneados)
2. Subquery correlacionado para `MAX(VALUE_UTC_TS)`
3. Lookback hardcoded a 30 días

**Refactor solutions**:
1. `IDENTIFIER(CASE...)` para selección dinámica de tabla
2. `QUALIFY RANK()` para snapshot en una pasada
3. Parámetro `PARAM_LOOKBACK_DAYS` con wrapper 4-args para compatibilidad

**Archivos**:
- `baseline_ddl.sql` - DDL original de producción
- `refactor_ddl.sql` - DDL refactorizado (sandbox)
- `refactor_ddl_dev.sql` - Versión para deploy a SANDBOX_DATA_ENGINEER

**Regression test**:
```powershell
# Comparar output de ambas funciones
snowrefactor compare-views \
  "TABLE(PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET('MOR', FALSE, ...))" \
  "TABLE(SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET('MOR', FALSE, ...))"
```

**ADX Future Migration**:
- Las tablas `SENSOR_READING_*_B` están siendo deprecadas
- ADX cluster: `fctsnaproddatexp02.westus2.kusto.windows.net`
- Cada sitio tiene su database (Morenci, Bagdad, etc.) con función `FCTSCURRENT()`
- `FCTSCURRENT()` ya devuelve el último valor por sensor (no necesita ventana de 30 días)

---

## 🗂️ ADX Semantic Model

El modelo semántico unificado para operaciones mineras está en [`adx_semantic_models/ADX_UNIFIED.semantic.yaml`](adx_semantic_models/ADX_UNIFIED.semantic.yaml).

### Estructura

| Componente | Contenido |
|------------|-----------|
| **version** | 4.0 |
| **connections** | Snowflake (FCX-NA) + ADX (fctsnaproddatexp02) |
| **outcome_definitions** | 16 métricas de negocio con description, unit, sensible_range |
| **sites** | 7 independientes (MOR, BAG, SAM, CMX, SIE, NMO, CVE) |
| **outcomes per site** | 16 cada uno con query + sample_data real validado |
| **cross_site_queries** | 3 queries comparativos |
| **column_mappings** | Referencia Snowflake + ADX |
| **usage_examples** | Python para ambas fuentes |

### Los 16 Business Outcomes

| # | Outcome | Section | Source |
|---|---------|---------|--------|
| 01 | Dig compliance (%) | Loading | Snowflake |
| 02 | Dig rate (TPOH) | Loading | Snowflake |
| 03 | Priority shovels | Loading | Snowflake |
| 04 | Number of trucks | Haulage | Snowflake |
| 05 | Cycle Time (min) | Haulage | Snowflake |
| 06 | Asset Efficiency | Haulage | Snowflake |
| 07 | Dump compliance (%) | Haulage | Snowflake |
| 08 | Mill tons delivered | Mill | Snowflake |
| 09 | Mill Crusher Rate | Mill | ADX |
| 10 | Mill Rate (TPOH) | Mill | ADX |
| 11 | Mill Strategy (IOS) | Mill | ADX |
| 12 | MFL tons delivered | MFL | Snowflake |
| 13 | MFL Crusher Rate | MFL | ADX |
| 14 | MFL FOS Rate | MFL | ADX |
| 15 | MFL Strategy | MFL | ADX |
| 16 | ROM tons delivered | ROM | Snowflake |

### Validación

```powershell
python tools\scripts\validate_semantic_model.py
```

### Archivos Relacionados

- [`KPI_ADX_MAPPING_ANALYSIS.md`](KPI_ADX_MAPPING_ANALYSIS.md) - Análisis de mapeo KPI → ADX
- [`adx_snapshots/`](adx_snapshots/) - Snapshots de estructura por database
- [`reports/semantic_model_complete.json`](reports/semantic_model_complete.json) - Backup JSON
