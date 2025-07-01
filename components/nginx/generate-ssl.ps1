# Script PowerShell para generar certificados SSL autofirmados para GRADEX
# Uso: powershell -ExecutionPolicy Bypass -File generate-ssl.ps1

Write-Host "Generando certificados SSL para GRADEX..." -ForegroundColor Cyan

# Verificar si OpenSSL está disponible
try {
    $null = Get-Command openssl -ErrorAction Stop
    Write-Host "OpenSSL encontrado" -ForegroundColor Green
} catch {
    Write-Host "ERROR: OpenSSL no esta instalado o no esta en PATH" -ForegroundColor Red
    Write-Host "Instala OpenSSL desde: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
    Write-Host "O usa Git Bash que incluye OpenSSL" -ForegroundColor Yellow
    exit 1
}

# Crear directorio para certificados
if (!(Test-Path "ssl")) {
    New-Item -ItemType Directory -Path "ssl" | Out-Null
    Write-Host "Directorio ssl/ creado" -ForegroundColor Green
}

try {
    # Generar clave privada RSA de 2048 bits
    Write-Host "Generando clave privada..." -ForegroundColor Yellow
    & openssl genrsa -out ssl/gradex.key 2048
    if ($LASTEXITCODE -ne 0) { throw "Error generando clave privada" }

    # Generar certificado autofirmado válido por 365 días
    Write-Host "Generando certificado autofirmado..." -ForegroundColor Yellow
    & openssl req -new -x509 -key ssl/gradex.key -out ssl/gradex.crt -days 365 -subj "/C=CO/ST=Colombia/L=Bogota/O=GRADEX/OU=IT Department/CN=localhost"
    if ($LASTEXITCODE -ne 0) { throw "Error generando certificado" }

    # Generar certificado DH para mayor seguridad
    Write-Host "Generando parametros Diffie-Hellman..." -ForegroundColor Yellow
    & openssl dhparam -out ssl/dhparam.pem 2048
    if ($LASTEXITCODE -ne 0) { throw "Error generando parámetros DH" }

    Write-Host ""
    Write-Host "Certificados SSL generados exitosamente en el directorio ssl/" -ForegroundColor Green
    Write-Host "Archivos creados:" -ForegroundColor White
    Write-Host "  - ssl/gradex.key (Clave privada)" -ForegroundColor Gray
    Write-Host "  - ssl/gradex.crt (Certificado publico)" -ForegroundColor Gray
    Write-Host "  - ssl/dhparam.pem (Parametros DH)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "El certificado es valido para: localhost" -ForegroundColor Cyan
    Write-Host "Valido por: 365 dias" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NOTA: Este es un certificado autofirmado para desarrollo." -ForegroundColor Yellow
    Write-Host "Para produccion, usa un certificado de una CA confiable." -ForegroundColor Yellow

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 