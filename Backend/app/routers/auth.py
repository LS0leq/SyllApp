
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from ..database import get_db
from ..models import User, RefreshToken
from ..schemas import (
    UserCreate, UserPublic, TokenPair, RefreshRequest, LogoutRequest,
    PasswordResetRequest, PasswordResetConfirm
)
from ..security import (
    hash_password, verify_password, create_access_token,
    generate_refresh_token, create_password_reset_token,
    decode_token_expected, settings
)
from ..deps import get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=UserPublic, status_code=201)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.name == user_in.name).first()
    if existing:
        raise HTTPException(status_code=409, detail="Username already exists")
    user = User(
        name=user_in.name,
        password=hash_password(user_in.password),
        notesCount=0
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/login", response_model=TokenPair)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.name == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")

    access = create_access_token(subject=user.name)
    refresh = generate_refresh_token()
    expires_at = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    db.add(RefreshToken(token=refresh, user_id=user.idUser, expires_at=expires_at))
    db.commit()

    return TokenPair(access_token=access, refresh_token=refresh)

@router.post("/refresh", response_model=TokenPair)
def refresh_token(payload: RefreshRequest, db: Session = Depends(get_db)):
    rt = db.query(RefreshToken).filter(RefreshToken.token == payload.refresh_token).first()
    if not rt or rt.revoked or rt.expires_at <= datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired refresh token")

    user = db.query(User).filter(User.idUser == rt.user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")

    new_refresh = generate_refresh_token()
    new_expires = datetime.now(timezone.utc) + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)

    rt.revoked = True
    rt.replaced_by_token = new_refresh
    db.add(rt)

    db.add(RefreshToken(token=new_refresh, user_id=user.idUser, expires_at=new_expires))

    access = create_access_token(subject=user.name)
    db.commit()

    return TokenPair(access_token=access, refresh_token=new_refresh)

@router.post("/logout", status_code=204)
def logout(payload: LogoutRequest, db: Session = Depends(get_db)):
    rt = db.query(RefreshToken).filter(RefreshToken.token == payload.refresh_token).first()
    if rt and not rt.revoked:
        rt.revoked = True
        db.add(rt)
        db.commit()
    return

@router.post("/logout-all", status_code=204)
def logout_all(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.query(RefreshToken).filter(RefreshToken.user_id == current_user.idUser, RefreshToken.revoked == False).update({RefreshToken.revoked: True})
    db.commit()
    return

@router.post("/request-password-reset")
def request_password_reset(payload: PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.name == payload.name).first()
    reset_token = None
    if user:
        reset_token = create_password_reset_token(subject=user.name)
    return {"reset_token": reset_token}

@router.post("/reset-password")
def reset_password(payload: PasswordResetConfirm, db: Session = Depends(get_db)):
    token_data = decode_token_expected(payload.reset_token, expected_type="pwd_reset")
    if not token_data or not token_data.sub:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")

    user = db.query(User).filter(User.name == token_data.sub).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = hash_password(payload.new_password)
    db.add(user)

    db.query(RefreshToken).filter(RefreshToken.user_id == user.idUser, RefreshToken.revoked == False).update({RefreshToken.revoked: True})

    db.commit()
    return {"status": "password_updated"}
