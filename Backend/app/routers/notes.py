from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Note, User
from ..schemas import NoteCreate, NoteUpdate, NotePublic
from ..deps import get_current_user

router = APIRouter(prefix="/notes", tags=["notes"])

@router.get("/", response_model=List[NotePublic])
def list_notes(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = Query(default=50, le=100)
):
    q = db.query(Note).filter(Note.idUser == current_user.idUser).offset(skip).limit(limit)
    return q.all()

@router.post("/", response_model=NotePublic, status_code=201)
def create_note(note_in: NoteCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = Note(
        idUser=current_user.idUser,
        name=note_in.name,
        text=note_in.text
    )
    db.add(note)
    current_user.notesCount += 1
    db.add(current_user)
    db.commit()
    db.refresh(note)
    return note

@router.get("/{idNote}", response_model=NotePublic)
def get_note(idNote: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = db.query(Note).filter(Note.idNote == idNote, Note.idUser == current_user.idUser).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    return note

@router.put("/{idNote}", response_model=NotePublic)
def update_note(idNote: int, note_in: NoteUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = db.query(Note).filter(Note.idNote == idNote, Note.idUser == current_user.idUser).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    if note_in.name is not None:
        note.name = note_in.name
    if note_in.text is not None:
        note.text = note_in.text
    db.add(note)
    db.commit()
    db.refresh(note)
    return note

@router.delete("/{idNote}", status_code=204)
def delete_note(idNote: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    note = db.query(Note).filter(Note.idNote == idNote, Note.idUser == current_user.idUser).first()
    if not note:
        raise HTTPException(status_code=404, detail="Note not found")
    db.delete(note)
    current_user.notesCount = max(0, current_user.notesCount - 1)
    db.add(current_user)
    db.commit()
    return
