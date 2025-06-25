# GRADEX - Prototipo 2


![image](https://github.com/user-attachments/assets/d511ece6-bccb-4a01-a9cb-1f46cc898cae)


### 1. **Team** 
- name: 2F  
- Integrantes: 
    - David Stiven Martinez Triana 
    - Carlos Sebastian Gomez Fernandez 
    - Nestor Steven Piraquive Garzon 
    - Luis Alfonso Pedraos Suarez 
    - Cesar Fabian Rincon Robayo 
### 2. **Software System** 
- name: Gradex 
- Logo:
  
![image](https://github.com/user-attachments/assets/b3657f68-ea46-4990-8fa8-a0c4b5c26e13)


- Description: Sistema de Gestión de calificaciones para colegios.


## Repositorio del proyecto

Para utilizar el proyecto simplemente clona el repositorio principal, el cual ya incluye todos los submódulos necesarios:

```bash
git clone --recursive https://github.com/Swarch2F/prototipo3.git
cd prototipo3
```

## Información sobre submódulos (Solo informativo)

Los submódulos fueron agregados inicialmente con estos comandos, pero no necesitas ejecutarlos nuevamente:

```bash
git submodule add https://github.com/Swarch2F/component-1.git components/component-1
git submodule add https://github.com/Swarch2F/component-2-1.git components/component-2-1
git submodule add https://github.com/Swarch2F/component-2-2.git components/component-2-2
git submodule add https://github.com/Swarch2F/component-3.git components/component-3
git submodule add https://github.com/Swarch2F/component-4.git components/component-4
git submodule add https://github.com/Swarch2F/broker.git components/broker
git submodule add https://github.com/Swarch2F/api-gateway.git components/api-gateway
```

## Actualización de submódulos recursivamente (por primer vez una vez clonado el proyecto):

```bash
git submodule update --init --recursive
git submodule update --remote --merge --recursive
```

## Levantar el prototipo con Docker Compose

El proyecto utiliza Docker Compose para gestionar la ejecución de todos los servicios.

### Ejecución rápida

Una vez clonado el proyecto, ejecuta:

```bash
docker compose up --build
```

OJO, para ejecutar todo correctamente se necesitan las variables de entorno del servicio
de autenticación, las cuales son sensibles, pero se puede cargar el archivo .env y ejecutar el scrip
que automatiza todo:

```bash
./start.sh
```

## Acceso a servicios

Puedes acceder a cada servicio desde tu navegador en las siguientes rutas:

* **API Gateway (gx_comun_gateway):** `http://localhost:9000/`
* **Gestión de Estudiantes y Cursos (gx_be_estcur):** `http://localhost:8083/`
* **Profesores y Asignaturas (gx_be_proasig):** `http://localhost:8080/graphiql`
* **Calificaciones (gx_be_calif):** `http://localhost:8081/graphiql`
* **Autenticación (gx_be_auth):** `http://localhost:8082/api/v1`
* **RabbitMQ Management:** `http://localhost:15673/`

### Gestión de contenedores

Para verificar el estado de los contenedores utiliza:

```bash
docker ps
```

Para pausar un contenedor utiliza el siguiente comando:
```bash
docker compose stop <nombre del contenedor>
```

Para volver a ejecutar un contenedor pausado utiliza el siguiente comando:
```bash
docker compose start <nombre del contenedor>
```

## Bases de datos

El proyecto utiliza PostgreSQL para el almacenamiento de datos. Las bases de datos se inicializan automáticamente con datos de prueba y se persisten en volúmenes de Docker.

### Configuración de bases de datos

* **Base de datos principal (gx_db_estcur):**
  - Puerto: 5432
  - Usuario: postgres
  - Contraseña: postgres
  - Base de datos: gradex_estcur

* **Base de datos de autenticación (gx_db_auth):**
  - Puerto: 5433
  - Usuario: postgres
  - Contraseña: postgres
  - Base de datos: gradex_auth

## Notas importantes

- Las credenciales por defecto para RabbitMQ son:
  - Usuario: guest
  - Contraseña: guest
- La base de datos PostgreSQL para estudiantes y cursos se inicializa automáticamente con datos de prueba
- Los datos de las bases de datos se persisten en volúmenes de Docker
- El servicio de autenticación utiliza JWT para la gestión de tokens
- Los servicios GraphQL (Profesores y Asignaturas, Calificaciones) incluyen una interfaz GraphiQL para pruebas

---
**© 2025 Swarch2F. GRADEX Prototipo 2** 
