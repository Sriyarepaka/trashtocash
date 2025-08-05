from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from api.routes.health import router as health_router
from api.routes.roles import router as roles_router
from api.routes.users import router as users_router

from api.routes.item_store import router as item_store_router
from api.routes.sellers_request import router as sellers_requests_router

app = FastAPI(
    title="trashtocash",
    description="trashtocash API",
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
app.include_router(item_store_router, prefix="/api", tags=["Items Store"])
app.include_router(sellers_requests_router, prefix="/api", tags=["Sellers Requests"])

# Run the application
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api.main:app", host="0.0.0.0", port=8080, reload=True)