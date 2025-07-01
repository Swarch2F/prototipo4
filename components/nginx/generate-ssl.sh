#!/bin/bash
# Script para generar certificados SSL autofirmados para GRADEX
# Uso: ./generate-ssl.sh

echo "🔒 Generando certificados SSL para GRADEX..."

# Crear directorio para certificados
mkdir -p ssl

# Generar clave privada RSA de 2048 bits
echo "📝 Generando clave privada..."
openssl genrsa -out ssl/gradex.key 2048

# Generar certificado autofirmado válido por 365 días
echo "📄 Generando certificado autofirmado..."
openssl req -new -x509 -key ssl/gradex.key -out ssl/gradex.crt -days 365 -subj "/C=CO/ST=Colombia/L=Bogota/O=GRADEX/OU=IT Department/CN=localhost"

# Generar certificado DH para mayor seguridad
echo "🔐 Generando parámetros Diffie-Hellman..."
openssl dhparam -out ssl/dhparam.pem 2048

# Configurar permisos de seguridad
chmod 600 ssl/gradex.key
chmod 644 ssl/gradex.crt
chmod 644 ssl/dhparam.pem

echo "✅ Certificados SSL generados exitosamente en el directorio ssl/"
echo "📂 Archivos creados:"
echo "  - ssl/gradex.key (Clave privada)"
echo "  - ssl/gradex.crt (Certificado público)"
echo "  - ssl/dhparam.pem (Parámetros DH)"
echo ""
echo "🌐 El certificado es válido para: localhost"
echo "⏰ Válido por: 365 días"
echo ""
echo "⚠️  NOTA: Este es un certificado autofirmado para desarrollo."
echo "    Para producción, usa un certificado de una CA confiable." 