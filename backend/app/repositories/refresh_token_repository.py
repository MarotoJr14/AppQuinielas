from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.refresh_token import RefreshToken
from app.repositories.base import BaseRepository


class RefreshTokenRepository(BaseRepository[RefreshToken]):
    def __init__(self):
        super().__init__(RefreshToken)

    def get_by_jti(self, db: Session, jti: str) -> RefreshToken | None:
        stmt = select(RefreshToken).where(RefreshToken.jti == jti)
        return db.scalar(stmt)

    def revoke_for_user(self, db: Session, user_id: int, revoked_at: datetime | None = None) -> None:
        now = revoked_at or datetime.now(timezone.utc)
        stmt = select(RefreshToken).where(
            RefreshToken.user_id == user_id,
            RefreshToken.revoked_at.is_(None),
        )
        for refresh_token in db.scalars(stmt):
            refresh_token.revoked_at = now

    def revoke(self, db: Session, refresh_token: RefreshToken, revoked_at: datetime | None = None) -> None:
        refresh_token.revoked_at = revoked_at or datetime.now(timezone.utc)
        db.add(refresh_token)


refresh_token_repository = RefreshTokenRepository()
