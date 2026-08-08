# Mejoras de la app
1. [Login](#login)
2. [Home](#home)
3. [Dashboard](#dashboard)
4. [Nueva quiniela](#nueva-quiniela)
5. [Quinielas en cola](#quinielas-en-cola)
6. [Ver quiniela en curso](#ver-quiniela-en-curso)
7. [Últimos resultados](#últimos-resultados)
8. [Estadísticas](#estadísticas)
9. [Configuración del grupo](#configuración-del-grupo)
10. [Chat del grupo](#chat-del-grupo)
11. [Administración del sistema](#administración-del-sistema)

---

## Panel admin

## Backend

- Añadir jornada.estado, obligatorio y de tipo enum, Podrá cobrar los valores de "Pendiente", "En curso" o "Finalizada".
- El enum apuesta.estado ahora contendrá los valores "Abierta" y "Cerrada". 
    - También se sustituirán en la lógica de la aplicación. El nuevo flujo será el siguiente.
        - Las apuestas se crean siempre en "abierta"
        - Cuando el líder hace click en "Cerrar apuesta" se cambia a "cerrada"
        - Cuando al menos un partido de esa jornada se cambia a un estado distinto de "pendiente" ya se considera que la jornada está "en_curso". Por lo tanto, en este momento, si alguna apuesta de esa jornada estaba "abierta" se cambia automáticamente a "cerrada".
        - Cuando todos los partidos de la quiniela tienen el estado "finalizado" se cambia a "finalizada".
        - Sólo se podrán asignar premios a una jornada si el estado de la jornada es "finalizada". Si no, al intentarlo se mostrará el error correspondiente.
    - En la pantalla de "Quinielas en cola" solo se mostrarán las apuestas de jornadas que estén "pendiente"
    - En la pantalla de "Ver quiniela en curso" sólo se mostrarán las apuestas de jornadas que estén "en_curso". 
    - En la pantalla de "Últimos resultados" solo se mostrarán las apuestas de jornadas que estén "finalizada"

- Los valores que se deben guardar en los pronósticos 1X2 (SignoEnum) en BD actualmente son: "UNO" "X" "DOS". Estos deben ser "1" "X" "2".
    - Lo mismo sucede con los pronósticos de pleno al 15 (GolesEnum). Actualmente son: "CERO" "UNO" "DOS" "M" . Estos deben ser "0" "1" "2" "M". 

- En la tabla "Temporadas" hay que añadir un estado, que podrá ser "actual" o "finalizada". Sólo se podrán editar datos relacionados con la temporada que esté "actual".
    - Esto quiere decir que no se podrán modificar las jornadas, ni sus apuestas, de temporadas "finalizadas".
    - Tampoco se podrán añadir ni eliminar competiciones a esa temporada, ni se podrán añadir ni eliminar equipos a competiciones de temporadas "finalizadas.
    - Ante todas estas acciones, se deberán mostrar sus errores correspondientes.

## Login

## Home

## Dashboard

## Nueva quiniela
- Cuando el líder del grupo va a realizar una columna que no es esuya, también podrá realizar la columna "elige 8".

## Quinielas en cola
- Solo se mostrarán las columnas a partir del momento en el que el usuario haya rellenado su columna.

- Cuando se esté rellenando una columna, solo se verá esa columna. Cuando se esté rellenando la columna "Elige 8" se mostrará la columna "Elige 8" y la columna del usuario responsable del "Elige 8"

## Ver quiniela en curso 


- En la clasificación de aciertos, la columna "Elige 8" solo se contarán los 8 pronósticos 1X2. Sin embargo, el resto de columnas sí que tendrán los 14 pronósticos 1X2 y además el pleno al 15. Así se podrá llegar a los 15 aciertos.
- En las secciones de "Nueva quiniela", "Quinielas en cola","Ver quiniela en curso","Últimos resultados",  cuando accedes a una jornada, debajo del nombre de la jornada y encima de la fecha de cierre, se mostrarán las competiciones que incluye esa jornada, separadas por " · ".


## Últimos resultados

## Estadísticas

## Configuración del grupo

## Chat del grupo

## Administración del sistema