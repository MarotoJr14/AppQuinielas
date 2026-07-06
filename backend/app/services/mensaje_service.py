from sqlalchemy.orm import Session

from app.models.mensaje import Mensaje
from app.repositories.mensaje_repository import mensaje_repository
from app.schemas.mensaje import MensajeCreate
from app.services.grupo_service import grupo_service


class MensajeService:
    def enviar(self, db: Session, usuario_id: int, datos: MensajeCreate) -> Mensaje:
        grupo_service.comprobar_pertenece(db, datos.grupo_id, usuario_id)
        mensaje = Mensaje(grupo_id=datos.grupo_id, usuario_id=usuario_id, contenido=datos.contenido)
        db.add(mensaje)
        db.commit()
        db.refresh(mensaje)
        return mensaje

    def listar_por_grupo(self, db: Session, usuario_id: int, grupo_id: int, skip: int = 0, limit: int = 50) -> list[Mensaje]:
        grupo_service.comprobar_pertenece(db, grupo_id, usuario_id)
        mensajes = mensaje_repository.list_por_grupo(db, grupo_id, skip, limit)
        return list(reversed(mensajes))


mensaje_service = MensajeService()
