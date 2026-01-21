"""
Discovery de databases en ADX - Prueba diferentes nombres
"""
from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.identity import InteractiveBrowserCredential

CLUSTER = "https://fctsnaproddatexp01.westus2.kusto.windows.net"

# Posibles nombres de databases
POSSIBLE_DBS = [
    "Global",
    "BAG", "Bagdad", "Bagdad (BAG)",
    "MOR", "Morenci", "Morenci (MOR)",
    "SAM", "Safford", "Miami", "Safford (SAM)",
    "SIE", "Sierrita", "Sierrita (SIE)",
    "NMO", "Tyrone", "Tyrone (NMO)",
    "CMX", "Chino", "Cobre", "Chino (CMX)",
    "CVE", "CerroVerde", "Cerro Verde", "CerroVerde (CVE)",
    "FCTS",
    "fcts",
    "global",
]

print(f"Connecting to: {CLUSTER}")
credential = InteractiveBrowserCredential()
kcsb = KustoConnectionStringBuilder.with_azure_token_credential(CLUSTER, credential)
client = KustoClient(kcsb)

print("\nProbando conexión a diferentes databases...")
print("=" * 60)

for db in POSSIBLE_DBS:
    try:
        # Intenta un query simple
        result = client.execute(db, "print 'ok'")
        rows = list(result.primary_results[0])
        print(f"✅ {db}: ACCESO OK")
    except Exception as e:
        err = str(e)
        if "not authorized" in err.lower():
            print(f"🔒 {db}: Existe pero sin permiso")
        elif "not found" in err.lower():
            print(f"❌ {db}: No existe")
        else:
            print(f"⚠️ {db}: {err[:60]}")
