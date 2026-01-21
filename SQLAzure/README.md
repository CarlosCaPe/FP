# SQL Azure Schema Repository

This folder contains SQL DDL snapshots from Azure SQL databases.

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
