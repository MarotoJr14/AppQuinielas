from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.grupo import Grupo
from app.models.usuario_grupo import UsuarioGrupo
from app.repositories.grupo_repository import grupo_repository
from app.repositories.usuario_grupo_repository import usuario_grupo_repository
from app.schemas.grupo import GrupoCreate, GrupoJoin, GrupoUpdate

ADMIN_USUARIO_ID = 1  # El usuario con id=1 es el administrador del sistema.


class GrupoService:
    def crear(self, db: Session, usuario_id: int, datos: GrupoCreate) -> Grupo:
        if grupo_repository.get_by_nombre(db, datos.nombre):
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un grupo con ese nombre.")
        grupo = Grupo(nombre=datos.nombre, password_hash=hash_password(datos.password))
        db.add(grupo)
        db.flush()
        relacion = UsuarioGrupo(grupo_id=grupo.id, usuario_id=usuario_id, es_lider=True)
        db.add(relacion)
        db.commit()
        db.refresh(grupo)
        return grupo

    def unirse(self, db: Session, usuario_id: int, datos: GrupoJoin) -> UsuarioGrupo:
        grupo = grupo_repository.get_by_nombre(db, datos.nombre)
        if grupo is None or not verify_password(datos.password, grupo.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Nombre de grupo o contraseña incorrectos."
            )
        existente = usuario_grupo_repository.get_by_grupo_usuario(db, grupo.id, usuario_id)
        if existente is not None:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya perteneces a este grupo.")
        relacion = UsuarioGrupo(grupo_id=grupo.id, usuario_id=usuario_id, es_lider=False)
        db.add(relacion)
        db.commit()
        db.refresh(relacion)
        return relacion

    def listar_de_usuario(self, db: Session, usuario_id: int, search: str | None = None) -> list[Grupo]:
        return grupo_repository.list_por_usuario(db, usuario_id, search)

    def obtener(self, db: Session, grupo_id: int) -> Grupo:
        return grupo_repository.get_or_404(db, grupo_id)

    def es_lider(self, db: Session, grupo_id: int, usuario_id: int) -> bool:
        relacion = usuario_grupo_repository.get_by_grupo_usuario(db, grupo_id, usuario_id)
        return relacion is not None and relacion.es_lider

    def comprobar_pertenece(self, db: Session, grupo_id: int, usuario_id: int) -> UsuarioGrupo:
        relacion = usuario_grupo_repository.get_by_grupo_usuario(db, grupo_id, usuario_id)
        if relacion is None:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No perteneces a este grupo.")
        return relacion

    def comprobar_lider(self, db: Session, grupo_id: int, usuario_id: int) -> None:
        relacion = self.comprobar_pertenece(db, grupo_id, usuario_id)
        if not relacion.es_lider:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Solo el líder del grupo puede realizar esta operación.",
            )

    def actualizar(self, db: Session, grupo_id: int, usuario_id: int, datos: GrupoUpdate) -> Grupo:
        self.comprobar_lider(db, grupo_id, usuario_id)
        grupo = grupo_repository.get_or_404(db, grupo_id)
        if datos.nombre and datos.nombre != grupo.nombre:
            if grupo_repository.get_by_nombre(db, datos.nombre):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT, detail="Ya existe un grupo con ese nombre."
                )
            grupo.nombre = datos.nombre
        if datos.password:
            grupo.password_hash = hash_password(datos.password)
        db.add(grupo)
        db.commit()
        db.refresh(grupo)
        return grupo

    def cambiar_lider(self, db: Session, grupo_id: int, usuario_id: int, nuevo_lider_id: int) -> None:
        self.comprobar_lider(db, grupo_id, usuario_id)
        actual = usuario_grupo_repository.get_lider(db, grupo_id)
        nuevo = usuario_grupo_repository.get_by_grupo_usuario(db, grupo_id, nuevo_lider_id)
        if nuevo is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="El nuevo líder no pertenece a este grupo."
            )
        if actual is not None:
            actual.es_lider = False
            db.add(actual)
            db.flush()
        nuevo.es_lider = True
        db.add(nuevo)
        db.commit()

    def listar_miembros(self, db: Session, grupo_id: int) -> list[UsuarioGrupo]:
        return usuario_grupo_repository.list_por_grupo(db, grupo_id)


grupo_service = GrupoService()
