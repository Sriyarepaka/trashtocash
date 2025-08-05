from pydantic import BaseModel
from datetime import datetime

class UserSchema(BaseModel):
    id: int
    name: str
    email_id: str
    phone_number: str = None
    role_id: int
    created_at: datetime

    class Config:
        orm_mode = True