import os
from dotenv import load_dotenv

# Load environment variables from a .env file if available
load_dotenv()

# DB Password
POSTGRE_PASSWORD = os.getenv("POSTGRE_PASSWORD")

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", f"postgresql://postgres:{POSTGRE_PASSWORD}@localhost:1520/ai_resume_db")

# JWT configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", 'a5282bbcfd35a93fe40825f82f4c6db1ea02644d7cf9943b05dbc9b698b633be')
JWT_ALGORITHM = "HS256"

# OpenAI API configuration
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Stripe configuration
STRIPE_SECRET = os.getenv("STRIPE_SECRET", "your_stripe_secret_key")

EMAIL_SENDER = os.getenv("EMAIL_SENDER", "airesumecreator@gmail.com")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")
