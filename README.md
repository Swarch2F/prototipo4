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

### 3. Architectural Structures


### Component-and Connector (C&C) Structure
**C&C View**
![image](https://github.com/user-attachments/assets/5dfe302b-2cb0-4190-8594-a60dd7a8362c)


#### **Description of architectural styles and patterns used.**


**Microservicios**:
Servicios independientes: por ejemplo GX_BE_EstCur y GX_BE_ProAsig son dos servicios backend autónomos:
Usan frameworks diferentes (Django y Spring Boot).
Están desplegados en puertos distintos (8083 y 8080).
Manejan bases de datos separadas (PostgreSQL y MongoDB respectivamente).
Se comunican externamente con el api gateway mediante HTTP (REST o GraphQL), y no hay acoplamiento directo entre ellos.


**Description of architectural patterns used**:
*API Gateway Pattern:* Punto único de entrada (Puerto 9000), maneja la orquestación de los microservicios.  Ocultando la complejidad del sistema a los clientes (Next.js/Electrón).

*Event-driven architecture:* Implementado por: gx_be_comun_async y gx_be_rabbitmq, Comunicación basada en eventos asíncronos a través de RabbitMQ. Permitiendo desacoplar procesos que no necesitan respuesta inmediata.

*Database per Service:* Cada microservicio tiene su propia base de datos dedicada, en lugar de compartir una base de datos centralizada. Esto promueve la independencia, el aislamiento y la escalabilidad de los microservicios. 
			
**Description of architectural elements and relations:**

Descripción de Componentes:

**GX_FE_Gradex (Frontend Web)**
Función: Interfaz gráfica para usuarios finales vía navegador web.
Tecnología: Next.js (React)
Propósito: Permite a los usuarios la gestión de calificaciones (estudiantes, profesores, asignaturas, cursos) para colegios.
Conexión: Se comunica con gx_api_gateway a través de HTTP utilizando GraphQL.

**GX_WD_Gradex (Aplicación de Escritorio)**
Función: Interfaz gráfica instalada localmente para windows en el dispositivo del usuario.
Tecnología: Electron.js
Propósito: Ofrecer la gestión de asignaturas para los usuarios finales.
Conexión: Igual que el frontend web, se comunica con gx_api_gateway mediante HTTP/GraphQL.

**gx_api_gateway (API Gateway)**
Función: Punto único de entrada al sistema backend.
Tecnología: Node.js (Express.js) + Apollo Server (GraphQL)
Propósito: Orquestar microservicios y centralizar todas las solicitudes externas. Expone GraphQL hacia los frontends y resuelve consultas delegándolas a los microservicios internos.
Conexión: HTTP (REST o GraphQL) a todos los microservicios.

**gx_be_comun_async (Broker HTTP Asíncrono)**
Función: gestionar flujos de eventos asíncronos.
Tecnología: Node.js (Express.js)
Propósito: Recibe eventos desde RabbitMQ y los reenvía al microservicio gx_be_calif por HTTP.
Conexión: AMQP (con gx_be_rabbitmq) + HTTP REST con  gx_be_calif.

**gx_be_rabbitmq (Broker de Mensajes)**
Función: Sistema de mensajería asíncrona.
Tecnología: RabbitMQ
Propósito: realizar la cola de mensajes de las peticiones realizadas para el microservicio de gx_be_calif.
Conexión: Protocolo AMQP con gx_be_comun_async.

**GX_BE_EstCur (Microservicio de estudiantes y cursos)**
Función: Gestionar información de estudiantes y cursos.
Tecnología: Django (Python)
Conexión: HTTP REST con el API Gateway. TCP/IP con base de datos PostgreSQL.

**GX_BE_ProAsig (Microservicio de Profesores y Asignaturas)**
Función: Gestión académica de profesores y asignaturas.
Tecnología: Spring Boot (Java)
Propósito: Encargado de la administración del personal docente y sus materias asignadas.
Conexión: HTTP GraphQL con el API Gateway. TCP/IP con MongoDB.

**GX_BE_Calif (Microservicio de Calificaciones)**
Función: Administración de las calificaciones de los estudiantes.
Tecnología: Spring Boot (Java)
Propósito: Permite consultar, actualizar y almacenar calificaciones académicas.
Conexión: HTTP GraphQL con el API Gateway. TCP/IP con MongoDB.

**GX_DB_EstCur (Base de Datos del Microservicio de estudiantes/cursos)**
Función: Persistencia de datos relacionados a cursos y estudiantes.
Tecnología: PostgreSQL
Propósito: Base de datos relacional que asegura integridad de datos de estudiantes y cursos.

**GX_DB_ProAsig (Base de Datos del Microservicio Profesores/Asignaturas)**
Función: Persistencia de datos para profesores y asignaturas.
Tecnología: MongoDB
Propósito: Base de datos NoSQL flexible para almacenar documentos relacionados a materias y docentes.

**GX_DB_Calif (Base de Datos del Microservicio de Calificaciones)**
Función: Persistencia de calificaciones estudiantiles.
Tecnología: MongoDB
Propósito: Almacena las notas de los estudiantes de forma flexible y escalable.

**GX_BE_Auth (Microservicio de Autenticación)**
Función: Gestionar la autenticación, registro de usuarios y emisión de tokens (JWT).
Tecnología: Go
Propósito: Encargado de validar credenciales, gestionar sesiones, emisión de tokens de acceso y registro de usuario.
Conexión:HTTP REST con el gx_api_gateway (para exponer el login, registro, etc.)
TCP/IP con su base de datos PostgreSQL.

**GX_DB_Auth (Base de Datos del microservicio de autenticación)**
Función: Almacenar credenciales, usuarios, roles, etc.
Tecnología: PostgreSQL
Propósito: Persistencia segura de la información relacionada con la autenticación.
Conexión: Comunicación directa TCP/IP con GX_BE_Auth.


#### Descripción de Conectores:

| Origen | Destino | Protocolo | Puerto | Propósito / Descripción |
| :---- | :---- | :---- | :---- | :---- |
| GX\_FE\_Gradex | gx\_api\_gateway | HTTP (GraphQL) | 9000 | Comunicación del frontend web con el API Gateway. |
| GX\_WD\_Gradex | gx\_api\_gateway | HTTP (GraphQL) | 9000 | Comunicación del frontend de escritorio con backend. |
| gx\_api\_gateway | GX\_BE\_Auth | HTTP (REST) | 8082 | Autenticación de usuarios. |
| gx\_api\_gateway | GX\_BE\_EstCur | HTTP (REST) | 8083 | Gestión de estudiantes y cursos. |
| gx\_api\_gateway | GX\_BE\_ProAsig | HTTP (GraphQL) | 8080 | Gestión de profesores y asignaturas. |
| gx\_api\_gateway | GX\_BE\_Calif | HTTP (GraphQL) | 8081 | Gestión de calificaciones académicas. |
| gx\_api\_gateway | gx\_be\_comun\_async | HTTP (REST) | 8081 | Manejo de eventos asíncronos. |
| gx\_be\_comun\_async | gx\_be\_rabbitmq | AMQP | 5673 | Publicación y consumo de eventos. |
| GX\_BE\_EstCur | GX\_DB\_EstCur | TCP/IP | 5433 | Persistencia de datos estudiantes y cursos. |
| GX\_BE\_ProAsig | GX\_DB\_ProAsig | TCP/IP | 27018 | Persistencia de datos de profesores y asignaturas. |
| GX\_BE\_Calif | GX\_DB\_Calif | TCP/IP | 27019 | Persistencia de calificaciones. |
| GX\_BE\_Auth | GX\_DB\_Auth | TCP/IP | 5432 | Persistencia de datos de usuarios y credenciales. |



### Layered Structure
#### Layered View:
![layered 2](https://github.com/user-attachments/assets/a8394cd9-174a-481f-9b28-e3fadae4f691)



####  Description:

  **Capa de Presentación**
  Permite la interacción del usuario a través de:
  Web (Next.js) y Escritorio (Electron).
  Se comunica con el sistema mediante GraphQL hacia el API Gateway.

  **Capa de Comunicación**
  Gestiona la entrada de solicitudes y coordina servicios.
  API Gateway (Apollo \+ Express.js) para centralizar peticiones.
  Broker asíncrono (Express.js) con RabbitMQ para procesamiento de eventos.

  **Capa Lógica**
  Contiene la lógica de negocio:
  Autenticación (Go)
  Gestión académica (Django)
  Profesores, asignaturas y calificaciones (Spring Boot)

  **Capa de Datos**
  Responsable de persistir la información:
  PostgreSQL para autenticación y datos académicos generales.
  MongoDB para profesores, asignaturas y calificaciones.

### Deployment Structure
#### Deployment View

![Diagrama de Despliegue (1)](https://github.com/user-attachments/assets/15383adf-be29-48fd-be31-c21036043a0b)



Este sistema está compuesto por múltiples microservicios y componentes backend que se ejecutan dentro de una red interna Docker, y un componente cliente desarrollado con Electron.js, que opera desde el dispositivo del usuario final como aplicación de escritorio. Todos los servicios están expuestos por distintos puertos y protocolos, y se comunican mediante HTTP, AMQP o TCP/IP.

 **Cliente de Escritorio \- Electron.js**

* **Tipo**: Aplicación de escritorio.  
* **Tecnología**: Electron.js (Node.js \+ Chromium)  
* **Ubicación**: Fuera del entorno Docker, en el equipo del. usuario.  
* **Función**:  
  * Interfaz gráfica de usuario del sistema.  
  * Se conecta a múltiples servicios del backend mediante HTTP, AMQP o TCP/IP.  
  * Sirve como punto de entrada principal del sistema para los usuarios finales.

 **Red Interna Docker**

Contiene todos los contenedores y servicios backend. Se encuentra encapsulada en una red interna aislada que permite la comunicación entre servicios por nombre y puerto.

 **1\. GX\_BE\_Auth (Go)**

**Nombre del contenedor:** gx\_be\_auth  
 **Tecnología:** Go

**Puerto expuesto:** 8082  
 **Rol:** Microservicio de Autenticación  
 **Responsabilidad:** Gestiona autenticación, registro, validación de credenciales, emisión de tokens JWT, y mantiene la seguridad del sistema mediante el control de acceso.

 **2\. GX\_BE\_EstCur (Django/Python)**

**Nombre del contenedor:** gx\_be\_estcur  
 **Tecnología:** Django (Python)

**Puerto expuesto:** 8083  
 **Rol:** Microservicio de Gestión de Estudiantes y Cursos  
 **Responsabilidad:** Manejo de operaciones CRUD relacionadas con estudiantes y cursos, administración de perfiles estudiantiles y organización académica básica.

 **3\. GX\_BE\_ProAsig (Spring Boot/Java)**

**Nombre del contenedor:** gx\_be\_proasig  
 **Tecnología:** Spring Boot (Java)

**Puerto expuesto:** 8080  
 **Rol:** Microservicio de Gestión de Profesores y Asignaturas  
 **Responsabilidad:** Administración de los docentes y sus asignaturas asociadas. Permite crear, modificar, consultar y eliminar la información académica del personal docente.

 **4\. GX\_BE\_Calif (Spring Boot/Java)**

**Nombre del contenedor:** gx\_be\_calif  
 **Tecnología:** Spring Boot (Java)

**Puerto expuesto:** 8081  
 **Rol:** Microservicio de Calificaciones  
 **Responsabilidad:** Control de las notas de los estudiantes: creación, modificación, consulta y almacenamiento seguro de calificaciones académicas.

 **5\. GX\_FE\_Gradex (Next.js/React)**

**Nombre del contenedor:** gx\_fe\_gradex  
 **Tecnología:** Next.js (React)

**Puerto expuesto:** 3000  
 **Rol:** Cliente Web  
 **Responsabilidad:** Proporciona la interfaz gráfica del sistema GRADEX accesible desde navegadores web para estudiantes, profesores y administradores.

 **6\. GX\_FE\_Gradex\_Desktop (Electron.js)**

**Nombre del contenedor:** GX\_FE\_Gradex\_Desktop  
 **Tecnología:** Electron.js

**Puerto expuesto:** 4000  
 **Rol:** Cliente de Escritorio  
 **Responsabilidad:** Interfaz nativa multiplataforma instalada en el dispositivo del usuario final. Permite interacción con el sistema mediante GUI conectándose al API Gateway.

 **7\. gx\_api\_gateway (Node.js/Apollo Server)**

**Nombre del contenedor:** gx\_api\_gateway  
 **Tecnología:** Node.js \+ Apollo Server

**Puerto expuesto:** 9000  
 **Rol:** API Gateway  
 **Responsabilidad:** Punto único de entrada al backend. Orquesta peticiones de frontends a microservicios. Expone GraphQL y maneja autenticación, validación y delegación de llamadas.

 **8\. gx\_be\_comun\_async (Node.js)**

**Nombre del contenedor:** gx\_be\_comun\_async  
 **Tecnología:** Node.js (Express.js)

**Puerto expuesto:** 8081  
 **Rol:** Broker HTTP Asíncrono  
 **Responsabilidad:** Recibe eventos desde RabbitMQ y los retransmite al microservicio gx\_be\_calif por HTTP, facilitando una arquitectura basada en eventos.

 **9\. gx\_be\_rabbitmq (RabbitMQ)**

**Nombre del contenedor:** gx\_be\_rabbitmq  
 **Tecnología:** RabbitMQ

**Puerto expuesto:** 5673  
 **Rol:** Sistema de Mensajería Asíncrona  
 **Responsabilidad:** Actúa como cola de mensajes AMQP para desacoplar procesos. Recibe, mantiene y entrega mensajes entre servicios de manera fiable y asincrónica.

 **10\. GX\_DB\_Auth (PostgreSQL)**

**Nombre del contenedor:** gx\_db\_auth  
 **Tecnología:** PostgreSQL

**Puerto expuesto:** 5432  
 **Rol:** Base de Datos de Autenticación  
 **Responsabilidad:** Almacena usuarios, credenciales, roles y tokens de sesión relacionados con el servicio de autenticación.

 **11\. GX\_DB\_EstCur (PostgreSQL)**

**Nombre del contenedor:** gx\_db\_estcur  
 **Tecnología:** PostgreSQL

**Puerto expuesto:** 5433  
 **Rol:** Base de Datos de Estudiantes y Cursos  
 **Responsabilidad:** Persistencia estructurada de la información académica básica como estudiantes y cursos.

 **12\. GX\_DB\_ProAsig (MongoDB)**

**Nombre del contenedor:** gx\_db\_proasig  
 **Tecnología:** MongoDB

**Puerto expuesto:** 27018  
 **Rol:** Base de Datos de Profesores y Asignaturas  
 **Responsabilidad:** Almacena datos académicos del personal docente y sus materias de forma flexible usando documentos JSON.

 **13\. GX\_DB\_Calif (MongoDB)**

**Nombre del contenedor:** gx\_db\_calif  
 **Tecnología:** MongoDB

**Puerto expuesto:** 27019  
 **Rol:** Base de Datos de Calificaciones  
 **Responsabilidad:** Gestión de las calificaciones estudiantiles. Permite un almacenamiento eficiente y escalable de las evaluaciones.

 **Nodo de Despliegue (Servidor on-premise)**

* **Procesador:** Intel Core i5 @ 2.27GHz  
* **Memoria RAM:** 8 GB  
* **Disco Duro:** 1 TB SSD  
* **Tipo de Despliegue:** Servidor físico local (on-premise)  
* **S.O. y Contenedores:** Se asume sistema Linux con servicios desplegados como contenedores Docker
  

### Decomposition Structure
#### Decomposition View

![Diagrama de Descompocicion2](https://github.com/user-attachments/assets/0a7d19bb-a6c7-454d-8308-0dd226006d09)




#### Description of architectural elements and relations:

* **GX\_FE\_Gradex**: Es el componente frontend del sistema GRADEX para una web app, encargado de la interfaz de usuario donde estudiantes, profesores y administradores interactúan con la plataforma. Proporciona formularios, listados y visualización de datos, comunicándose con el API Gateway para realizar todas las operaciones.


* **GX\_WD\_Gradex**: Es el componente frontend del sistema GRADEX para una aplicación de escritorio, encargado de la interfaz de usuario donde estudiantes, profesores y administradores interactúan con la plataforma. Proporciona formularios, listados y visualización de datos, comunicándose con el API Gateway para realizar todas las operaciones.


* **gx\_api\_gateway**: Actúa como intermediario entre el frontend y los microservicios backend. Centraliza todas las solicitudes, enrutándolas al servicio correspondiente y manejando aspectos como autenticación y unificación de respuestas para simplificar la comunicación.


* **GX\_BE\_Auth**: Se encarga de la autenticación y gestión de usuarios, incluyendo registro e inicio de sesión para estudiantes, profesores y administradores. Garantiza el acceso seguro al sistema mediante validación de credenciales.


* **GX\_BE\_EstCur**: Gestiona la información relacionada con estudiantes y cursos, permitiendo operaciones como creación, consulta, modificación y eliminación de registros. Es fundamental para la administración académica básica.


* **GX\_BE\_Calif**: Administra todo lo referente a calificaciones, incluyendo su registro, consulta y actualización. Este componente asegura que los datos de evaluación de los estudiantes sean almacenados y accesibles de manera confiable.


* **Registro**: Proceso específico para dar de alta nuevos usuarios en el sistema, ya sean profesores o administradores, validando sus datos antes de permitirles acceso.


* **Login**: Módulo que autentica a los usuarios (profesores y administradores) mediante credenciales, permitiéndoles ingresar a sus respectivas áreas dentro de la plataforma.


* **Estudiantes**: Área dedicada a la gestión de perfiles estudiantiles, donde se pueden realizar acciones como agregar, consultar, modificar o eliminar estudiantes del sistema.


* **Cursos**: Componente que maneja la creación, consulta, actualización y eliminación de cursos, facilitando la organización de la oferta académica.


* **Calificaciones**: Sección especializada en el manejo de las notas y evaluaciones de los estudiantes, permitiendo su registro y modificación según sea necesario.


* **Broker**: Elemento que actúa como cola de mensajes en la comunicación entre el servicio de calificaciones, asegurando que los mensajes y datos fluyan correctamente entre los componentes.


* **Profesor**: Rol dentro del sistema que tiene permisos para gestionar calificaciones de estusiantes, además de acceder a información específica de los estudiantes que enseña.


* **Administrador**: Rol con privilegios elevados para gestionar usuarios, cursos y configuraciones globales del sistema, asegurando su correcto funcionamiento y crear y administrar profesores asignaturas y cursos.


* **Crear/Consultar/Eliminar/Modificar**: Operaciones básicas disponibles en distintos módulos del sistema, permitiendo la administración completa de estudiantes, cursos y calificaciones.

## Repositorio del proyecto

Para utilizar el proyecto simplemente clona el repositorio principal, el cual ya incluye todos los submódulos necesarios:

```bash
git clone --recursive https://github.com/Swarch2F/prototipo2.git
cd prototipo2
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
