import os
from dotenv import load_dotenv
import secrets

# Load environment variables from a .env file if available
load_dotenv()

# Database configuration
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:wipDr^Isemi917@localhost:1520/ai_resume_db")

# JWT configuration
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", 'a5282bbcfd35a93fe40825f82f4c6db1ea02644d7cf9943b05dbc9b698b633be')
JWT_ALGORITHM = "HS256"


# Stripe configuration
STRIPE_SECRET = os.getenv("STRIPE_SECRET", "your_stripe_secret_key")

EMAIL_SENDER = os.getenv("EMAIL_SENDER", "airesumecreator@gmail.com")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD", "omwy tblk xshq qjvb")
