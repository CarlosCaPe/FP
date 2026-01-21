"""
Script para ELIMINAR el DRILL_CYCLE_IMO incorrecto de ConnectedOperations.

Fue creado por error en ConnectedOperations cuando debía estar en SNOWFLAKE_WG.
El correcto ya existe en SNOWFLAKE_WG.
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

server = "azwd22midbx02.eb8a77f2eea6.database.windows.net"
database = "ConnectedOperations"  # La base INCORRECTA donde lo creamos por error

credential = InteractiveBrowserCredential()
token = credential.get_token("https://database.windows.net/.default")
token_bytes = token.token.encode("utf-16-le")
token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)

conn_str = f"Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}"
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

# Verificar que existe antes de borrar
cursor.execute("SELECT name FROM sys.table_types WHERE name = 'DRILL_CYCLE_IMO'")
if cursor.fetchone():
    cursor.execute("DROP TYPE [dbo].[DRILL_CYCLE_IMO]")
    conn.commit()
    print("✅ ELIMINADO: [dbo].[DRILL_CYCLE_IMO] de ConnectedOperations")
else:
    print("ℹ️ No existía DRILL_CYCLE_IMO en ConnectedOperations")

# Verificar Table Types IMO restantes
cursor.execute("SELECT name FROM sys.table_types WHERE name LIKE '%IMO%'")
remaining = cursor.fetchall()
print(f"\nTable Types *_IMO restantes en ConnectedOperations: {len(remaining)}")
for r in remaining:
    print(f"  - {r[0]}")

conn.close()
print("\n✅ Limpieza completada!")
