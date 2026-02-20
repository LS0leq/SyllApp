
from sqlalchemy import Column, Integer, String, ForeignKey, Text, Boolean, DateTime, func
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "Users"
    idUser = Column(Integer, primary_key=True, index=True)
    name = Column(String(150), unique=True, index=True, nullable=False)
    password = Column(String(255), nullable=False)  # hashed
    notesCount = Column(Integer, nullable=False, default=0)

    notes = relationship("Note", back_populates="user", cascade="all, delete-orphan")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")

class Note(Base):
    __tablename__ = "Notes"
    idNote = Column(Integer, primary_key=True, index=True)
    idUser = Column(Integer, ForeignKey("Users.idUser", ondelete="CASCADE"), nullable=False)
    name = Column(String(200), nullable=False)
    text = Column(Text, nullable=False)

    user = relationship("User", back_populates="notes")

class RefreshToken(Base):
    __tablename__ = "RefreshTokens"
    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(255), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("Users.idUser", ondelete="CASCADE"), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    revoked = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    replaced_by_token = Column(String(255), nullable=True)

    user = relationship("User", back_populates="refresh_tokens")
