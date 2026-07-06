from fastapi import HTTPException, status

ADMIN_USUARIO_ID = 1  # El usuario con id=1 es el administrador del sistema (gestiona jornadas, partidos, premios...).


def comprobar_admin(usuario_id: int) -> None:
    if usuario_id != ADMIN_USUARIO_ID:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo el administrador del sistema puede realizar esta operación.",
        )
