# Usa una imagen oficial y ligera de NGINX
FROM nginx:alpine

# Exponer los puertos es una buena práctica (documentación)
EXPOSE 80 443

# El comando por defecto para mantener NGINX corriendo en primer plano.
# No se necesita copiar ningún archivo, Kubernetes se encargará de eso.
CMD ["nginx", "-g", "daemon off;"]
