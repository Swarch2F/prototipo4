FROM nginx:alpine

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Crear directorios necesarios
RUN mkdir -p /var/log/nginx /etc/nginx/ssl

# Copiar certificados SSL profesionales
COPY ssl/certificate.crt /etc/nginx/ssl/certificate.crt
COPY ssl/private.key /etc/nginx/ssl/private.key
COPY ssl/ca_bundle.crt /etc/nginx/ssl/ca_bundle.crt
COPY ssl/dhparam.pem /etc/nginx/ssl/dhparam.pem

# Configurar permisos de seguridad para certificados
RUN chmod 644 /etc/nginx/ssl/certificate.crt && \
    chmod 600 /etc/nginx/ssl/private.key && \
    chmod 644 /etc/nginx/ssl/ca_bundle.crt && \
    chmod 644 /etc/nginx/ssl/dhparam.pem

# Exponer puertos HTTP (80) y HTTPS (443)
EXPOSE 80 443

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]
