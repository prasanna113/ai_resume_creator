from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from openai import OpenAI
from auth import get_current_user
from database import get_db
from models import Resume
from config import OPENAI_API_KEY

router = APIRouter()

@router.post("/")
def generate_resume(
    full_name: str,
    experience: str,
    skills: str,
    job_title: str,
    job_description: str,
    db: Session = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    """Generates a resume using OpenAI API based on user input."""

    client = OpenAI(
        api_key=OPENAI_API_KEY
    )

    prompt = f"""
    Generate a professional resume for {full_name} applying for {job_title}.
    Experience: {experience}
    Skills: {skills}
    Match with job description: {job_description}
    """

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            store=True,
            messages=[
                {"role": "system", "content": "You are a professional resume writer."},
                {"role": "user", "content": prompt}
            ]
        )
        resume_text = response.choices[0].message
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")

    # Save the generated resume to the database
    new_resume = Resume(
        user_id=user["id"],
        full_name=full_name,
        experience=experience,
        skills=skills,
        job_title=job_title,
        job_description=job_description
    )
    db.add(new_resume)
    db.commit()

    print(resume_text.content)
    return {"resume": resume_text.content}
