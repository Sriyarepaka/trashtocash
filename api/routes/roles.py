from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from api.db.session import get_db
from api.models.role import Role
from api.schemas.role import RoleSchema

router = APIRouter()

@router.get("/roles", response_model=List[RoleSchema], status_code=status.HTTP_200_OK)
def get_roles(db: Session = Depends(get_db)):
    """
    Fetch the list of roles.
    """
    roles = db.query(Role).all()
    if not roles:
        raise HTTPException(status_code=404, detail="No roles found")
    return roles