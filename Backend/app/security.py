
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext
from pydantic_settings import BaseSettings, SettingsConfigDict
from .schemas import TokenData
import secrets

pwd_context = CryptContext(schemes=["sha512_crypt"], deprecated="auto")

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    SECRET_KEY: str = "change_me"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 14
    PASSWORD_RESET_TOKEN_EXPIRE_MINUTES: int = 15

settings = Settings()

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def _jwt_encode(payload: dict) -> str:
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def _jwt_decode(token: str) -> dict | None:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        return None

def create_access_token(subject: str, minutes: int | None = None) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=minutes or settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return _jwt_encode({"sub": subject, "type": "access", "exp": expire})

def create_password_reset_token(subject: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.PASSWORD_RESET_TOKEN_EXPIRE_MINUTES)
    return _jwt_encode({"sub": subject, "type": "pwd_reset", "exp": expire})

def decode_token_expected(token: str, expected_type: str) -> TokenData | None:
    payload = _jwt_decode(token)
    if not payload or payload.get("type") != expected_type:
        return None
    return TokenData(sub=payload.get("sub"), type=payload.get("type"))

def generate_refresh_token() -> str:
    return secrets.token_urlsafe(48)
