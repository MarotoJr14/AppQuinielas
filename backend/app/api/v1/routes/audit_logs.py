from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_user_id
from app.db.deps import get_db
from app.schemas.audit_log import AuditLogRead
from app.services.audit_log_service import audit_log_service
from app.utils.permissions import comprobar_admin

router = APIRouter(prefix="/audit-logs", tags=["Auditoría"])


@router.get("", response_model=list[AuditLogRead])
def listar_audit_logs(
    skip: int = 0, limit: int = 100, usuario_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)
):
    comprobar_admin(usuario_id)
    return audit_log_service.listar(db, skip, limit)
