from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from auth import create_jwt_token
from database import get_db
from models import User
from pydantic import BaseModel
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm
import random
import smtplib
from config import EMAIL_SENDER, EMAIL_PASSWORD

router = APIRouter()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserCreate(BaseModel):
    email: str
    password: str

class ActivationRequest(BaseModel):
    email: str
    code: str

def hash_password(password: str) -> str:
    """Hash a password using bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plaintext password against the hashed version."""
    return pwd_context.verify(plain_password, hashed_password)


@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user with hashed password storage and send an activation code."""
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = hash_password(user.password)
    activation_code = str(random.randint(100000, 999999))  # Generate 6-digit code

    new_user = User(email=user.email, password=hashed_password, activation_code=activation_code)
    db.add(new_user)
    db.commit()

    send_activation_email(user.email, activation_code)  # Send activation email

    return {"message": "User registered successfully. Check your email for activation code."}


def send_activation_email(email: str, code: str):
    """Sends an activation email with the code."""
    sender_email = EMAIL_SENDER
    sender_password = EMAIL_PASSWORD

    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender_email, sender_password)
        message = f"Subject: Activate Your Account\n\nYour activation code is: {code}"
        server.sendmail(sender_email, email, message)


@router.post("/activate")
def activate_user(request: ActivationRequest, db: Session = Depends(get_db)):
    """Validates activation code and activates the user."""
    user = db.query(User).filter(User.email == request.email, User.activation_code == request.code).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid activation code")

    user.is_active = True
    user.activation_code = None  # Clear activation code
    db.commit()

    return {"message": "Email successfully validated. You can now log in."}

@router.post("/login")
def login(user: UserCreate, db: Session = Depends(get_db)):
    """Authenticate user and return JWT token."""
    stored_user = db.query(User).filter(User.email == user.email).first()
    if not stored_user or not verify_password(user.password, stored_user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_jwt_token({"id": stored_user.id, "email": stored_user.email})
    return {"access_token": token}

@router.post("/token")
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    """OAuth2-compatible login endpoint that returns an access token"""
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    token = create_jwt_token({"id": user.id, "email": user.email})
    return {"access_token": token, "token_type": "bearer"}
