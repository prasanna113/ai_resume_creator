import jwt
from datetime import datetime, timedelta, UTC
from fastapi import HTTPException, Security, Depends
from fastapi.security import OAuth2PasswordBearer
from config import JWT_SECRET_KEY, JWT_ALGORITHM
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/user/token")

def create_jwt_token(data: dict, expires_delta: timedelta = None):
    """Generate a JWT token with an optional expiration time."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(UTC) + expires_delta
    else:
        expire = datetime.now(UTC) + timedelta(hours=24)  # Default expiration: 24 hours
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def verify_jwt_token(token: str = Security(oauth2_scheme)):
    """Verify and decode a JWT token."""
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return payload
    except ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

def get_current_user(token_data: dict = Depends(verify_jwt_token)):
    """Extract user information from the verified JWT token."""
    return token_data  # Return the decoded token data containing user details
