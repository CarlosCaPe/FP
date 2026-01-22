"""
ADX Client for SENSOR_SNAPSHOT_GET equivalent
==============================================
Reemplaza las queries a SENSOR_READING_*_B de Snowflake con queries directas a ADX.

Cluster: fctsnaproddatexp01.westus2.kusto.windows.net
       (o fctsnaproddatexp02 según permisos)

Requiere:
    pip install azure-kusto-data azure-identity pandas

Uso:
    python adx_sensor_snapshot.py --site MOR --sensors "sensor1,sensor2"
"""

import argparse
from azure.identity import InteractiveBrowserCredential
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
import pandas as pd

# -----------------------------------------------------------------------------
# Configuración
# -----------------------------------------------------------------------------

# Cluster URL (cambiar si es necesario)
CLUSTER_URL = "https://fctsnaproddatexp02.westus2.kusto.windows.net"

# Mapeo de SITE_CODE a database de ADX
SITE_TO_DATABASE = {
    "SAM": "Miami",
    "MOR": "Morenci", 
    "CMX": "Climax",
    "SIE": "Sierrita",
    "NMO": "NewMexico",
    "BAG": "Bagdad",
    "CVE": "CerroVerde",
}


def get_kusto_client() -> KustoClient:
    """Create Kusto client with browser authentication (SSO)."""
    credential = InteractiveBrowserCredential()
    kcsb = KustoConnectionStringBuilder.with_azure_token_credential(
        CLUSTER_URL, credential
    )
    return KustoClient(kcsb)


def sensor_snapshot_get(
    client: KustoClient,
    site_code: str,
    sensor_ids: list[str],
    use_historical: bool = False,
    lookback_days: int = 30,
) -> pd.DataFrame:
    """
    Equivalente a PROD_API_REF.CONNECTED_OPERATIONS.SENSOR_SNAPSHOT_GET
    
    Args:
        client: KustoClient autenticado
        site_code: Código del sitio (MOR, BAG, SAM, etc.)
        sensor_ids: Lista de sensor_id (PI Point names)
        use_historical: Si True, usa FCTS con lookback. Si False, usa FCTSCURRENT.
        lookback_days: Días de lookback para histórico (default 30)
    
    Returns:
        DataFrame con columnas: TAG_NAME, VALUE_UTC_TS, SENSOR_VALUE, UOM, QUALITY
    """
    database = SITE_TO_DATABASE.get(site_code.upper())
    if not database:
        raise ValueError(f"Site code '{site_code}' no reconocido. Válidos: {list(SITE_TO_DATABASE.keys())}")
    
    # Escapar comillas en sensor_ids
    sensor_list = ", ".join([f"'{s}'" for s in sensor_ids])
    
    if use_historical:
        # Usar FCTS con summarize arg_max para obtener último valor
        query = f"""
        FCTS
        | where timestamp > ago({lookback_days}d)
        | where sensor_id in ({sensor_list})
        | summarize arg_max(timestamp, *) by sensor_id
        | project 
            TAG_NAME = sensor_id,
            VALUE_UTC_TS = timestamp,
            SENSOR_VALUE = tostring(value),
            UOM = unit,
            QUALITY = quality
        """
    else:
        # Usar FCTSCURRENT (snapshot directo, más eficiente)
        query = f"""
        FCTSCURRENT
        | where sensor_id in ({sensor_list})
        | project 
            TAG_NAME = sensor_id,
            VALUE_UTC_TS = timestamp,
            SENSOR_VALUE = tostring(value),
            UOM = uom,
            QUALITY = quality
        """
    
    print(f"Executing query on {database}...")
    print(f"Query:\n{query}\n")
    
    response = client.execute(database, query)
    
    # Convertir a DataFrame
    rows = []
    for row in response.primary_results[0]:
        rows.append({
            "TAG_NAME": row["TAG_NAME"],
            "VALUE_UTC_TS": row["VALUE_UTC_TS"],
            "SENSOR_VALUE": row["SENSOR_VALUE"],
            "UOM": row["UOM"],
            "QUALITY": row["QUALITY"],
        })
    
    return pd.DataFrame(rows)


def main():
    parser = argparse.ArgumentParser(
        description="Query ADX FCTSCURRENT (equivalent to SENSOR_SNAPSHOT_GET)"
    )
    parser.add_argument(
        "--site", "-s",
        required=True,
        choices=list(SITE_TO_DATABASE.keys()),
        help="Site code"
    )
    parser.add_argument(
        "--sensors", "-n",
        required=True,
        help="Lista de sensor_id separados por coma"
    )
    parser.add_argument(
        "--historical", "-H",
        action="store_true",
        help="Usar FCTS (histórico) en vez de FCTSCURRENT (snapshot)"
    )
    parser.add_argument(
        "--lookback", "-l",
        type=int,
        default=30,
        help="Días de lookback para histórico (default: 30)"
    )
    parser.add_argument(
        "--output", "-o",
        help="Archivo de salida CSV (opcional)"
    )
    
    args = parser.parse_args()
    
    sensor_ids = [s.strip() for s in args.sensors.split(",")]
    
    print(f"Site: {args.site} → Database: {SITE_TO_DATABASE[args.site]}")
    print(f"Sensors: {sensor_ids}")
    print(f"Mode: {'Historical (FCTS)' if args.historical else 'Snapshot (FCTSCURRENT)'}")
    print()
    
    client = get_kusto_client()
    
    df = sensor_snapshot_get(
        client,
        args.site,
        sensor_ids,
        use_historical=args.historical,
        lookback_days=args.lookback,
    )
    
    print(f"\nResultados: {len(df)} filas")
    print(df.to_string(index=False))
    
    if args.output:
        df.to_csv(args.output, index=False)
        print(f"\nGuardado en: {args.output}")


if __name__ == "__main__":
    main()
