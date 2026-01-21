"""
SQL Azure Database Schema Extractor
Uses sqlcmd with Azure AD authentication
Run this after connecting manually once
"""
import subprocess
import os
from pathlib import Path
from datetime import datetime

# SQL Azure servers
SERVERS = [
    {
        "name": "DEV",
        "server": "azwd22midbx02.eb8a77f2eea6.database.windows.net",
    },
    {
        "name": "TEST", 
        "server": "azwt22midbx02.9959d3e6fe6e.database.windows.net",
    },
    {
        "name": "PROD",
        "server": "azwp22midbx02.8232c56adfdf.database.windows.net",
    }
]

BASE_DIR = Path(__file__).parent

def run_sql(server: str, database: str, query: str):
    """Run SQL using sqlcmd with Azure AD auth"""
    cmd = [
        "sqlcmd",
        "-S", server,
        "-d", database,
        "-G",  # Azure AD auth
        "-Q", query,
        "-W",  # Remove trailing spaces
        "-h", "-1",  # No headers
        "-s", "|"  # Column separator
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise Exception(result.stderr)
    return result.stdout.strip().split('\n')

def main():
    print("=" * 80)
    print("SQL Azure Schema Extractor (using sqlcmd)")
    print("=" * 80)
    
    # Test sqlcmd availability
    try:
        result = subprocess.run(["sqlcmd", "-?"], capture_output=True)
        print("✅ sqlcmd found")
    except FileNotFoundError:
        print("❌ sqlcmd not found")
        print("\nAlternative: Use Azure Data Studio to export schemas")
        print("1. Connect to each server in Azure Data Studio")
        print("2. Right-click on database > Generate Scripts")
        print("3. Save to SQLAzure/<ENV>/<DATABASE>/ folder")
        return
    
    for server_info in SERVERS:
        print(f"\n🖥️  {server_info['name']}: {server_info['server']}")
        try:
            databases = run_sql(server_info['server'], 'master', 
                "SELECT name FROM sys.databases WHERE name NOT IN ('master','tempdb','model','msdb')")
            print(f"   Databases: {databases}")
        except Exception as e:
            print(f"   ❌ {e}")

if __name__ == "__main__":
    main()
