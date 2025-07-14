# 🔐 Credenciales de Bases de Datos GCP - Proyecto GradeX

## 🍃 **Instancias de MongoDB**

### 1. **mongo-profesores** (Profesores y Asignaturas)
- **Región:** us-central1-a
- **IP pública:** 34.16.39.121
- **Base de datos:** `profesores_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-1 (Spring Boot)
- **Cadena de conexión:** `mongodb://34.16.39.121:27017/profesores_db`

### 2. **mongo-calificaciones** (Calificaciones)
- **Región:** us-central1-b
- **IP pública:** 34.61.138.228
- **Base de datos:** `calificaciones_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-2 (Spring Boot)
- **Cadena de conexión:** `mongodb://34.61.138.228:27017/calificaciones_db`

## 🔧 **Comandos de Conexión**

### MongoDB
```bash
# Conectar a mongo-profesores
mongosh "mongodb://34.16.39.121:27017/profesores_db"

# Conectar a mongo-calificaciones
mongosh "mongodb://34.61.138.228:27017/calificaciones_db"
```

## 🛡️ **Configuración de Firewall**

### Reglas de Firewall Creadas
- **Nombre:** `allow-mongo`
- **Puerto:** 27017 (MongoDB)
- **Protocolo:** TCP
- **Origen:** 0.0.0.0/0 (cualquier IP)

## 📋 **Variables de Entorno para Docker**

### Component-2-1 (Spring Boot - Profesores)
```yaml
environment:
  - SPRING_DATA_MONGODB_URI=mongodb://34.16.39.121:27017/profesores_db
```

### Component-2-2 (Spring Boot - Calificaciones)
```yaml
environment:
  - SPRING_DATA_MONGODB_URI=mongodb://34.61.138.228:27017/calificaciones_db
```

## ⚠️ **Notas Importantes**

1. **Seguridad:** Estas credenciales son para desarrollo. En producción, usa contraseñas más seguras.
2. **Firewall:** Las reglas de firewall permiten conexiones desde cualquier IP. En producción, restringe a IPs específicas.
3. **Backup:** Configura backups automáticos en GCP.
4. **Monitoreo:** Usa Cloud Monitoring para monitorear el rendimiento de las bases de datos.

## 🔍 **Comandos de Verificación**

### Verificar instancias de Compute Engine (MongoDB)
```bash
gcloud compute instances list --filter="name~mongo"
```

### Verificar reglas de firewall
```bash
gcloud compute firewall-rules list --filter="name=allow-mongo"
```

---

**Proyecto GCP:** bright-aloe-465517-q3  
**Región principal:** northamerica-south1  
**Última actualización:** 2025-07-13 

## 🚀 **Optimizaciones de Conexión y Timeout**

### Configuraciones Implementadas para Mejorar la Comunicación con GCP

#### 1. **MongoDB (Component-2-1 y Component-2-2) - OPTIMIZADO**
- **Pool Size**: 2-10 conexiones (reducido de 5-20)
- **Idle Time**: 300 segundos (5 minutos)
- **Timeouts**: 30 segundos para conexión, socket y selección de servidor
- **URI optimizada** con parámetros de conexión

#### 2. **API Gateway**
- **HTTP Timeout**: 30 segundos
- **GraphQL Timeout**: 30 segundos
- **API Timeout**: 30 segundos

#### 3. **Nginx Proxy**
- **Proxy Timeout**: 60 segundos
- **Upstream Timeout**: 60 segundos
- **Keepalive Timeout**: 65 segundos

#### 4. **Frontend (Next.js)**
- **API Timeout**: 30 segundos
- **Request Timeout**: 30 segundos

### 🔧 **Problema Resuelto: Agotamiento de Conexiones**

**Error anterior**: 
```
connection to server failed: FATAL: remaining connection slots are reserved for roles with privileges
```

**Solución implementada**:
- Reducido pool MongoDB de 20 a 10 conexiones máximo
- Optimizado tiempo de vida de conexiones
- Mejorado manejo de conexiones idle

### Beneficios de estas Optimizaciones

1. **✅ Eliminación de errores de agotamiento de conexiones**
2. **✅ Mejor manejo de conexiones** a bases de datos GCP
3. **✅ Inicio ordenado** de servicios con dependencias
4. **✅ Monitoreo automático** de salud de servicios
5. **✅ Recuperación automática** en caso de fallos temporales

### 🎯 **Estado Actual del Sistema**

- **✅ Component-2-1 (Spring/Profesores)**: Conectado a MongoDB GCP
- **✅ Component-2-2 (Spring/Calificaciones)**: Conectado a MongoDB GCP
- **✅ API Gateway**: Funcionando correctamente, health check OK
- **✅ Lectura de datos**: Problema de conexiones resuelto 