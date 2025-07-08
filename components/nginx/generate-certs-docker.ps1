# Script para generar certificados SSL usando Docker (OpenSSL incluido)
# Uso: powershell -ExecutionPolicy Bypass -File generate-certs-docker.ps1

Write-Host "Generando certificados SSL usando Docker..." -ForegroundColor Cyan

# Verificar si Docker está disponible
try {
    docker --version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker no disponible" }
    Write-Host "Docker encontrado" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker no esta instalado o no esta funcionando" -ForegroundColor Red
    exit 1
}

# Crear directorio ssl si no existe
if (!(Test-Path "ssl")) {
    New-Item -ItemType Directory -Path "ssl" | Out-Null
    Write-Host "Directorio ssl/ creado" -ForegroundColor Green
}

try {
    Write-Host "Generando clave privada..." -ForegroundColor Yellow
    docker run --rm -v ${PWD}/ssl:/certs alpine/openssl genrsa -out /certs/gradex.key 2048
    if ($LASTEXITCODE -ne 0) { throw "Error generando clave privada" }

    Write-Host "Generando certificado autofirmado..." -ForegroundColor Yellow
    docker run --rm -v ${PWD}/ssl:/certs alpine/openssl req -new -x509 -key /certs/gradex.key -out /certs/gradex.crt -days 365 -subj "/C=CO/ST=Colombia/L=Bogota/O=GRADEX/OU=IT Department/CN=localhost"
    if ($LASTEXITCODE -ne 0) { throw "Error generando certificado" }

    Write-Host "Generando parametros Diffie-Hellman..." -ForegroundColor Yellow
    docker run --rm -v ${PWD}/ssl:/certs alpine/openssl dhparam -out /certs/dhparam.pem 2048
    if ($LASTEXITCODE -ne 0) { throw "Error generando parametros DH" }

    Write-Host ""
    Write-Host "Certificados SSL generados exitosamente!" -ForegroundColor Green
    Write-Host "Archivos creados:" -ForegroundColor White
    Write-Host "  - ssl/gradex.key (Clave privada)" -ForegroundColor Gray
    Write-Host "  - ssl/gradex.crt (Certificado publico)" -ForegroundColor Gray
    Write-Host "  - ssl/dhparam.pem (Parametros DH)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "El certificado es valido para: localhost" -ForegroundColor Cyan
    Write-Host "Valido por: 365 dias" -ForegroundColor Cyan

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 