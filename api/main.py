from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from api.routes.health import router as health_router
from api.routes.roles import router as roles_router
from api.routes.users import router as users_router
from api.config import settings

# Create FastAPI app
app = FastAPI(
    title="Trashtocash API",
    description="Backend API for Trashtocash",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health_router, prefix="/api", tags=["Health"])
app.include_router(roles_router, prefix="/api", tags=["Roles"])
app.include_router(users_router, prefix="/api", tags=["Users"])

# Future router inclusions will go here
# app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])
# app.include_router(seller_router, prefix="/api/sellers", tags=["Sellers"])
# app.include_router(buyer_router, prefix="/api/buyers", tags=["Buyers"])
# app.include_router(admin_router, prefix="/api/admin", tags=["Admin"])

if __name__ == "__main__":
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)