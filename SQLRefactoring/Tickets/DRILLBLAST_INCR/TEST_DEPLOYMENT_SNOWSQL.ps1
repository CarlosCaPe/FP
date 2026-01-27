<# 
.SYNOPSIS
    Execute DRILLBLAST INCR test deployment using SnowSQL CLI
.DESCRIPTION
    This script runs the complete test deployment in DEV_API_REF.FUSE
    Uses SnowSQL CLI which is always compatible (no Python version issues)
.NOTES
    Author: Carlos Carrillo
    Date: 2026-01-26
    
    IMPORTANTE: Python 3.14 NO es compatible con snowflake-connector-python
    Este script usa SnowSQL CLI como alternativa permanente.
#>

param(
    [string]$SqlFile = "TEST_DEPLOYMENT_DEV.sql",
    [string]$Account = "fcx-na",
    [string]$Database = "DEV_API_REF",
    [string]$Schema = "FUSE",
    [string]$Warehouse = "COMPUTE_WH",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "DRILLBLAST INCR - Test Deployment Script" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""

# Check if SnowSQL is installed
$snowsql = Get-Command snowsql -ErrorAction SilentlyContinue
if (-not $snowsql) {
    Write-Host "❌ SnowSQL CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "ALTERNATIVAS:" -ForegroundColor Yellow
    Write-Host "1. Instalar SnowSQL: https://docs.snowflake.com/en/user-guide/snowsql-install-config" -ForegroundColor Yellow
    Write-Host "2. Ejecutar manualmente en Snowflake Worksheet:" -ForegroundColor Yellow
    Write-Host "   - Abrir https://app.snowflake.com" -ForegroundColor Gray
    Write-Host "   - Ir a Worksheets" -ForegroundColor Gray
    Write-Host "   - Copiar contenido de: $SqlFile" -ForegroundColor Gray
    Write-Host "   - Ejecutar" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Usar VS Code Snowflake Extension" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ SnowSQL found: $($snowsql.Source)" -ForegroundColor Green

# Check if SQL file exists
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlFilePath = Join-Path $scriptPath $SqlFile

if (-not (Test-Path $sqlFilePath)) {
    Write-Host "❌ SQL file not found: $sqlFilePath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SQL file found: $sqlFilePath" -ForegroundColor Green
Write-Host ""

# Show what will be executed
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Account:   $Account" -ForegroundColor Gray
Write-Host "  Database:  $Database" -ForegroundColor Gray
Write-Host "  Schema:    $Schema" -ForegroundColor Gray
Write-Host "  Warehouse: $Warehouse" -ForegroundColor Gray
Write-Host "  SQL File:  $SqlFile" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN - Command that would be executed:" -ForegroundColor Yellow
    Write-Host "snowsql -a $Account -d $Database -s $Schema -w $Warehouse -f `"$sqlFilePath`"" -ForegroundColor Gray
    exit 0
}

# Execute
Write-Host "🚀 Executing deployment..." -ForegroundColor Cyan
Write-Host ""

try {
    # Run SnowSQL with SSO authentication
    & snowsql -a $Account -d $Database -s $Schema -w $Warehouse -f $sqlFilePath --authenticator externalbrowser
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=" * 70 -ForegroundColor Green
        Write-Host "✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
        Write-Host "=" * 70 -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ SnowSQL exited with code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
}
