from fastapi import APIRouter
import datetime
import platform

router = APIRouter()

@router.get("/healthCheck")
async def health_check():
    """
    Health check endpoint to verify API is running.
    Returns basic system information.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat(),
        "python_version": platform.python_version(),
        "platform": platform.platform(),
    }