from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    ENVIRONMENT: str = "development"

    POSTGRES_USER: str = "quinielas"
    POSTGRES_PASSWORD: str = "quinielas"
    POSTGRES_DB: str = "quinielas"
    POSTGRES_HOST: str = "db"
    POSTGRES_PORT: int = 5432

    DATABASE_URL: str | None = None

    SECRET_KEY: str = "change-this-secret-key-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7

    API_V1_PREFIX: str = "/api/v1"
    PROJECT_NAME: str = "Quinielas API"

    @property
    def SQLALCHEMY_DATABASE_URL(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    @property
    def SYNC_DATABASE_URL(self) -> str:
        return self.SQLALCHEMY_DATABASE_URL
    
    @property
    def PSYCOPG_DATABASE_URL(self) -> str:
        return self.SQLALCHEMY_DATABASE_URL.replace("+psycopg", "")


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
