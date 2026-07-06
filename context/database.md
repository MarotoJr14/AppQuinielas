# Base de datos

La base de datos será PostgreSQL, usando modelos SQLAlchemy 2.0 y Alembic para las migraciones.

---

## Índice

1. [Tablas](#tablas)
2. [Relaciones](#relaciones)
3. [Restricciones](#restricciones)
4. [Enums](#enums)
5. [Indices](#indices)

---

## Tablas

### 1. Usuario
Usuario de la aplicación.
- id (int): PK
- nombre_usuario (str): UQ, NN
- contraseña (str): NN
- correo_electrónico (str): UQ, NN

### 2. Grupo (peña)
Grupo de usuarios que realizan quinielas.
- id (int): PK
- nombre (str): UQ, NN
- contraseña (str): NN

### 3. Usuario - Grupo
Tabla de unión de Usuario y Grupo.
- id (int): PK
- grupo_id (int): FK, NN
- usuario_id (int): FK, NN
- es_lider (bool): NN, def(FALSE)

### 4. Temporada
Las quinielas se organizan en temporadas, equivalentes a las temporadas de la Liga española de fútbol.
- id (int): PK
- nombre (str): UQ, NN

### 5. Jornada
Conjunto de partidos sobre los cuales se realiza una quiniela. Lo conforman obligatoriamente 14 partidos + 1 partido especial: el Pleno al 15.
- id (int): PK
- temporada_id (int): FK, NN
- nombre (str): NN
- fecha_cierre (datetime): UQ

### 6. Premio
Lista de premios de una jornada.
- id (int): PK
- jornada_id (int): FK, NN
- categoría (enum): NN
- valor (float): 

### 7. Competición
Competición deportiva cuyos partidos aparecen en una quiniela.
- id (int): PK
- nombre (str): UQ, NN
- ámbito (str): NN
- es_clubes (bool): NN, def(TRUE)

### 8. Temporada - Competición
Tabla de unión de Temporada y Competición.
- id (int): PK
- temporada_id (int): FK, NN
- competición_id (int): FK, NN

### 9. Equipo
Equipo que juega partidos de una quiniela.
- id (int): PK
- nombre (str): UQ, NN
- es_club (bool): NN, def(TRUE)
- país (str): NN

### 10. Equipo - Temporada - Competición
Tabla de unión de Equipo y Temporada-Competición
- id (int): PK
- equipo_id (int): FK, NN
- temporada_competicion_id (int): FK, NN

### 11. Partido
Cada partido que forma parte de una jornada de quinielas.
- id (int): PK
- jornada_id (int): FK, NN
- orden (int): NN
- competicion_temporada_id (int): FK
- fecha_hora (datetime): 
- canal (str): 
- equipo_local_id (int): FK
- equipo_visiante_id (int): FK
- goles_local (int): 
- goles_visitante (int): 

### 12. Apuesta
Apuesta o quiniela que realiza un grupo sobre los partidos de una jornada concreta.
- id (int): PK
- jornada_id (int): FK, NN
- grupo_id (int): FK, NN
- usuario_elige8_id (int): FK, NN
- estado (enum.estado): NN
- precio (float): 
- beneficio (float): 

### 13. Columna
Apuesta individual de un usuario para los partidos de una jornada concreta.
- id (int): PK
- apuesta_id (int): FK, NN
- usuario_id (int): FK, NN
- es elige8 (bool): NN

### 14. Pronóstico
Apuesta de un usuario a un partido en concreto de una jornada.
- id (int): PK
- columna_id (int): FK, NN
- partido_id (int): FK, NN
- signo (enum.signo): 
- plenoal15_local (enum.goles): 
- plenoal15_visitante (enum.goles): 

### 15. Mensaje
Mensake que manda un usuario al chat de un grupo
- id
- grupo_id (int): FK, NN
- usuario_id (int): FK, NN
- datetime (datetime): NN
- contenido (str): NN

### 16. Audit Log
Registro de auditoría para ver las operaciones que se han realizado.
- id
- operacion (enum.operacion): NN
. tabla (enum.tabla): NN
- usuario_id (int): FK, NN
- oservaciones (Str):

### Tips
Todas las tablas tendrán los atributos de tipo datetime created_at y updated_at

---

## Relaciones

### Usuario N:M Grupo
Un usuario puede pertenecer simultáneamente a varios grupos, y a su vez un grupo puede tener varios usuarios.

### Temporada 1:N Jornada
Una temporada agrupa muchas jornadas, pero una jornada solo pertenece a una temporada concreta. Las jornadas

### Jornada 1:N Premios
Una jornada tiene una serie de premios, en las categorías de 15 aciertos, 14 aciertos, 13 aciertos, 12 aciertos, 11 aciertos, 10 aciertos, y la categoría especial de Elige 8.

### Temporada N:M Competición
Una competición tiene varias temporadas, y una temporada implica varias competiciones.

### Equipo N:M Temporada-Competición
Una edición de una competición tiene varios equipos, y un equipo puede estar en varias ediciones de varias competiciones.

### Jornada 1:N Partido
Una jornada tiene concretamente 15 partidos, pero un partido pertenece solo a una jornada.

### Jornada 1:N Apuesta
Una apuesta corresponde a una jornada concreta, pero una jornada puede recibir múltiples apuestas.

### Usuario 1:N Apuesta
Un usuario es el responsable de hacer la columna especial "Elige8" de múltiples apuestas, pero la columna especial "Elige8" de una apuesta sólo la puede hacer un usuario.

### Grupo 1:N Apuesta
Una apuesta es realizada por un único grupo, pero un grupo puede realizar muchas apuestas.

### Apuesta 1:N Columna
Una apuesta está formada por varias columnas, pero una columna se realiza sólo para una sola apuesta.

### Partido 1:N Pronóstico
Un partido puede tener varios pronósticos, pero un pronóstico es de un solo partido.

### Columna 1:N Pronóstico
Una columna tiene varios pronósticos (uno para cada partido implicado), pero un pronóstico es para una columna en concreto.

### Grupo 1:N Mensaje
Un mensaje es enviado al chat de un unico grupo pero un grupo puede tener muchos mensajes.

### Usuario 1:N Mensaje
Un mensaje es enviado por un unico usuario pero un usuario puede enviar muchos mensajes.

### Usuario 1:N Audit Log
Un usuario realiza muchas operaciones, pero una operación solo es realizada por un usuario

---

## Restricciones

### 1. Usuario - Grupo
- grupo_id x usuario_id: UQ
- grupo_id x es_lider=true: UQ

### 2. Jornada
- temporada_id x nombre: UQ

### 3. Premios
- jornada_id x categoria: UQ

### 4. Temporada - Competición
- temporada_id x competicio_id: UQ

### 5. Equipo - Temporada - Competición
- equipo_id x temporada_competicion_id: UQ

### 6. Partido
- jornada_id x orden: UQ

### 7. Apuesta
- jornada_id x grupo_id: UQ

### 8. Columna
- apuesta_id x es_elige8=true: UQ

### 9. Pronóstico
- columna_id x partido_id: UQ

---

## Enums

### 1. signo
- 1
- X
- 2

### 2. goles
- 0
- 1
- 2
- M

### 3. estado
- pendiente
- cerrada
- en_curso
- finalizada

### 4. categoria
- 15 aciertos
- 14 aciertos
- 13 aciertos
- 12 aciertos
- 11 aciertos
- 10 aciertos
- elige 8

### 5. operacion
- create
- update
- delete

### 6. tabla
- usuario
- grupo
- usuario-grupo
- temporada
- jornada
- premio
- competicion
- temporada-competicion
- equipo
- equipo-temporada-competicion
- partido
- apuesta
- columna
- pronostico
- mensaje

---

## Indices

Los necesarios para un funcionamiento óptimo de la aplicación.

---