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
