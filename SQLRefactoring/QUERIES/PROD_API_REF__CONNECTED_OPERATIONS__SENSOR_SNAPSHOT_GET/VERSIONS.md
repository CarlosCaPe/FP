# SENSOR_SNAPSHOT_GET - 3 Versions

Este directorio contiene 3 versiones de la función `SENSOR_SNAPSHOT_GET` para comparar rendimiento durante la migración de Snowflake a ADX.

## Versiones

| # | Versión | Archivo | Plataforma | Estado |
|---|---------|---------|------------|--------|
| 1 | **Baseline** | `baseline_ddl.sql` | Snowflake | ✅ Producción actual |
| 2 | **Refactor** | `refactor_ddl.sql` | Snowflake | ✅ Optimizado (sandbox) |
| 3 | **ADX Function** | `adx_function.kql` | Azure Data Explorer | 🔄 Para migración |

## Firma (todas las versiones)

**Input:**
```
SENSOR_SNAPSHOT_GET(
    site_code: VARCHAR(3),        -- 'MOR', 'BAG', 'SAM', etc.
    is_af_path_flag: BOOLEAN,     -- TRUE = AF Path, FALSE = PI Point
    attribute_path_list: ARRAY,   -- Lista de AF paths (si is_af_path_flag=TRUE)
    pi_point_list: ARRAY          -- Lista de PI points (si is_af_path_flag=FALSE)
)
```

**Output (5 columnas, mismas en todas las versiones):**
```
TAG_NAME       VARCHAR   -- Nombre del sensor/tag
VALUE_UTC_TS   TIMESTAMP -- Timestamp del último valor
SENSOR_VALUE   VARCHAR   -- Valor del sensor
UOM            VARCHAR   -- Unidad de medida
QUALITY        VARCHAR   -- Calidad del dato
```

## Comparación Técnica

### Version 1: Baseline (Snowflake Original)

**Archivo:** `baseline_ddl.sql`

**Problema:**
- UNION de 7 tablas `SENSOR_READING_*_B`
- Escanea ~52 GB aunque solo necesite 1 tabla
- Subquery correlacionado para `MAX(VALUE_UTC_TS)`

**Uso:**
```sql
SELECT * FROM TABLE(PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET(
    'MOR', FALSE, ARRAY_CONSTRUCT(''), 
    ARRAY_CONSTRUCT('sensor1', 'sensor2')
));
```

---

### Version 2: Refactor (Snowflake Optimizado)

**Archivo:** `refactor_ddl.sql`

**Mejoras:**
- `IDENTIFIER(CASE...)` para seleccionar solo 1 tabla
- `QUALIFY RANK()` en vez de subquery
- Parámetro `PARAM_LOOKBACK_DAYS` opcional
- Wrapper 4-args para compatibilidad

**Reducción esperada:**
- Bytes: ~52 GB → ~7 GB (85% menos)
- Tiempo: ~40s → ~10s (75% más rápido)

**Uso:**
```sql
-- 4 args (compatible con baseline)
SELECT * FROM TABLE(SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET(
    'MOR', FALSE, ARRAY_CONSTRUCT(''), 
    ARRAY_CONSTRUCT('sensor1', 'sensor2')
));

-- 5 args (con lookback personalizado)
SELECT * FROM TABLE(SANDBOX_DATA_ENGINEER.CCARRILL2.SENSOR_SNAPSHOT_GET(
    'MOR', FALSE, ARRAY_CONSTRUCT(''), 
    ARRAY_CONSTRUCT('sensor1', 'sensor2'),
    7  -- solo últimos 7 días
));
```

---

### Version 3: ADX Function

**Archivo:** `adx_function.kql`

**Ventajas:**
- `FCTSCURRENT` ya tiene el último valor (no necesita window)
- Datos en tiempo real vs batch de Snowflake
- Sin escaneo de histórico

**Mapeo de databases:**
| Site Code | ADX Database |
|-----------|--------------|
| SAM | Miami |
| MOR | Morenci |
| CMX | Climax |
| SIE | Sierrita |
| NMO | NewMexico |
| BAG | Bagdad |
| CVE | CerroVerde |

**Uso (KQL):**
```kql
let sensor_list = dynamic(['sensor1', 'sensor2']);
database('Morenci').FCTSCURRENT
| where sensor_id in (sensor_list)
| project 
    TAG_NAME = sensor_id,
    VALUE_UTC_TS = timestamp,
    SENSOR_VALUE = tostring(value),
    UOM = unit,
    QUALITY = quality
```

**Uso (Python):**
```python
python adx_sensor_snapshot.py --site MOR --sensors "sensor1,sensor2"
```

---

## Regression Test

**Script:** `regression_test.py`

Ejecuta las 3 versiones y compara:
- ⏱️ Tiempos de ejecución
- 📊 Columnas (deben ser iguales)
- 📈 Row counts (pueden variar por timing)

**Uso:**
```bash
# Comparar las 3 versiones
python regression_test.py --site MOR --sensors "CR03_CRUSH_OUT_TIME,PE_MOR_CC_MflPileTonnage"

# Solo Snowflake (si no hay acceso a ADX)
python regression_test.py --site MOR --sensors "sensor1,sensor2" --skip-adx

# Solo Refactor vs ADX (si baseline es muy lento)
python regression_test.py --site MOR --sensors "sensor1,sensor2" --skip-baseline
```

**Output esperado:**
```
## Timing Comparison
| Version              | Time    | Rows |
|:---------------------|:--------|:-----|
| 1. Baseline (SF)     | 43.277s | 4    |
| 2. Refactor (SF)     | 8.521s  | 4    |
| 3. ADX Function      | 0.342s  | 4    |

## Speedup Analysis
- Refactor vs Baseline: 5.08x faster
- ADX vs Baseline: 126.54x faster
- ADX vs Refactor: 24.91x faster

## Schema Comparison
- All schemas match: ✅ YES
```

---

## Archivos en este directorio

| Archivo | Descripción |
|---------|-------------|
| `baseline_ddl.sql` | DDL original de producción |
| `baseline.sql` | Query de ejemplo para baseline |
| `refactor_ddl.sql` | DDL optimizado para sandbox |
| `refactor_ddl_dev.sql` | Versión DEV del refactor |
| `refactor.sql` | Query de ejemplo para refactor |
| `adx_function.kql` | Definición de función KQL en ADX |
| `adx_equivalent.kql` | Queries KQL equivalentes (ejemplos) |
| `adx_sensor_snapshot.py` | Cliente Python para ADX |
| `regression_test.py` | Script de comparación de las 3 versiones |
| `FINDINGS.md` | Hallazgos de performance |
| `VERSIONS.md` | Este archivo |
| `config.yml` | Configuración para snowrefactor |
| `signature.txt` | Firma de la función |

---

## Plan de Migración

1. ✅ **Fase 1**: Optimizar en Snowflake (refactor_ddl.sql)
2. 🔄 **Fase 2**: Validar ADX function (adx_function.kql)
3. 📋 **Fase 3**: Notificar a consumidores (equipo IROC)
4. 📋 **Fase 4**: Deprecar tablas `SENSOR_READING_*_B` en Snowflake

**Contacto ADX:** Héctor Solís, Chris Martin (permisos)
