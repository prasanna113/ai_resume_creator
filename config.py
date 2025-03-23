import os
from dotenv import load_dotenv

# Load environment variables from a .env file if available
load_dotenv()

# DB Password
POSTGRE_PASSWORD = os.getenv("POSTGRE_PASSWORD")

# Database configuration
DATABASE_URL_SYNC = os.getenv("DATABASE_URL", f"postgresql://postgres:{POSTGRE_PASSWORD}@localhost:1520/ai_resume_db")

# Async database url
DATABASE_URL = os.getenv("DATABASE_URL", f"postgresql+asyncpg://postgres:{POSTGRE_PASSWORD}@localhost:1520/ai_resume_db")

# JWT configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")
JWT_ALGORITHM = "HS256"

# OpenAI API configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Stripe configuration
STRIPE_SECRET = os.getenv("STRIPE_SECRET", "your_stripe_secret_key")

EMAIL_SENDER = os.getenv("EMAIL_SENDER", "airesumecreator@gmail.com")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")
