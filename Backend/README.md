# SyllApp Backend API

Backend REST API dla aplikacji SyllApp, zbudowany w oparciu o FastAPI i SQLAlchemy. System zapewnia bezpieczną autoryzację użytkowników z tokenami JWT, funkcjonalne zarządzanie notatkami oraz integrację z zewnętrznymi serwisami rymów.

## Użyte technologie

Backend aplikacji został zbudowany przy użyciu sprawdzonych technologii:

- **FastAPI 0.115.0** - Nowoczesny, wysokowydajny framework do budowy API
- **SQLAlchemy 2.0.35** - Toolkit SQL i biblioteka Object-Relational Mapping (ORM)
- **Pydantic 2.x** - Walidacja danych przy użyciu adnotacji typów Python
- **Uvicorn 0.30.6** - Wydajny serwer ASGI
- **Python-Jose 3.3.0** - Obsługa JWT (JSON Web Tokens)
- **Passlib 1.7.4** - Kompleksowy framework do hashowania haseł
- **Wsparcie PostgreSQL** - Produkcyjna baza danych poprzez psycopg3
- **BeautifulSoup4 4.12.3** - Web scraping i parsowanie HTML
- **HTTPX 0.27.2** - Nowoczesna biblioteka klienta HTTP

## Funkcjonalności

### Autentykacja i autoryzacja
- Rejestracja użytkowników z bezpiecznym hashowaniem haseł (SHA-512 Crypt)
- Autoryzacja oparta na JWT z tokenami dostępu i odświeżania
- Mechanizm odświeżania tokenów do zarządzania sesjami
- Bezpieczna funkcja wylogowania z unieważnianiem tokenów
- Możliwość odwołania wszystkich sesji użytkownika

### Zarządzanie notatkami
- Tworzenie, odczytywanie, aktualizowanie i usuwanie notatek (operacje CRUD)
- Izolacja notatek specyficznych dla użytkownika
- Wsparcie paginacji dla listowania notatek
- Automatyczne śledzenie liczby notatek per użytkownik

### Integracja zewnętrzna
- Serwis scrapowania rymów dla polskich słów
- Kategoryzacja rymów według liczby sylab
- Solidna obsługa błędów dla wywołań zewnętrznych API

### Funkcje bezpieczeństwa
- Wygasanie i rotacja tokenów
- Ochrona przed typowymi lukami bezpieczeństwa
- Konfiguracja middleware CORS
- Bezpieczne przechowywanie haseł ze standardowym hashowaniem

## Architektura

Aplikacja wykorzystuje modularną architekturę z wyraźnym rozdzieleniem odpowiedzialności:

```
app/
├── routers/          # Endpointy API i handlery tras
│   ├── auth.py      # Endpointy autoryzacji
│   ├── notes.py     # Endpointy zarządzania notatkami
│   └── scraper.py   # Integracja z zewnętrznymi danymi
├── models.py        # Modele ORM SQLAlchemy
├── schemas.py       # Schematy walidacji Pydantic
├── database.py      # Konfiguracja bazy danych i zarządzanie sesjami
├── security.py      # Narzędzia do kontroli bezpieczeństwa
├── deps.py          # Uwierzytelnia i zwraca użytkownika
├── utils.py         # Tworzy tabele bazy
└── main.py          # Punkt wejścia aplikacji i konfiguracja
```

### Wzorce projektowe

- **Dependency Injection**: System zależności FastAPI dla sesji bazy danych i autentykacji
- **Wzorzec Repository**: Separacja logiki dostępu do danych przez SQLAlchemy ORM
- **Wzorzec DTO**: Schematy Pydantic do walidacji request/response
- **Wzorzec Middleware**: CORS i obsługa błędów
- **Autentykacja oparta na tokenach**: Bezstanowa autentykacja z użyciem JWT

## Konfiguracja

### Zmienne środowiskowe

| Zmienna | Opis | Domyślna wartość | Wymagana |
|---------|------|------------------|----------|
| `DATABASE_URL` | String połączenia z bazą danych | `sqlite:///./app.db` | Nie |
| `SECRET_KEY` | Klucz do podpisywania JWT | `change_me` | **Tak** |
| `ALGORITHM` | Algorytm JWT | `HS256` | Nie |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Czas życia tokena dostępu | `60` | Nie |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Czas życia tokena odświeżania | `14` | Nie |
| `PASSWORD_RESET_TOKEN_EXPIRE_MINUTES` | Czas życia tokena resetowania hasła | `15` | Nie |
``



## Schemat bazy danych

### Tabela Users
```sql
CREATE TABLE Users (
    idUser INTEGER PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    notesCount INTEGER DEFAULT 0 NOT NULL
);
```

### Tabela Notes
```sql
CREATE TABLE Notes (
    idNote INTEGER PRIMARY KEY,
    idUser INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    text TEXT NOT NULL,
    FOREIGN KEY (idUser) REFERENCES Users(idUser) ON DELETE CASCADE
);
```

### Tabela RefreshTokens
```sql
CREATE TABLE RefreshTokens (
    id INTEGER PRIMARY KEY,
    token VARCHAR(255) UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    replaced_by_token VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(idUser) ON DELETE CASCADE
);
```

## Licencja

Wszelkie prawa zastrzeżone ©

## Wsparcie

W przypadku problemów, pytań lub chęci współpracy, skontaktuj się z zespołem deweloperskim lub otwórz issue w repozytorium.

---

