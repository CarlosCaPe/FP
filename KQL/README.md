# KQL / Azure Data Explorer (ADX)

Herramientas para consultar los clusters ADX de FCTS.

## Clusters

| Cluster | URL | Uso |
|---------|-----|-----|
| **fctsnaproddatexp02** | `https://fctsnaproddatexp02.westus2.kusto.windows.net` | ✅ Principal (App Integration) |
| fctsnaproddatexp01 | `https://fctsnaproddatexp01.westus2.kusto.windows.net` | FCTS Raw Data (requiere permisos adicionales) |

## Databases en fctsnaproddatexp02

| Database | Descripción |
|----------|-------------|
| **AppIntegration** | Funciones de integración |
| **Global** | Registry global |
| Bagdad | Sitio BAG |
| Morenci | Sitio MOR |
| Sierrita | Sitio SIE |
| Miami | Sitio SAM |
| Safford | Sitio |
| CerroVerde | Sitio CVE |
| NewMexico | Sitio NMO |
| Climax | Sitio CMX |
| Henderson | Sitio |
| ElPaso | Sitio |
| ElAbra | Sitio |
| Huelva | Sitio |
| Rotterdam | Sitio |
| FtMadison | Sitio |
| Stowmarket | Sitio |
| NAMEM | Regional |
| SAMEM | Regional |
| TechCenter | Tech |

## Funciones en AppIntegration

| Función | Descripción |
|---------|-------------|
| `AcidTankLevels` | Niveles de tanques de ácido |
| `HaulTruck` | Datos de camiones |
| `HaulTruck_DEV` | Versión desarrollo |
| `Morenci_Batman_BallMill_Aggregates` | Agregados Ball Mill |
| `Morenci_Batman_Section_Aggregates` | Agregados por sección |
| `Morenci_Batman_Mill_Overview` | Overview del mill |
| `ConSmelter_GetCastingSpeed` | Velocidad de casting |

## Queries de Ejemplo

### Llamar una función
```kql
AppIntegration.AcidTankLevels()
| take 10
```

### Current Value (Snapshot)
```kql
database('Bagdad').FCTSCURRENT
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

### Historical Data
```kql
database('Bagdad').FCTS
| where timestamp > ago(180d)
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

### Stream Registry Lookup
```kql
database('Global').RegistryStreams
| where sensor_id == "BAG-REPT_CLP_CYANEX_VOL"
```

## Scripts

```powershell
cd C:\Users\ccarrill2\Documents\repos\FP\KQL\scripts

# Discovery del cluster
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe discover_cluster02.py

# Query ad-hoc
C:\Users\ccarrill2\Documents\repos\FP\.venv312\Scripts\python.exe adx_browser.py query --cluster https://fctsnaproddatexp02.westus2.kusto.windows.net --db AppIntegration --kql "AcidTankLevels() | take 5"
```

## Conexión desde Azure Data Explorer Web

Abrir directamente en el navegador:
- https://dataexplorer.azure.com/clusters/fctsnaproddatexp02.westus2/databases/AppIntegration

## Contexto: Migración FCTS

Las tablas `SENSOR_READING_*_B` en Snowflake (`PROD_DATALAKE.FCTS`) serán reemplazadas por ADX:

| Snowflake (OLD) | ADX (NEW) |
|-----------------|-----------|
| `PROD_DATALAKE.FCTS.SENSOR_READING_BAG_B` | `database('Bagdad').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_MOR_B` | `database('Morenci').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_SAM_B` | `database('Miami').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_SIE_B` | `database('Sierrita').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_NMO_B` | `database('NewMexico').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_CMX_B` | `database('Climax').FCTS` |
| `PROD_DATALAKE.FCTS.SENSOR_READING_CVE_B` | `database('CerroVerde').FCTS` |

## Dependencias

```powershell
pip install azure-kusto-data azure-identity
```

## Acceso

- **Grupo:** `SG-ENT-FCTS-ADX-Viewer`
- **Ticket:** RITM0569765 (aprobado)
- **Admin:** Chris Martin

## Contactos

| Rol | Persona |
|-----|---------|
| ADX Admin / Permisos | Chris Martin |
| Info sobre tablas | Héctor Solís |
