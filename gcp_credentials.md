# 🔐 Credenciales de Bases de Datos GCP - Proyecto GradeX

## 📊 **Instancias de PostgreSQL**

### 1. **sia-colegios-db** (Estudiantes y Cursos)
- **Región:** us-central1-c
- **IP pública:** 34.68.43.142
- **Base de datos:** `sia_colegios`
- **Usuario:** `postgres`
- **Contraseña:** `postgres123`
- **Puerto:** 5432
- **Microservicio:** Component-1 (Django/SIA Colegios)
- **Cadena de conexión:** `postgresql://postgres:postgres123@34.68.43.142:5432/sia_colegios`

### 2. **auth-postgres** (Autenticación)
- **Región:** southamerica-east1-b
- **IP pública:** 35.247.229.4
- **Base de datos:** `authdb`
- **Usuario:** `postgres`
- **Contraseña:** `postgres123`
- **Puerto:** 5432
- **Microservicio:** Component-4 (Go/Auth)
- **Cadena de conexión:** `postgresql://postgres:postgres123@35.247.229.4:5432/authdb`

### 3. **sia-postgres** (Backup/Alternativa)
- **Región:** southamerica-east1-b
- **IP pública:** 35.247.249.84
- **Base de datos:** `sia_colegios`
- **Usuario:** `postgres`
- **Contraseña:** (configurada al crear la instancia)
- **Puerto:** 5432
- **Nota:** Instancia adicional disponible

## 🍃 **Instancias de MongoDB**

### 1. **mongo-profesores** (Profesores y Asignaturas)
- **Región:** us-central1-a
- **IP pública:** 34.61.138.228
- **Base de datos:** `profesores_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-1 (Spring Boot)
- **Cadena de conexión:** `mongodb://34.61.138.228:27017/profesores_db`

### 2. **mongo-calificaciones** (Calificaciones)
- **Región:** us-central1-b
- **IP pública:** 34.56.58.46
- **Base de datos:** `calificaciones_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-2 (Spring Boot)
- **Cadena de conexión:** `mongodb://34.56.58.46:27017/calificaciones_db`

## 🔧 **Comandos de Conexión**

### PostgreSQL
```bash
# Conectar a sia-colegios-db
psql -h 34.68.43.142 -U postgres -d sia_colegios

# Conectar a auth-postgres
psql -h 35.247.229.4 -U postgres -d authdb
```

### MongoDB
```bash
# Conectar a mongo-profesores
mongosh "mongodb://34.61.138.228:27017/profesores_db"

# Conectar a mongo-calificaciones
mongosh "mongodb://34.56.58.46:27017/calificaciones_db"
```

## 🛡️ **Configuración de Firewall**

### Reglas de Firewall Creadas
- **Nombre:** `allow-mongo`
- **Puerto:** 27017 (MongoDB)
- **Protocolo:** TCP
- **Origen:** 0.0.0.0/0 (cualquier IP)

## 📋 **Variables de Entorno para Docker**

### Component-1 (Django)
```yaml
environment:
  - DB_HOST=34.68.43.142
  - DB_NAME=sia_colegios
  - DB_USER=postgres
  - DB_PASSWORD=postgres123
  - DB_PORT=5432
```

### Component-4 (Go/Auth)
```yaml
environment:
  - DB_HOST=35.247.229.4
  - DB_PORT=5432
  - DB_USER=postgres
  - DB_PASSWORD=postgres123
  - DB_NAME=authdb
  - DB_SSL_MODE=disable
```

### Component-2-1 (Spring Boot - Profesores)
```yaml
environment:
  - SPRING_DATA_MONGODB_URI=mongodb://34.61.138.228:27017/profesores_db
```

### Component-2-2 (Spring Boot - Calificaciones)
```yaml
environment:
  - SPRING_DATA_MONGODB_URI=mongodb://34.56.58.46:27017/calificaciones_db
```

## ⚠️ **Notas Importantes**

1. **Seguridad:** Estas credenciales son para desarrollo. En producción, usa contraseñas más seguras.
2. **Firewall:** Las reglas de firewall permiten conexiones desde cualquier IP. En producción, restringe a IPs específicas.
3. **SSL:** PostgreSQL está configurado sin SSL para desarrollo. En producción, habilita SSL.
4. **Backup:** Configura backups automáticos en GCP Cloud SQL.
5. **Monitoreo:** Usa Cloud Monitoring para monitorear el rendimiento de las bases de datos.

## 🔍 **Comandos de Verificación**

### Verificar instancias de Cloud SQL
```bash
gcloud sql instances list --project=bright-aloe-465517-q3
```

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

#### 1. **PostgreSQL (Component-1 y Component-4) - OPTIMIZADO PARA f1-micro**
- **Connection Pool**: Máximo 5 conexiones (reducido de 20-25)
- **Connection Lifetime**: 300 segundos (reducido de 1800)
- **Timeout**: 30 segundos para conexiones
- **Max Age**: 60 segundos para mantener conexiones vivas (reducido de 300)
- **Idle Connections**: 2 conexiones idle máximo (reducido de 5)

#### 2. **MongoDB (Component-2-1 y Component-2-2) - OPTIMIZADO**
- **Pool Size**: 2-10 conexiones (reducido de 5-20)
- **Idle Time**: 300 segundos (5 minutos)
- **Timeouts**: 30 segundos para conexión, socket y selección de servidor
- **URI optimizada** con parámetros de conexión

#### 3. **API Gateway**
- **HTTP Timeout**: 30 segundos
- **GraphQL Timeout**: 30 segundos
- **API Timeout**: 30 segundos

#### 4. **Nginx Proxy**
- **Proxy Timeout**: 60 segundos
- **Upstream Timeout**: 60 segundos
- **Keepalive Timeout**: 65 segundos

#### 5. **Frontend (Next.js)**
- **API Timeout**: 30 segundos
- **Request Timeout**: 30 segundos

### 🔧 **Problema Resuelto: Agotamiento de Conexiones**

**Error anterior**: 
```
connection to server at "34.68.43.142", port 5432 failed: FATAL: remaining connection slots are reserved for roles with privileges of the "pg_use_reserved_connections" role
```

**Solución implementada**:
- Reducido pool de conexiones PostgreSQL de 20-25 a 5 conexiones máximo
- Reducido tiempo de vida de conexiones de 1800s a 300s
- Reducido conexiones idle de 5 a 2
- Reducido pool MongoDB de 20 a 10 conexiones máximo

### Beneficios de estas Optimizaciones

1. **✅ Eliminación de errores de agotamiento de conexiones**
2. **✅ Mejor manejo de conexiones** a bases de datos GCP f1-micro
3. **✅ Inicio ordenado** de servicios con dependencias
4. **✅ Monitoreo automático** de salud de servicios
5. **✅ Recuperación automática** en caso de fallos temporales

### 🎯 **Estado Actual del Sistema**

- **✅ Component-1 (Django)**: Conectado a PostgreSQL GCP, 19 cursos, 36 estudiantes
- **✅ Component-4 (Go/Auth)**: Conectado a PostgreSQL GCP, 2 usuarios
- **✅ Component-2-1 (Spring/Profesores)**: Conectado a MongoDB GCP
- **✅ Component-2-2 (Spring/Calificaciones)**: Conectado a MongoDB GCP
- **✅ API Gateway**: Funcionando correctamente, health check OK
- **✅ Lectura de datos**: Problema de conexiones resuelto 