"""
Ver columnas de LH_BUCKET y LH_LOADING_CYCLE para identificar PKs
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

tables = ['LOAD_HAUL__LH_BUCKET', 'LOAD_HAUL__LH_LOADING_CYCLE']

for table in tables:
    print('=' * 60)
    print(f'COLUMNAS DE {table}')
    print('=' * 60)
    
    cursor.execute(f"""
        SELECT COLUMN_NAME, DATA_TYPE 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = '{table}' AND TABLE_SCHEMA = 'dbo'
        ORDER BY ORDINAL_POSITION
    """)
    
    for i, row in enumerate(cursor.fetchall(), 1):
        pk_hint = ' <-- PK?' if 'SK' in row[0] or 'ID' in row[0] or 'KEY' in row[0] else ''
        print(f'{i:2}. {row[0]:45} {row[1]}{pk_hint}')
    print()

conn.close()
