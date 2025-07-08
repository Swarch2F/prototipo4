# 🔒 Proxy Inverso NGINX - Sistema GRADEX

## 📖 **ÍNDICE**
1. [¿Qué es y para qué sirve?](#-qué-es-y-para-qué-sirve)
2. [Flujo de Datos Completo](#-flujo-de-datos-completo)
3. [Configuración Detallada](#-configuración-detallada)
4. [Arquitectura de Seguridad](#-arquitectura-de-seguridad)
5. [Routing y Direccionamiento](#-routing-y-direccionamiento)
6. [Integración con Docker](#-integración-con-docker)
7. [Monitoreo y Logs](#-monitoreo-y-logs)
8. [Testing y Verificación](#-testing-y-verificación)

---

## 🎯 **¿QUÉ ES Y PARA QUÉ SIRVE?**

El **Proxy Inverso NGINX** en GRADEX actúa como la **puerta de entrada única** y **capa de seguridad** de todo el sistema. Es el único componente que expone un puerto al exterior (80), mientras que todos los demás servicios quedan protegidos en la red interna de Docker.

### **🔐 Funciones Principales**
- **Punto de entrada único**: Solo el puerto 80 está expuesto externamente
- **Proxy inverso**: Redirige las peticiones a los servicios internos apropiados
- **Capa de seguridad**: Headers, rate limiting, bloqueo de archivos sensibles
- **Balanceador de carga**: Distribución de conexiones con keepalive
- **Terminación SSL**: Preparado para HTTPS (futuro)

---

## 🔄 **FLUJO DE DATOS COMPLETO**

### **🏗️ Arquitectura Visual Completa**

```mermaid
graph TB
    subgraph "ACCESO EXTERNO"
        USER[👤 Usuario Browser]
        INTERNET[🌐 Internet Puerto 80]
    end
    
    subgraph "PROXY LAYER - ÚNICO PUNTO DE ENTRADA"
        NGINX[🔒 NGINX Proxy<br/>gx_nginx_proxy<br/>Puerto 80]
        
        subgraph "NGINX ROUTING"
            ROUTE1[📍 /nginx-health<br/>→ Respuesta directa]
            ROUTE2[📍 /graphql<br/>→ API Gateway]
            ROUTE3[📍 / - todo lo demás<br/>→ Frontend]
        end
        
        subgraph "SEGURIDAD NGINX"
            RATE[⚡ Rate Limiting<br/>API: 10 req/s<br/>General: 30 req/s]
            HEADERS[🛡️ Security Headers<br/>X-Frame-Options<br/>X-XSS-Protection<br/>CSP]
            BLOCK[🚫 Archivos Bloqueados<br/>.env .sql .config<br/>Archivos ocultos]
        end
    end
    
    subgraph "RED INTERNA DOCKER - PROTEGIDA"
        subgraph "FRONTEND LAYER"
            FE[🌐 Frontend Next.js<br/>gx_fe_gradex<br/>Puerto 3000 interno]
            FEPAGES[📄 Páginas:<br/>/ - Dashboard<br/>/login - Autenticación<br/>/administrador - Admin<br/>/docente - Docente]
        end
        
        subgraph "API LAYER"
            GW[⚡ API Gateway<br/>gx_api_gateway<br/>Puerto 4000 interno]
            GWFUNC[🔧 Funciones:<br/>GraphQL Server<br/>Schema Federation<br/>Service Orchestration]
        end
        
        subgraph "MICROSERVICES LAYER"
            MS1[📚 SIA Colegios<br/>Django + PostgreSQL<br/>:8083]
            MS2[👨‍🏫 Profesores/Asignaturas<br/>Java Spring + MongoDB<br/>:8080]
            MS3[📊 Calificaciones<br/>Java Spring + MongoDB<br/>:8081]
            MS4[🔐 Autenticación<br/>Go + JWT + PostgreSQL<br/>:8082]
            MS5[📨 Message Broker<br/>Node.js + RabbitMQ<br/>:3000]
        end
        
        subgraph "DATA LAYER"
            DB1[(🗄️ PostgreSQL SIA<br/>:5433)]
            DB2[(🗄️ PostgreSQL Auth<br/>:5432)]
            DB3[(🍃 MongoDB Profesores<br/>:27018)]
            DB4[(🍃 MongoDB Calificaciones<br/>:27019)]
            DB5[(🐰 RabbitMQ<br/>:5673)]
        end
    end
    
    %% Conexiones principales
    USER --> INTERNET
    INTERNET --> NGINX
    
    %% Routing interno NGINX
    NGINX --> ROUTE1
    NGINX --> ROUTE2
    NGINX --> ROUTE3
    
    %% Aplicación de seguridad
    NGINX -.-> RATE
    NGINX -.-> HEADERS
    NGINX -.-> BLOCK
    
    %% Proxy pass a servicios internos
    ROUTE2 --> GW
    ROUTE3 --> FE
    
    %% Frontend a páginas
    FE --> FEPAGES
    
    %% API Gateway a funciones
    GW --> GWFUNC
    
    %% API Gateway a microservicios
    GW --> MS1
    GW --> MS2
    GW --> MS3
    GW --> MS4
    GW --> MS5
    
    %% Microservicios a bases de datos
    MS1 --> DB1
    MS2 --> DB3
    MS3 --> DB4
    MS4 --> DB2
    MS5 --> DB5
    
    %% Estilos
    classDef proxy fill:#ff6b6b,stroke:#d63031,stroke-width:3px,color:#fff
    classDef frontend fill:#74b9ff,stroke:#0984e3,stroke-width:2px,color:#fff
    classDef api fill:#fd79a8,stroke:#e84393,stroke-width:2px,color:#fff
    classDef micro fill:#55a3ff,stroke:#2980b9,stroke-width:2px,color:#fff
    classDef db fill:#6c5ce7,stroke:#5f39bb,stroke-width:2px,color:#fff
    classDef security fill:#00b894,stroke:#00a085,stroke-width:2px,color:#fff
    
    class NGINX,ROUTE1,ROUTE2,ROUTE3 proxy
    class FE,FEPAGES frontend
    class GW,GWFUNC api
    class MS1,MS2,MS3,MS4,MS5 micro
    class DB1,DB2,DB3,DB4,DB5 db
    class RATE,HEADERS,BLOCK security
```

### **📋 Descripción del Flujo**

1. **Usuario hace request** → `http://localhost/cualquier-ruta`
2. **NGINX recibe** → Puerto 80 (único puerto expuesto)
3. **NGINX analiza la ruta**:
   - `/nginx-health` → Respuesta directa del nginx
   - `/graphql` → Proxy a `api-gateway:4000`
   - Todo lo demás → Proxy a `gx_fe_gradex:3000`
4. **Servicios procesan** → En red interna Docker
5. **NGINX retorna respuesta** → Con headers de seguridad añadidos

### **🔄 Flujo Detallado de Request**

```mermaid
sequenceDiagram
    participant U as 👤 Usuario
    participant N as 🔒 NGINX Proxy
    participant F as 🌐 Frontend
    participant G as ⚡ API Gateway
    participant M as 📚 Microservicio
    participant D as 🗄️ Base de Datos
    
    Note over U,D: FLUJO COMPLETO DE REQUEST EN GRADEX
    
    rect rgb(255, 240, 240)
        Note over U,N: 1. REQUEST INICIAL
        U->>+N: GET http://localhost/
        N->>N: ✅ Verificar Rate Limiting
        N->>N: ✅ Aplicar Headers Seguridad
        N->>N: ✅ Analizar Ruta: / → Frontend
    end
    
    rect rgb(240, 248, 255)
        Note over N,F: 2. PROXY PASS AL FRONTEND
        N->>+F: proxy_pass http://gx_fe_gradex:3000/
        Note over F: Frontend Next.js procesa request
        F->>N: 200 OK + HTML/CSS/JS
        N->>N: ➕ Añadir Headers Seguridad
        N->>-U: 200 OK + Página Web
    end
    
    rect rgb(248, 255, 240)
        Note over U,G: 3. REQUEST API DESDE FRONTEND
        U->>+N: POST http://localhost/graphql
        N->>N: ✅ Rate Limiting API (10 req/s)
        N->>N: ✅ Validar método HTTP
        N->>N: ✅ Analizar Ruta: /graphql → API Gateway
        N->>+G: proxy_pass http://api-gateway:4000/graphql
    end
    
    rect rgb(255, 248, 240)
        Note over G,M: 4. API GATEWAY ORQUESTA MICROSERVICIOS
        G->>G: 📝 Parsear GraphQL Query
        G->>G: 🔍 Resolver Schema
        G->>+M: HTTP Request a Microservicio
        Note over M: Procesar lógica de negocio
    end
    
    rect rgb(248, 240, 255)
        Note over M,D: 5. ACCESO A BASE DE DATOS
        M->>+D: SQL/MongoDB Query
        D->>-M: Datos solicitados
        M->>-G: JSON Response
    end
    
    rect rgb(240, 255, 248)
        Note over G,U: 6. RESPUESTA COMPLETA
        G->>G: 📋 Compilar Response GraphQL
        G->>-N: JSON GraphQL Response
        N->>N: ➕ Headers Seguridad API
        N->>-U: 200 OK + Datos JSON
    end
    
    Note over U,D: ✅ Request Completo con Seguridad
```

---

## ⚙️ **CONFIGURACIÓN DETALLADA**

### **🔗 Upstream Servers (Destinos Internos)**

```nginx
# Destino 1: API Gateway (GraphQL)
upstream api_gateway {
    server api-gateway:4000;    # Nombre del contenedor + puerto interno
    keepalive 32;               # Pool de conexiones reutilizables
}

# Destino 2: Frontend Next.js
upstream frontend {
    server gx_fe_gradex:3000;   # Nombre del contenedor + puerto interno
    keepalive 32;               # Pool de conexiones reutilizables
}
```

### **🎯 Routing Rules (Reglas de Direccionamiento)**

| **Ruta de Entrada** | **Destino Interno** | **Propósito** |
|---------------------|---------------------|---------------|
| `/nginx-health` | Respuesta directa nginx | Health check del proxy |
| `/graphql` | `api-gateway:4000` | API GraphQL para datos |
| `/` (todo lo demás) | `gx_fe_gradex:3000` | Frontend Next.js |

### **🛡️ Configuración de Seguridad**

```nginx
# Rate Limiting (Límites de Requests)
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;     # API: 10 req/seg
limit_req_zone $binary_remote_addr zone=general_limit:10m rate=30r/s; # General: 30 req/seg

# Headers de Seguridad Globales
add_header X-Frame-Options "SAMEORIGIN" always;                    # Anti-clickjacking
add_header X-Content-Type-Options "nosniff" always;               # Anti-MIME sniffing
add_header X-XSS-Protection "1; mode=block" always;               # Anti-XSS
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; ..." always; # CSP completa
```

### **⏱️ Timeouts y Límites**

| **Configuración** | **Valor** | **Propósito** |
|-------------------|-----------|---------------|
| `client_max_body_size` | 10M | Límite de uploads |
| `client_body_timeout` | 60s | Timeout subida datos |
| `client_header_timeout` | 60s | Timeout headers |
| `proxy_connect_timeout` | 30s | Timeout conexión backend |
| `proxy_send_timeout` | 30s | Timeout envío backend |
| `proxy_read_timeout` | 30s | Timeout lectura backend |

---

## 🔒 **ARQUITECTURA DE SEGURIDAD**

### **🛡️ Capas de Protección**

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET PÚBLICO                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│               NGINX PROXY (Puerto 80)                      │
│ ✅ Rate Limiting        ✅ Headers Seguridad               │
│ ✅ Bloqueo Archivos     ✅ Validación HTTP                 │
│ ✅ Logging Completo     ✅ Timeouts                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              RED INTERNA DOCKER                            │
│ 🔒 Frontend (3000)     🔒 API Gateway (4000)              │
│ 🔒 SIA (8000)          🔒 Auth (8082)                     │
│ 🔒 Profesores (8080)   🔒 Calificaciones (8080)           │
│ 🔒 Broker (3000)       🔒 Bases de Datos                  │
└─────────────────────────────────────────────────────────────┘
```

### **🚫 Archivos y Rutas Bloqueadas**

```nginx
# Archivos ocultos (empiezan con punto)
location ~ /\. {
    deny all;                    # ❌ Bloquear .env, .git, .htaccess, etc.
}

# Archivos sensibles por extensión
location ~ \.(sql|conf|config|bak|backup|swp|tmp)$ {
    deny all;                    # ❌ Bloquear backups y configuraciones
}

# Métodos HTTP no permitidos
if ($request_method !~ ^(GET|POST|OPTIONS)$ ) {
    return 405;                  # ❌ Solo GET, POST, OPTIONS
}
```

---

## 🎯 **ROUTING Y DIRECCIONAMIENTO**

### **📍 Mapeo Completo de URLs**

| **URL Pública** | **Destino Real** | **Función** |
|-----------------|------------------|-------------|
| `http://localhost/` | `gx_fe_gradex:3000/` | Página principal |
| `http://localhost/login` | `gx_fe_gradex:3000/login` | Página de login |
| `http://localhost/administrador` | `gx_fe_gradex:3000/administrador` | Panel admin |
| `http://localhost/docente` | `gx_fe_gradex:3000/docente` | Panel docente |
| `http://localhost/graphql` | `api-gateway:4000/graphql` | API GraphQL |
| `http://localhost/nginx-health` | **Respuesta directa nginx** | Health check |

### **🔄 Proceso de Proxy Pass**

```nginx
# Ejemplo: /graphql
location /graphql {
    # 1. Aplicar rate limiting
    limit_req zone=api_limit burst=20 nodelay;
    
    # 2. Validar método HTTP
    if ($request_method !~ ^(GET|POST|OPTIONS)$) {
        return 405;
    }
    
    # 3. Añadir headers de identificación
    add_header X-API-Gateway "GRADEX-v1" always;
    
    # 4. Hacer proxy pass con headers
    proxy_pass http://api_gateway;              # → api-gateway:4000
    proxy_set_header Host $host;                # Mantener host original
    proxy_set_header X-Real-IP $remote_addr;   # IP real del cliente
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---

## 🐳 **INTEGRACIÓN CON DOCKER**

### **📦 Configuración en docker-compose.yml**

```yaml
# Nginx Proxy - ÚNICO puerto expuesto externamente
nginx-proxy:
  container_name: gx_nginx_proxy
  ports:
    - "80:80"                                    # ✅ ÚNICO puerto externo
  volumes:
    - ./components/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  depends_on:
    - api-gateway                                # Espera a API Gateway
    - gx_fe_gradex                              # Espera a Frontend
  networks:
    - microservices-network                      # Red interna Docker

# Frontend - Solo puerto interno
gx_fe_gradex:
  container_name: gx_fe_gradex
  expose:
    - "3000"                                     # 🔒 Solo red interna
  environment:
    - API_URL=http://localhost/graphql           # Usar proxy para API

# API Gateway - Solo puerto interno  
api-gateway:
  container_name: gx_api_gateway
  expose:
    - "4000"                                     # 🔒 Solo red interna
```

### **🌐 Resolución de Nombres en Docker**

Docker crea automáticamente un DNS interno donde:
- `api-gateway` → Resuelve a IP interna del contenedor `gx_api_gateway`
- `gx_fe_gradex` → Resuelve a IP interna del contenedor frontend
- Todos están en la red `microservices-network`

---

## 📊 **MONITOREO Y LOGS**

### **📝 Configuración de Logging**

```nginx
# Formato de logs personalizado
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';

access_log /var/log/nginx/access.log main;      # Todos los requests
error_log /var/log/nginx/error.log warn;        # Solo errores
```

### **🔍 Comandos de Monitoreo**

```powershell
# Ver logs en tiempo real
docker logs gx_nginx_proxy -f

# Ver últimas 50 líneas
docker logs gx_nginx_proxy --tail 50

# Ver logs de errores específicos
docker logs gx_nginx_proxy 2>&1 | findstr "error"

# Ver estadísticas de requests
docker exec gx_nginx_proxy cat /var/log/nginx/access.log | findstr "200"
```

### **📈 Información en los Logs**

| **Campo** | **Descripción** | **Ejemplo** |
|-----------|-----------------|-------------|
| `$remote_addr` | IP del cliente | `172.18.0.1` |
| `$time_local` | Timestamp | `[28/Jun/2025:01:43:21 +0000]` |
| `$request` | Request completo | `"GET /graphql HTTP/1.1"` |
| `$status` | Código de respuesta | `200`, `404`, `403` |
| `$http_user_agent` | Navegador | `Mozilla/5.0...` |

---

## 🧪 **TESTING Y VERIFICACIÓN**

### **✅ Health Checks Disponibles**

```powershell
# 1. Health check del proxy
Invoke-WebRequest -Uri "http://localhost/nginx-health"

# 2. Test del frontend
Invoke-WebRequest -Uri "http://localhost/"

# 3. Test del API Gateway (debería dar 400 - normal)
Invoke-WebRequest -Uri "http://localhost/graphql"

# 4. Test de archivos bloqueados (debería dar 403)
Invoke-WebRequest -Uri "http://localhost/.env"
```

### **🔄 Script de Testing Automatizado**

```powershell
# Ejecutar suite completa de tests
powershell -ExecutionPolicy Bypass -File "components/nginx/test-proxy.ps1"
```

### **📊 Resultados Esperados**

| **Test** | **URL** | **Status Esperado** | **Significado** |
|----------|---------|-------------------|-----------------|
| Health Check | `/nginx-health` | `200 OK` | Proxy funcionando |
| Frontend | `/` | `200 OK` | App accesible |
| GraphQL | `/graphql` | `400 Bad Request` | Normal (necesita POST) |
| Archivo .env | `/.env` | `403 Forbidden` | Seguridad activa |
| Archivo .sql | `/backup.sql` | `403 Forbidden` | Seguridad activa |

---

## 🎯 **BENEFICIOS DE ESTA IMPLEMENTACIÓN**

### **🔒 Seguridad**
- **Punto de entrada único**: Solo puerto 80 expuesto
- **Aislamiento de servicios**: Microservicios en red interna
- **Protección DDoS**: Rate limiting por IP
- **Headers de seguridad**: Protección contra XSS, clickjacking
- **Bloqueo de archivos**: `.env`, `.sql`, archivos ocultos inaccesibles

### **⚡ Performance**
- **Connection pooling**: Keepalive hacia backends
- **Balanceador de carga**: Distribución de conexiones
- **Terminación SSL**: Preparado para HTTPS
- **Compression**: Preparado para gzip

### **🛠️ Operacional**
- **Logs centralizados**: Todo el tráfico auditado
- **Health checks**: Monitoreo de disponibilidad
- **Configuración declarativa**: Infrastructure as Code
- **Escalabilidad**: Fácil añadir más backends

---

## 🚀 **PRÓXIMOS PASOS RECOMENDADOS**

1. **🔐 SSL/HTTPS**: Implementar certificados SSL
2. **📊 Métricas**: Integrar con Prometheus/Grafana
3. **🛡️ WAF**: Web Application Firewall
4. **🌐 CDN**: Content Delivery Network para estáticos
5. **📈 Caching**: Cache Redis para responses

---

**✅ El proxy nginx está funcionando perfectamente como capa de seguridad y punto de entrada único para todo el sistema GRADEX.** 