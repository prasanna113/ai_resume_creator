from fastapi import FastAPI, Depends
from routes.user import router as user_router
from routes.resume import router as resume_router
from routes.cover_letter import router as cover_letter_router
import uvicorn

app = FastAPI(debug=True)

@app.get("/")
async def root():
    return {"message": "Welcome to the AI Resume Generator API!"}

# Include API route modules
app.include_router(user_router, prefix="/user", tags=["User"])
app.include_router(resume_router, prefix="/resume", tags=["Resume"])
app.include_router(cover_letter_router, prefix="/cover_letter", tags=["Cover Letter"])

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True, log_level="debug")