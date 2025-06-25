#!/bin/bash

# Verificar si existe el archivo .env
if [ ! -f .env ]; then
    echo "Error: El archivo .env no existe"
    echo "Por favor, crea un archivo .env con las variables necesarias."
    exit 1
fi

# Cargar variables de entorno
set -a
source .env
set +a

# Verificar variables críticas
if [ -z "$JWT_SECRET" ]; then
    echo "Error: JWT_SECRET no está definido en .env"
    exit 1
fi

# Imprimir variables cargadas (excluyendo las sensibles)
echo "=== Variables de entorno cargadas ==="
echo "GOOGLE_REDIRECT_URL: $GOOGLE_REDIRECT_URL"
echo "GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID:0:4}..." # Solo muestra los primeros 4 caracteres
echo "GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET:0:4}..." # Solo muestra los primeros 4 caracteres
echo "JWT_SECRET: ${JWT_SECRET:0:4}..." # Solo muestra los primeros 4 caracteres
echo "==================================="

# Ejecutar docker-compose
echo "Iniciando servicios con las variables de entorno cargadas..."
docker-compose up -d

echo "Servicios iniciados correctamente" 