FROM nginx:alpine

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/nginx.conf

# Crear directorios necesarios
RUN mkdir -p /var/log/nginx /etc/nginx/ssl

# Copiar certificados SSL
COPY ssl/gradex.crt /etc/nginx/ssl/gradex.crt
COPY ssl/gradex.key /etc/nginx/ssl/gradex.key
COPY ssl/dhparam.pem /etc/nginx/ssl/dhparam.pem

# Configurar permisos de seguridad para certificados
RUN chmod 644 /etc/nginx/ssl/gradex.crt && \
    chmod 600 /etc/nginx/ssl/gradex.key && \
    chmod 644 /etc/nginx/ssl/dhparam.pem

# Exponer puertos HTTP (80) y HTTPS (443)
EXPOSE 80 443

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]
