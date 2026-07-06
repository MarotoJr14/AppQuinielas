from pydantic import BaseModel, EmailStr, Field, field_validator

from app.schemas.common import TimestampedSchema


class UsuarioBase(BaseModel):
    nombre_usuario: str = Field(min_length=3, max_length=50)
    email: EmailStr

    @field_validator("nombre_usuario")
    @classmethod
    def nombre_usuario_minusculas_alfanumerico(cls, v: str) -> str:
        if not v.isalnum() or not v.islower():
            raise ValueError(
                "El nombre de usuario solo puede contener letras minúsculas y números."
            )
        return v

    @field_validator("email")
    @classmethod
    def email_minusculas(cls, v: str) -> str:
        if v != v.lower():
            raise ValueError("El correo electrónico no puede contener letras mayúsculas.")
        return v


class UsuarioCreate(UsuarioBase):
    password: str = Field(min_length=8)

    @field_validator("password")
    @classmethod
    def password_segura(cls, v: str) -> str:
        if not any(c.isupper() for c in v) or not any(c.islower() for c in v):
            raise ValueError(
                "La contraseña debe contener al menos 8 caracteres, "
                "con al menos 1 mayúscula y 1 minúscula."
            )
        return v


class UsuarioUpdate(BaseModel):
    nombre_usuario: str | None = Field(default=None, min_length=3, max_length=50)
    password: str | None = Field(default=None, min_length=8)


class UsuarioRead(TimestampedSchema):
    nombre_usuario: str
    email: EmailStr


class UsuarioResetPassword(BaseModel):
    email: EmailStr
    nueva_password: str = Field(min_length=8)
