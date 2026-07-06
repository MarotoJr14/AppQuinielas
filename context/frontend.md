# Frontend

El frontend se realizará en Flutter, ya que la app debe correr en iOS y Android.

Se trata de una aplicación para gestionar quinielas por parte de muchos usuarios organizados en grupos (también llamados peñas).
El usuario deberá escoger el grupo en el que quiere hacer cualquier operación, es decir, cada grupo tiene su espacio, y no se deberá mezclar.

---

## Índice

1. [Temas](#temas)
2. [Pantallas login](#pantallas-login)
3. [Widgets](#widgets)
4. [Pantallas app](#pantallas-app)

---

## Temas

La app tendrá tema claro y oscuro, y almacenará la elección del usuario. Por defecto, se cargará la app con el tema claro.

Estos son los principales colores que se usarán:

- Fondo tema claro: #F8F7F4
- Fondo tema oscuro: #121212
- Acento: #C9A227
- Aciertos: #2E8B57
- Errores: #C94A4A

## Pantallas login

### 1. Login

Pantalla simple de login con nombre de usuario y contraseña.

Además contendrá 2 botones:
- Recuperar contraseña
- Nuevo usuario

### 2. Registro

Pantalla de registro de un usuario nuevo, a la cual se accede sólo desde la pantalla de login.

Contiene un formulario en el cual el usuario deberá introducir el correo electrónico, nombre de usuario, contraseña (y confirmar contraseña).

Restricciones:
- El correo electrónico no almacenará letras mayñusculas.
- El nombre de usuario solo aceptará letras minúsculas y números.
- La contraseña deberá contener al menos 8 caracteres, con al menos 1 mayúscula, 1 minúscula
    - Si las contraseñas no coinciden, o la contraseña introducida no cumple con la restricción se lanzará el error correspondiente.

### 3. Recuperar contraseña

Pantalla para recuperar contraseña. Comienza con un formulario en el cual el usuario debe introducir el correo electrónico vinculado al usuario.
- Si no hay un usuario con ese correo en la bd, se lanzará el error correspondiente.

Si existe, se le habilitará una segunda parte del formulario con los campos "Nueva contraseña" y "Confirmar nueva contraseña".

Al finalizar se volverá a la pantalla del login.

---

## Widgets
Elementos de la aplicación comunes a todas las pantallas de la misma, salvo las de la sección de login.

### 1. Header
Sección superior de la pantalla. Contiene en la esquina izquierda un botón que despliega un menú lateral con las distintas secciones de la app.

Ubicado en el centro contiene el nombre del grupo en el que se encuentra el usuario (o el texto "Inicio" si está en la pantalla de Home)

A la derecha, el nombre de usuario que ha iniciado sesión, junto a un círculo con la inicial del usuario a la izquierda y un botón para logout a la cerecha.

### 2. Menú lateral

El menú lateral contendrá el logo de la app y el nombre de la app, y debajo de eso empezará la lista de secciones. Estas serán las siguientes:

- Inicio: Lleva a la pantalla de home
- Nueva quiniela
- Quinielas en cola
- Ver quiniela en curso
- Últimos resultados
- Estadísticas
- Configuración del grupo

---

## Pantallas app

### 1. Home

La pantalla de home, contendrá una lista con 1 card por cada grupo o peña del usuario. Encima de ls lista de cards, habrá un buscador para facilitar la búsqueda, por si un usuario forma parte de muchos grupos. La lista de cards tendrá una paginación de 10 cards por página.

Además, en la parte superior, habrá 2 botones:
- Crear un grupo
- Unirse a un grupo

Al hacer click en un grupo, se cambia al dashboard del grupo.

El usuario con id 1 tiene un permiso extra que es el administrador del sistema. Esta función se mostrará como un card más del home, y servirá para agregar jornadas, con todo lo que eso conlleva (introducir los partidos, etc.), asignar los premios de las jornadas, y ese tipo de cosas.

### 2. Crear un grupo

Pantalla con un formulario con los datos de un grupo: Nombre y contraseña del grupo.

Al confirmar el envío de los datos, se creará el registro del grupo y se creará un registro en Usuario-Grupo para el usuario que ha creado el grupo, donde el atributo es_lider será TRUE.

### 3. Unirse a un grupo

Pantalla para entrar en un grupo existente. El usuario deberá introducir el nombre y la contraseña del grupo correctamente para poder entrar.

Al confirmar el envío de los datos, se creará un registro en Usuario-Grupo para el usuario, donde el atributo es_lider será FALSE.

### Información del usuario

Al hacer click sobre el div del header donde está el nombre del usuario, se entra en una pantalla de información del usuario.

En la parte superior central, el círculo con la inicial.

Debajo de eso, se muestran los datos del usuario, y una opción de cambiar el nombre de usuario y/o la contraseña, con las mismas validaciones qeu en el registro.

### Dashboard

En esta pantalla, si el usuario es líder del grupo en el que se encuentra, tendrá más permisos que si es un miembro normal.

En esta pantalla habrá varios cards que serán los distintos bloques de la app.
- Nueva quiniela
- Quinielas en cola
- Ver quiniela en curso
- Últimos resultados
- Estadísticas
- Configuración del grupo
- Chat del grupo

Si el usuario no es líder del grupo, los cards de "Nueva quiniela" y "Configuración del grupo" saldrán como apagados, y al hacer click sobre éstos se informará que solo el líder del grupo puede realizar esa operación.

Si no hay una quiniela con el estado "pendiente" en el grupo, al hacer click en el card "Quiniela activa" se lanzará el error correspondiente.

Si no hay una quiniela con el estado "en_curso" en el grupo, al hacer click en el card "Ver quiniela en curso" se lanzará el error correspondiente.

### Configuración del grupo

Pantalla similar a la de información del usuario, peor para la información del grupo. Sólo es visible por el líder del grupo.

En esta pantalla se pueden editar los datos del grupo: Nombre, contraseña, incluso cambiar el líder del grupo. En este caso, en cuanto el usuario salga de la pantalla, ya no podría volver a entrar en esta.

### Nueva quiniela

Se abre un formulario ocn los siguientes campos:

- Paso 1. Un listado con las jornadas de quiniela que no tengan una apuesta ya realizada por ese grupo (y cuya fecha_cierre sea futura a la fecha y hora actual), ya que un grupo no puede realizar 2 apuestas a una misma jornada.
- Paso 2. Qué usuario va a encargarse de la columna especial del Elige 8.

Tras completar todos estos pasos, se registra la apuesta con los datos introducidos.

En el momento que se crea la apuesta se le enviará una notificación a cada usuario invitado a la apuesta, para que rellene su 

### Quinielas en cola

Esta pantalla sirve para gestionar las apuestas creadas, que estén pendientes (aún no pagadas).

Al entrar en esta sección se muestra una lista con la cola de aquestas pendientes, ordenada por fecha límite de más próxima a más lejana.

Cuando le das a una apuesta en concreto, se abre una vista de la apuesta en forma de una tabla, donde hay una especie de cabecera en la que se ve:
- jornada.nombre temporada.nombre
Competiciones: x, y, z
- jornada.fecha_cierre (DD/MM/AAAA HH:mm)
- precio de la quiniela: apuesta.precio
- premios obtenidos: apuesta.beneficio
(para el precio y beneficio, si contienen NULL, se mostrará "-"
por el contrario, si contienen valor, se mostrará "x,xx €")
- El precio será 0,50 € la columna Elige 8 + 0,75 € x el nº de columnas normales.
- El beneficio será el número de columnas con 10 aciertos x el valor del premio de categoría "10 aciertos", y así sucesivamente para 11, 12, 13, 14, 15 aciertos. Además, se sumará el valor del premio "Elige 8" si la columna Elige8 no tiene pronósticoas fallados.

Debajo de la cabecera, empiezan a mostrarse la información de los partidos (1 en cada fila):

- "partido.orden"
- "partido.equipo_local (nombre)" - "partido.equipo_visitante (nombre)"

A la derecha de cada partido, se comienzan a mostrar las diferentes columnas.
- Para cada columna, se muestra una cabecera con el nombre del usuario propietario de la columna (salvo la columna del Elige 8 que contendrá el texto "Elige 8"). Debajo de esA cabecera, para lo 14 primeros partidos, a la altura de cada partido se mostrarán 3 labels con el siguiente texto respectivamente: 1, X, 2.
    - El usuario debe marcar exclusivamente 1 de ellos, por lo que si el usuario tiene marcado el 1 y pincha sobre el 2, el 1 se deseleccionará para marcar el 2.
    - El usuario encargado de rellenar la columna del elige 8 debe copiar 8 pronósticos entre los 14 pronósticos normales (1X2), por lo que no se permitirá introducir pronósticos distintos para el elige 8 y la columna del usuario (Ejemplo: Si el usuario en su columna tien marcado una X para un partido, en la columna Elige 8 ese partido solo puede llevar una X).
- La columna especial Elige 8 incluye los pronósticos del pleno al 15, por lo que en esa columna habrá, a la altura del partido 15, 2 filas distintas, de 4 labels cada una, con el siguiente texto respectivamente: 0, 1, 2, M. La primera fila es para el pronóstico de los goles del equipo local, y la segunda fila para el pronóstico de los goles del equipo visitante.

- El usuario podrá rellenar su columna mediante un botón "Rellenar mi columna". Este botón agrega una columna vacía con su nombre de usuario. 
    - Además, si se trata del usuario encargado de la columna especial "Elige 8", se le habilitará esta columna también.
- El administrador tiene también el poder de añadir la columna de otro usuario, mediante un botón de "Nueva columna". Al hacer click en este botón el funcionamiento será exactamente igual que si rellenara su columna, pero además deberá especificar el usuario propietario de esa columna para almacenar la misma.

- Cuando el usuario haya rellenado su columna, ya se mostrarán todas las columnas existentes para esa apuesta. Las columnas deben estar siempre ordenadas de la siguiente forma:
    - 1. Columna Elige 8
    - 2. Columna normal del usuario encargado de realizar la columna Elige 8
    - 3. Columnas normales del resto de usuarios, ordenadas por fecha y hora de creación.
- Además, se mostrará un botón para poder editar sus pronósticos, y poder sobreescribir los mismos.

- Cuando el líder desee, mediante un botón de "Cerrar quiniela" se cambiará el estado de esa apuesta a "cerrada". Desde ese momento, ya no se podrán realizar cambios en las columnas existentes, ni agregar nuevas columnas. Esta opción es irreversible, por lo que se enviará una alerta de confirmación.

### Ver quiniela en curso

Se trata de un seguimiento en directo de los resultados de la jornada que se está disputando. Se mostrará la misma vista en tabla que en la pantalla de las quinielas pendientes, pero con unas modificaciones:

- a la derecha del nombre de los equipos, se mostrarán, alineados verticalmente los marcadores de los partidos con el siguiente formato: "partido.goles_local" - "partido.goles_visitante"
- Además, sobre los pronósticos, se marcarán con fondo verde los pronósticos acertados y en rojo los pronósticos fallados.
    - Para evaluar un pronóstico, los atributos del partido goles_local y goles_visitante deben estar rellenos.
    - Un pronóstico se considera acertado si:
        - El pronóstico es 1 y goles_local>goles_visitante
        - El pronóstico es X y goles_local=goles_visitante
        - El pronóstico es 2 y goles_local<goles_visitante
    - En cualquier otro caso el pronóstico será fallado.
    - En el caso del partido 15, los pronósticos setán acertados si:
        - partido.goles_local<=2 y pronóstico.plenoal15_local=partido.goles_local
        - partido.goles_local>=3 y pronóstico.plenoal15_local="M"
        *Lo mismo para partido.goles_visitante y pronóstico.plenoal15_visitante

Además, debajo de la tabla de la apuesta, habrá un ranking con una clasificación de los usuarios en función de los aciertos de las columnas normales.
- En el ranking se mostrarán las filas de la siguiente forma:
    - La fila del elige8 se mostrará siempre al principio, y la fila estará coloreada de verde si en el momento de la consulta no hay pronósticos fallados (solo aciertos y partidos aún por resolver).
    - Las columnas normales se mostrarán ordenadas por número de aciertos de forma descendente, y cada fila estará coloreada de verde si la columna correspondiente contiene como máximo 4 pronósticos fallados en la columna. El resto deben ser pronósticos acertados o aún por resolver  

### Últimos resultados

Esta sección es más para consultar datos de apuestas finalizadas.

Al entrar en la sección se muestra una lista de apuestas como las de la sección de "Quinielas en cola", pero ordenadas de fecha más reciente a fecha más pasada.

Cuando haces click en una apuesta, se muestra una vista como la descrita para la sección "Ver quiniela en curso", con la tabla y el ranking de aciertos.

- Además, al estar finalizadas las jornadas, se mostrará una tabla de premios de la jornada, con la categoría y el valor.

### Estadísticas

Sección de estadísticas un poco más avanzadas del grupo.

Se puede acceder a un ranking de aciertos (solo de columnas normales, sin elige 8)

### Configuración del grupo

Pantalla accesible solo para el líder del grupo, prácticamente igual que la de información del usuario, pero para el grupo. En ella, se pueden editar los datos del grupo y ver el listado de usuarios del mismo. 

### Chat del grupo

Se trata de una especie de grupo de WhatsApp pero interno de la aplicación, para que se pueda mantener una buena comunicación entre los miembros del grupo en lo relativo a las quinielas. Cada mensaje del grupo implica la notificación correspondiente al resto de usuarios del grupo.

Importante que se refresque automáticamente cada muy poco tiempo para que el usuario no tenga que entrar y salir o refrescar manualmente para ver nuevos mensajes.