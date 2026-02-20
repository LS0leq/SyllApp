
from pydantic import BaseModel, Field
from typing import Optional

# ---------- Users ----------
class UserBase(BaseModel):
    name: str = Field(min_length=3, max_length=150)

class UserCreate(UserBase):
    password: str = Field(min_length=6, max_length=128)

class UserPublic(UserBase):
    idUser: int
    notesCount: int

    class Config:
        from_attributes = True

# ---------- Auth ----------
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenPair(Token):
    refresh_token: str

class TokenData(BaseModel):
    sub: Optional[str] = None  # username
    type: Optional[str] = None

class RefreshRequest(BaseModel):
    refresh_token: str

class LogoutRequest(BaseModel):
    refresh_token: str

class PasswordResetRequest(BaseModel):
    name: str

class PasswordResetConfirm(BaseModel):
    reset_token: str
    new_password: str = Field(min_length=6, max_length=128)

# ---------- Notes ----------
class NoteBase(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    text: str

class NoteCreate(NoteBase):
    pass

class NoteUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=200)
    text: Optional[str] = None

class NotePublic(NoteBase):
    idNote: int
    idUser: int

    class Config:
        from_attributes = True
