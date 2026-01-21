# SQL Azure Schema Repository

This folder contains SQL DDL snapshots from Azure SQL databases.

## 🚧 TODO - Próximos Pasos

1. **Ejecutar desde servidor en red corporativa** - Los scripts no funcionan desde fuera de la red (VPN/Firewall)
2. **Probar `extract_schemas_v2.py`** - Usa azure-identity, debería funcionar con `az login`
3. **Extraer schemas de las 6 bases de datos** en DEV, TEST, PROD
4. **Organizar estructura** - Una vez extraídos, revisar y limpiar los DDL
5. **Usar como base para crear nuevos objetos** - Este repo será el source of truth para SQL Azure

## Servers

| Environment | Server |
|-------------|--------|
| DEV | azwd22midbx02.eb8a77f2eea6.database.windows.net |
| TEST | azwt22midbx02.9959d3e6fe6e.database.windows.net |
| PROD | azwp22midbx02.8232c56adfdf.database.windows.net |

## Structure

```
SQLAzure/
├── DEV/
│   └── <database>/
│       └── <schema>/
│           ├── Tables/
│           ├── Views/
│           ├── StoredProcedures/
│           └── Functions/
├── TEST/
│   └── ...
└── PROD/
    └── ...
```

## Usage

### Extract all schemas
```bash
python extract_schemas.py
```

### Requirements
- Python 3.8+
- pyodbc
- ODBC Driver 18 for SQL Server
- Azure AD authentication configured

## Authentication

Uses Azure Active Directory Interactive authentication (Microsoft Entra MFA).
