from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, notes
from .utils import init_db
from .routers import scraper

def get_app() -> FastAPI:
    app = FastAPI(title="SyllApp", version="1.0.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(auth.router)
    app.include_router(notes.router)
    app.include_router(scraper.router)

    @app.get("/", tags=["health"])
    def health():
        return {"status": "ok"}

    return app


app = get_app()

init_db()
