from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog
from app.models.enums import OperacionEnum, TablaEnum
from app.repositories.audit_log_repository import audit_log_repository


class AuditLogService:
    def registrar(
        self, db: Session, usuario_id: int, operacion: OperacionEnum, tabla: TablaEnum, observaciones: str | None = None
    ) -> AuditLog:
        return audit_log_repository.create(
            db,
            {
                "usuario_id": usuario_id,
                "operacion": operacion,
                "tabla": tabla,
                "observaciones": observaciones,
            },
        )

    def listar(self, db: Session, skip: int = 0, limit: int = 100) -> list[AuditLog]:
        return audit_log_repository.list(db, skip, limit)


audit_log_service = AuditLogService()
