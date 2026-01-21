# KQL / Azure Data Explorer (ADX)

Herramientas para consultar el cluster ADX de FCTS.

## Cluster Info

| Propiedad | Valor |
|-----------|-------|
| **Cluster** | `fctsnaproddatexp01` |
| **URL** | `https://fctsnaproddatexp01.westus2.kusto.windows.net` |
| **Subscription** | NA Production |
| **Acceso** | Contactar a **Chris Martin** para permisos |

## Databases por Sitio

| Sitio | Database | Tablas Principales |
|-------|----------|-------------------|
| Bagdad | `BAG` | FCTS, FCTSCURRENT |
| Sierrita | `SIE` | FCTS, FCTSCURRENT |
| Morenci | `MOR` | FCTS, FCTSCURRENT |
| Safford/Miami | `SAM` | FCTS, FCTSCURRENT |
| Cerro Verde | `CVE` | FCTS, FCTSCURRENT |
| Chino/Cobre | `CMX` | FCTS, FCTSCURRENT |
| Tyrone | `NMO` | FCTS, FCTSCURRENT |
| Global | `Global` | RegistryStreams |

## Tablas Principales

| Tabla | Descripción | Uso |
|-------|-------------|-----|
| `FCTS` | Historical data (archive) | Datos históricos por timestamp |
| `FCTSCURRENT` | Current value (snapshot) | Último valor por sensor |
| `RegistryStreams` | Stream registry | Lookup de streams/sensors |

## Queries de Ejemplo

### Current Value (Snapshot)
```kql
database('BAG').FCTSCURRENT
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

### Historical Data (últimos 180 días)
```kql
database('BAG').FCTS
| where timestamp > ago(180d)
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

### Stream Registry Lookup
```kql
database('Global').RegistryStreams
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

## Scripts

### `adx_browser.py` (Browser auth - recomendado)
```powershell
cd KQL\scripts
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_browser.py list-dbs
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_browser.py list-tables --db BAG
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_browser.py sample --db BAG --table FCTS --limit 5
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_browser.py query --db BAG --kql "FCTSCURRENT | take 10"
```

### `adx_discovery.py` (Device code auth - legacy)
```powershell
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_discovery.py list-dbs
```

## Contexto: Migración FCTS

Las tablas `SENSOR_READING_*_B` en Snowflake (`PROD_DATALAKE.FCTS`) están siendo reemplazadas por ADX:

| Snowflake (OLD) | ADX (NEW) |
|-----------------|-----------|
| `PROD_DATALAKE.FCTS.SENSOR_READING_BAG_B` | `database('BAG').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_MOR_B` | `database('MOR').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_SAM_B` | `database('SAM').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_SIE_B` | `database('SIE').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_NMO_B` | `database('NMO').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_CMX_B` | `database('CMX').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_CVE_B` | `database('CVE').FCTS` |

### Beneficio
Las tablas Snowflake tienen problemas de scan (sin clustering key):
- `SENSOR_READING_MOR_B`: 3.16 TB / 292K partitions → ADX resuelve esto
- `SENSOR_READING_NMO_B`: 269 GB / 34K partitions → ADX resuelve esto

## Dependencias

```powershell
pip install azure-kusto-data azure-identity
```

## Troubleshooting

### "No tienes acceso"
1. Levanta ticket en [Application Access](https://login.microsoftonline.com/...)
2. Contacta a **Chris Martin** para que asigne permisos al grupo correcto

### "Timed out waiting for authentication"
- Asegúrate de completar el login en el browser popup
- Si no se abre, revisa bloqueadores de popups

## Contactos

| Rol | Persona |
|-----|---------|
| ADX Admin / Permisos | Chris Martin |
| Info sobre tablas | Héctor Solís |
