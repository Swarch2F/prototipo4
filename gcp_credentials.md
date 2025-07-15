# 🔐 Credenciales de Bases de Datos GCP - Proyecto GradeX

## 🐘 **Instancias de PostgreSQL (Cloud SQL)**

### 1. **sia-colegios** (SIA Colegios - Estudiantes y Cursos)
- **Región:** us-central1-f
- **Versión:** POSTGRES_17
- **IP pública:** 35.232.229.161
- **Base de datos:** `sia_colegios`
- **Usuario:** `postgres`
- **Contraseña:** `postgres`
- **Puerto:** 5432
- **Microservicio:** Component-1 (Django)
- **Tier:** db-perf-optimized-N-8
- **Cadena de conexión:** `postgresql://postgres:postgres@35.232.229.161:5432/sia_colegios`

### 2. **authdb** (Base de Datos de Autenticación)
- **Región:** us-central1-f
- **Versión:** POSTGRES_16
- **IP pública:** 34.45.100.245
- **Base de datos:** `authdb`
- **Usuario:** `authuser`
- **Contraseña:** `authpass` ← **Coincide con docker-compose**
- **Puerto:** 5432
- **Microservicio:** Component-4 (Go)
- **Tier:** db-perf-optimized-N-8
- **Cadena de conexión:** `postgresql://authuser:authpass@34.45.100.245:5432/authdb`

## 🍃 **Instancias de MongoDB (Compute Engine)**

### 1. **mongo-profesores** (Profesores y Asignaturas)
- **Región:** us-central1-a
- **IP pública:** 34.56.58.46
- **IP interna:** 10.128.0.2
- **Base de datos:** `profesores_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-1 (Spring Boot)
- **Tipo de máquina:** e2-small
- **Cadena de conexión:** `mongodb://34.56.58.46:27017/profesores_db`

### 2. **mongo-calificaciones** (Calificaciones)
- **Región:** us-central1-b
- **IP pública:** 34.61.138.228
- **IP interna:** 10.128.0.3
- **Base de datos:** `calificaciones_db`
- **Puerto:** 27017
- **Microservicio:** Component-2-2 (Spring Boot)
- **Tipo de máquina:** e2-small
- **Cadena de conexión:** `mongodb://34.61.138.228:27017/calificaciones_db`

## 🔧 **Comandos de Conexión**

### PostgreSQL (Cloud SQL)
```bash
# Conectar a sia-colegios
psql "postgresql://postgres:postgres@35.232.229.161:5432/sia_colegios"

# Conectar a authdb
psql "postgresql://authuser:authpass@34.45.100.245:5432/authdb"
```

### MongoDB (Compute Engine)
```bash
# Conectar a mongo-profesores
mongosh "mongodb://34.56.58.46:27017/profesores_db"

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

### Component-1 (Django - SIA Colegios)

```yaml
environment:
  - DB_HOST=35.232.229.161
  - DB_NAME=sia_colegios
  - DB_USER=postgres

  - DB_PASSWORD=postgres
  - DB_PORT=5432
```

### Component-4 (Go - Autenticación)

```yaml
environment:
  - DB_HOST=34.45.100.245
  - DB_PORT=5432

  - DB_USER=authuser
  - DB_PASSWORD=authpass
  - DB_NAME=authdb

```

### Component-2-1 (Spring Boot - Profesores)
```yaml
environment:

  - SPRING_DATA_MONGODB_URI=mongodb://34.56.58.46:27017/profesores_db

```

### Component-2-2 (Spring Boot - Calificaciones)
```yaml
environment:

  - SPRING_DATA_MONGODB_URI=mongodb://34.61.138.228:27017/calificaciones_db
```

## 🔍 **Correspondencia Docker Compose ↔ GCP**

| Docker Compose | GCP Instance | Tipo | IP/Conexión | Estado |
|---|---|---|---|---|
| `sia-db` | `sia-colegios` | Cloud SQL (PostgreSQL 17) | 35.232.229.161 | ✅ |
| `gx_db_auth` | `authdb` | Cloud SQL (PostgreSQL 16) | 34.45.100.245 | ✅ |
| `mongo-professors` | `mongo-profesores` | Compute Engine (MongoDB) | 34.56.58.46 | ✅ |
| `mongo-grades` | `mongo-calificaciones` | Compute Engine (MongoDB) | 34.61.138.228 | ✅ |

## ⚠️ **Notas Importantes**

1. **Seguridad:** Estas credenciales son para desarrollo. En producción, usa contraseñas más seguras.
2. **Firewall:** Las reglas de firewall permiten conexiones desde cualquier IP. En producción, restringe a IPs específicas.

3. **Backup:** Configura backups automáticos en GCP.
4. **Monitoreo:** Usa Cloud Monitoring para monitorear el rendimiento de las bases de datos.
5. **Consistencia:** Las contraseñas en GCP coinciden exactamente con las del docker-compose.

## 🔍 **Comandos de Verificación**

### Verificar instancias de Cloud SQL (PostgreSQL)

```bash
gcloud sql instances list --project=bright-aloe-465517-q3
```

### Verificar instancias de Compute Engine (MongoDB)
```bash

gcloud compute instances list --filter="name~mongo" --project=bright-aloe-465517-q3

```

### Verificar reglas de firewall
```bash
gcloud compute firewall-rules list --filter="name=allow-mongo"
```

---

**Proyecto GCP:** bright-aloe-465517-q3  
**Región principal:** northamerica-south1  

**Última actualización:** 2025-07-14 


## 🚀 **Optimizaciones de Conexión y Timeout**

### Configuraciones Implementadas para Mejorar la Comunicación con GCP


#### 1. **PostgreSQL (Component-1 y Component-4) - CLOUD SQL**
- **Pool Size**: Configurado para Cloud SQL
- **SSL Mode**: Configurado según necesidades
- **Timeout**: 30 segundos para conexiones


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


- **✅ Component-1 (Django/SIA)**: Conectado a PostgreSQL Cloud SQL
- **✅ Component-4 (Go/Auth)**: Conectado a PostgreSQL Cloud SQL
- **✅ Component-2-1 (Spring/Profesores)**: Conectado a MongoDB GCP
- **✅ Component-2-2 (Spring/Calificaciones)**: Conectado a MongoDB GCP
- **✅ API Gateway**: Funcionando correctamente, health check OK
- **✅ Lectura de datos**: Problema de conexiones resuelto

