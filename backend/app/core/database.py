from sqlmodel import SQLModel, create_engine, Session
from typing import Generator

SQLITE_FILE_NAME = "mediscan.db"
sqlite_url = f"sqlite:///{SQLITE_FILE_NAME}"

engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})

def init_db():
    """
    Creates the tables in the database if they don't exist.
    """
    SQLModel.metadata.create_all(engine)
    print("✅ SQLite Database Connected & Tables Created!")

def get_session() -> Generator[Session, None, None]:
    """
    Dependency to provide a database session to endpoints.
    """
    with Session(engine) as session:
        yield session