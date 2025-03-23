from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from config import DATABASE_URL
import os

# ✅ Create an async engine
engine = create_async_engine(DATABASE_URL, echo=True)

# ✅ Create an async session factory
AsyncSessionLocal = sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)

# ✅ Declare Base for models
Base = declarative_base()

# ✅ Dependency for async DB session
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session