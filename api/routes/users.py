from fastapi import APIRouter, Depends, HTTPException, status, Query, Body
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List
from pydantic import BaseModel
import bcrypt
import random
import string
from datetime import datetime

from api.db.session import get_db
from api.models.user import User
from api.models.role import Role  # assuming Role model exists in models/role.py
from api.models.otp import UserOtp  # Add this import
from api.models.session import UserSessionAudit
from api.schemas.user import UserSchema

router = APIRouter()

# New request schemas
class RegistrationData(BaseModel):
    name: str
    email: str
    password: str
    phone_number: str | None = None
    role: str  # expected 'seller' or 'buyer'

class OTPValidation(BaseModel):
    email: str
    otp: str

class LoginData(BaseModel):
    email: str
    password: str

@router.get("/users", response_model=List[UserSchema], status_code=status.HTTP_200_OK)
def get_users(role: str = Query("all", description="Role filter: seller, buyer, or all"), db: Session = Depends(get_db)):
    """
    Fetch users filtered by role.
    - If role is 'seller', returns users with role 'Seller'.
    - If role is 'buyer', returns users with role 'Buyer'.
    - If role is 'all', returns all users.
    """
    query = db.query(User)
    role_filter = role.lower()
    if role_filter in ["seller", "buyer"]:
        # join Role table to filter by role_name (case-insensitive)
        # query = "select * from users u join roles r on u.role_id = r.id where r.role_name = :role_name"
        query = query.join(Role).filter(Role.role_name.ilike(role_filter))
    elif role_filter != "all":
        raise HTTPException(status_code=400, detail="Invalid role filter value. Use 'seller', 'buyer', or 'all'.")
    
    users = query.all()
    if not users:
        raise HTTPException(status_code=404, detail="No users found for the given filter.")
    return users

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_user(reg_data: RegistrationData, db: Session = Depends(get_db)):
    # Check if user already exists
    existing = db.query(User).filter(User.email_id == reg_data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")
    
    # Hash the password
    hashed_pw = bcrypt.hashpw(reg_data.password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Retrieve role from DB
    role_obj = db.query(Role).filter(Role.role_name.ilike(reg_data.role)).first()
    if not role_obj:
        raise HTTPException(status_code=400, detail="Invalid role provided")
    
    # Create new user
    new_user = User(
        name=reg_data.name,
        email_id=reg_data.email,
        phone_number=reg_data.phone_number,
        password=hashed_pw,
        role_id=role_obj.id
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Generate a 6-digit OTP
    otp = ''.join(random.choices(string.digits, k=6))
    
    # Store OTP in database
    new_otp = UserOtp(
        user_id=new_user.id,
        otp=otp
    )
    db.add(new_otp)
    db.commit()
    
    # In a real application, send OTP via email here
    
    return {"message": "User registered successfully. OTP sent to email.", "user_id": new_user.id}

@router.post("/validate-otp", status_code=status.HTTP_200_OK)
def validate_otp(otp_data: OTPValidation, db: Session = Depends(get_db)):
    # Find user by email
    user = db.query(User).filter(User.email_id == otp_data.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Find the most recent non-validated OTP for this user
    otp_record = db.query(UserOtp).filter(
        UserOtp.user_id == user.id,
        UserOtp.validated == False,
        UserOtp.expiry_time > datetime.now()
    ).order_by(UserOtp.generated_time.desc()).first()
    
    if not otp_record:
        raise HTTPException(status_code=400, detail="OTP expired or not found")
    
    if otp_record.otp != otp_data.otp:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    
    # Mark OTP as validated
    otp_record.validated = True
    db.commit()
    
    return {"message": "OTP validated successfully."}

@router.post("/login", status_code=status.HTTP_200_OK)
def login_user(login_data: LoginData, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email_id == login_data.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    if not bcrypt.checkpw(login_data.password.encode('utf-8'), user.password.encode('utf-8')):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create session audit entry for login
    session_audit = UserSessionAudit(
        id=user.id
        # login_time defaults to current timestamp
        # logout_time is NULL until logout
    )
    db.add(session_audit)
    db.commit()
    
    # Generate a dummy JWT token (replace with actual JWT generation in production)
    token = "dummy_jwt_token"
    return {"token": token, "user_id": user.id, "name": user.name, "role_id": user.role_id}

# We should also add a logout endpoint
@router.post("/logout", status_code=status.HTTP_200_OK)
def logout_user(user_id: int = Body(...), db: Session = Depends(get_db)):
    # Find the most recent active session for this user
    active_session = db.query(UserSessionAudit).filter(
        UserSessionAudit.id == user_id,
        UserSessionAudit.logout_time == None
    ).order_by(UserSessionAudit.login_time.desc()).first()
    
    if not active_session:
        raise HTTPException(status_code=404, detail="No active session found for this user")
    
    # Update logout time
    active_session.logout_time = func.now()
    db.commit()
    
    return {"message": "Logged out successfully"}