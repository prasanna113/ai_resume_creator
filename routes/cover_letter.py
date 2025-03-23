from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from openai import AsyncOpenAI
from auth import get_current_user
from database import get_db
from models import CoverLetter
from config import OPENAI_API_KEY

router = APIRouter()

@router.post("/")
async def generate_cover_letter(
    full_name: str,
    experience: str,
    job_title: str,
    job_description: str,
    db: AsyncSession = Depends(get_db),
    user: dict = Depends(get_current_user),
):
    """Generates a cover letter using OpenAI API based on user input."""

    client = AsyncOpenAI(
        api_key=OPENAI_API_KEY
    )

    prompt = f"""
    Generate a personalized cover letter for {full_name} applying for {job_title}.
    Experience: {experience}
    Match with job description: {job_description}
    """

    try:
        response = await client.chat.completions.create(
            model="gpt-4o-mini",
            store=True,
            messages=[
                {"role": "system", "content": "You are a professional cover letter writer."},
                {"role": "user", "content": prompt}
            ]
        )
        cover_letter_text = response.choices[0].message
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {str(e)}")

    # Save the generated cover letter to the database asynchronously
    new_cover_letter = CoverLetter(
        user_id=user["id"],
        full_name=full_name,
        experience=experience,
        job_title=job_title,
        job_description=job_description
    )
    db.add(new_cover_letter)
    await db.commit()
    await db.refresh(new_cover_letter)

    return {"cover_letter": cover_letter_text.content}
