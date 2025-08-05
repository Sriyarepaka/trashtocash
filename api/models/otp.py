from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.sql import func
from datetime import datetime, timedelta
from api.db.session import Base

class UserOtp(Base):
    __tablename__ = "users_otp_store"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    otp = Column(String(10), nullable=False)
    generated_time = Column(DateTime, default=func.now())
    expiry_time = Column(DateTime, default=lambda: datetime.now() + timedelta(minutes=15))
    validated = Column(Boolean, default=False)