from sqlalchemy import Column, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func
from api.db.session import Base

class UserSessionAudit(Base):
    __tablename__ = "user_session_audit"
    
    id = Column(Integer, ForeignKey("users.id"), nullable=False, primary_key=True)
    login_time = Column(DateTime, default=func.now(), primary_key=True)
    logout_time = Column(DateTime, nullable=True)