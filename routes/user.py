from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from auth import create_jwt_token
from database import get_db
from models import User
from pydantic import BaseModel
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm
import random
import smtplib
import asyncio
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
async def register(user: UserCreate, db: AsyncSession = Depends(get_db)):
    """Register a new user with hashed password storage and send an activation code."""
    result = await db.execute(select(User).filter(User.email == user.email))
    existing_user = result.scalars().first()

    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")

    hashed_password = hash_password(user.password)
    activation_code = str(random.randint(100000, 999999))  # Generate 6-digit code

    new_user = User(email=user.email, password=hashed_password, activation_code=activation_code)
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    asyncio.create_task(send_activation_email(user.email, activation_code))  # Send activation email asynchronously

    return {"message": "User registered successfully. Check your email for activation code."}

async def send_activation_email(email: str, code: str):
    """Sends an activation email asynchronously."""
    sender_email = EMAIL_SENDER
    sender_password = EMAIL_PASSWORD

    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, sync_send_email, sender_email, sender_password, email, code)

def sync_send_email(sender_email: str, sender_password: str, recipient_email: str, code: str):
    """Blocking email sending function to run in background."""
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender_email, sender_password)
        message = f"Subject: Activate Your Account\n\nYour activation code is: {code}"
        server.sendmail(sender_email, recipient_email, message)

@router.post("/activate")
async def activate_user(request: ActivationRequest, db: AsyncSession = Depends(get_db)):
    """Validates activation code and activates the user."""
    result = await db.execute(select(User).filter(User.email == request.email, User.activation_code == request.code))
    user = result.scalars().first()

    if not user:
        raise HTTPException(status_code=400, detail="Invalid activation code")

    user.is_active = True
    user.activation_code = None  # Clear activation code
    await db.commit()

    return {"message": "Email successfully validated. You can now log in."}

@router.post("/login")
async def login(user: UserCreate, db: AsyncSession = Depends(get_db)):
    """Authenticate user and return JWT token."""
    result = await db.execute(select(User).filter(User.email == user.email))
    stored_user = result.scalars().first()

    if not stored_user or not verify_password(user.password, stored_user.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_jwt_token({"id": stored_user.id, "email": stored_user.email})
    return {"access_token": token}

@router.post("/token")
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: AsyncSession = Depends(get_db)):
    """OAuth2-compatible login endpoint that returns an access token"""
    result = await db.execute(select(User).filter(User.email == form_data.username))
    user = result.scalars().first()

    if not user or not verify_password(form_data.password, user.password):
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    token = create_jwt_token({"id": user.id, "email": user.email})
    return {"access_token": token, "token_type": "bearer"}

@router.get("/exists")
async def check_user_exists(email: str = Query(...), db: AsyncSession = Depends(get_db)):
    """Check if a user exists by email."""
    result = await db.execute(select(User).filter(User.email == email))
    user = result.scalars().first()
    return {"exists": bool(user)}
