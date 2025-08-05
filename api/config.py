import os
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings."""
    # API config
    API_V1_STR: str = "/api"
    PROJECT_NAME: str = "Bazario"
    
    # Database connection
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: str = os.getenv("DB_PORT", "5432")
    DB_USER: str = os.getenv("DB_USER", "yeedu")
    DB_PASS: str = os.getenv("DB_PASS", "yeedu")
    DB_NAME: str = os.getenv("DB_NAME", "postgres")
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "bazario-dev-secret-key")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60  # 1 hour
    
    # Environment
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = ENVIRONMENT == "development"
    
    @property
    def DATABASE_URL(self) -> str:
        """Get the database connection URL."""
        return f"postgresql://{self.DB_USER}:{self.DB_PASS}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create settings instance
settings = Settings()