from sqlalchemy import Column, Integer, String
from api.db.session import Base

class Role(Base):
    __tablename__ = "roles"
    id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String(50), unique=True, nullable=False)
    # ...existing columns if any...
# select id, role_name from roles;