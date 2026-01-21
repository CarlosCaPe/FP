"""
Script para ver todos los objetos existentes en SNOWFLAKE_WG (DEV)
"""
from azure.identity import InteractiveBrowserCredential
import pyodbc
import struct

server = 'azwd22midbx02.eb8a77f2eea6.database.windows.net'
database = 'SNOWFLAKE_WG'

credential = InteractiveBrowserCredential()
token = credential.get_token('https://database.windows.net/.default')
token_bytes = token.token.encode('utf-16-le')
token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)

conn_str = f'Driver={{ODBC Driver 17 for SQL Server}};Server={server};Database={database}'
conn = pyodbc.connect(conn_str, attrs_before={1256: token_struct})
cursor = conn.cursor()

print('=' * 70)
print('OBJETOS EXISTENTES EN SNOWFLAKE_WG (DEV)')
print('=' * 70)

# Tables
print('\n📋 TABLES:')
cursor.execute("""
    SELECT TABLE_SCHEMA, TABLE_NAME 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_TYPE = 'BASE TABLE'
    ORDER BY TABLE_NAME
""")
for row in cursor.fetchall():
    print(f'  [{row[0]}].[{row[1]}]')

# Procedures
print('\n⚙️ STORED PROCEDURES:')
cursor.execute("""
    SELECT SCHEMA_NAME(schema_id), name 
    FROM sys.procedures
    ORDER BY name
""")
for row in cursor.fetchall():
    print(f'  [{row[0]}].[{row[1]}]')

# Table Types
print('\n📦 TABLE TYPES:')
cursor.execute("""
    SELECT SCHEMA_NAME(schema_id), name 
    FROM sys.table_types
    ORDER BY name
""")
for row in cursor.fetchall():
    print(f'  [{row[0]}].[{row[1]}]')

conn.close()
