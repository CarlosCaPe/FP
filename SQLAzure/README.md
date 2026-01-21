# SQL Azure Schema Repository

Repositorio de DDL (schemas) extraídos de las bases de datos SQL Azure del proyecto.

## 📁 Estructura del Proyecto

```
SQLAzure/
├── README.md                 # Este archivo
├── requirements.txt          # Dependencias Python
├── .env.example             # Template de variables de entorno
├── scripts/                  # Scripts de extracción
│   ├── extract_schemas.py    # Extractor con ODBC Driver 17
│   ├── extract_schemas_v2.py # Extractor con azure-identity
│   └── extract_sqlcmd.py     # Extractor con sqlcmd CLI
└── schemas/                  # DDL extraídos (por ambiente)
    ├── DEV/
    │   └── <database>/
    │       └── <schema>/
    │           ├── Tables/
    │           ├── Views/
    │           ├── StoredProcedures/
    │           └── Functions/
    ├── TEST/
    └── PROD/
```

## 🔧 Servidores

| Ambiente | Servidor |
|----------|----------|
| DEV | `azwd22midbx02.eb8a77f2eea6.database.windows.net` |
| TEST | `azwt22midbx02.9959d3e6fe6e.database.windows.net` |
| PROD | `azwp22midbx02.8232c56adfdf.database.windows.net` |

## 🚀 Instalación

```bash
# Desde el folder SQLAzure
pip install -r requirements.txt

# Autenticarse con Azure CLI
az login
```

## 📋 Uso

### Extraer todos los schemas

```bash
cd scripts
python extract_schemas_v2.py  # Recomendado - usa azure-identity
```

### Extraer con ODBC (alternativo)

```bash
python extract_schemas.py
```

## 🚧 TODO

- [ ] Ejecutar desde servidor en red corporativa (VPN requerida)
- [ ] Probar `extract_schemas_v2.py` con `az login`
- [ ] Extraer schemas de las 6 bases de datos
- [ ] Revisar y limpiar los DDL extraídos
- [ ] Documentar diferencias entre ambientes

## 🔐 Autenticación

Los scripts usan **Microsoft Entra ID** (Azure AD) con MFA.

### Opciones:
1. **Azure CLI** (recomendado): `az login` antes de ejecutar
2. **Interactive Browser**: El script abre el navegador para autenticación
3. **Service Principal**: Para CI/CD (configurar en `.env`)

## 📝 Notas

- Requiere acceso VPN a la red corporativa
- ODBC Driver 17/18 for SQL Server requerido
- Python 3.8+
