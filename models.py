from sqlalchemy import Column, String, Boolean, Integer, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.ext.asyncio import AsyncAttrs
from database import Base


class User(AsyncAttrs, Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
    subscription_active = Column(Boolean, default=False)
    is_active = Column(Boolean, default=False)  # ✅ Tracks whether the user has activated their account
    activation_code = Column(String, nullable=True)

class Resume(AsyncAttrs, Base):
    __tablename__ = "resumes"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    full_name = Column(String, nullable=False)
    experience = Column(String, nullable=False)
    skills = Column(String, nullable=False)
    job_title = Column(String, nullable=False)
    job_description = Column(String, nullable=False)

    user = relationship("User", back_populates="resumes")

class CoverLetter(AsyncAttrs, Base):
    __tablename__ = "cover_letters"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    full_name = Column(String, nullable=False)
    experience = Column(String, nullable=False)
    job_title = Column(String, nullable=False)
    job_description = Column(String, nullable=False)

    user = relationship("User", back_populates="cover_letters")

# Establish relationships in User model
User.resumes = relationship("Resume", back_populates="user", cascade="all, delete-orphan")
User.cover_letters = relationship("CoverLetter", back_populates="user", cascade="all, delete-orphan")
