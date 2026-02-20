# SyllApp

> Zaawansowane środowisko do tworzenia i analizowania tekstów muzycznych z pełnym wsparciem dla języka polskiego.

Dostęp online - `SyllApp.netlify.app`

## O projekcie

**SyllApp** to wieloplatformowa aplikacja naśladująca IDE (Integrated Development Environment) dedykowana twórcom tekstów muzycznych, szczególnie w stylu rap/hip-hop. Projekt składa się z dwóch głównych komponentów:

- **Frontend** — aplikacja mobilna, desktopowa i webowa zbudowana we Flutterze
- **Backend** — REST API zbudowane w FastAPI z bazą danych PostgreSQL

## Kluczowe funkcjonalności

-  **Licznik sylab w czasie rzeczywistym** — analiza metryki dla każdej linii tekstu
-  **Detektor rymów** — wykrywanie rymów dokładnych, przybliżonych i asonansów z kolorowym podświetlaniem
-  **Schemat rymów** — automatyczna generacja notacji literowej (AABB, ABAB, etc.)
-  **Sugestie rymów** — inteligentne podpowiedzi słów rymujących się
-  **Zarządzanie projektami** — tworzenie, edycja i organizacja projektów tekstowych
-  **Synchronizacja z chmurą** — backup i synchronizacja między urządzeniami (tryb online)
-  **Tryb offline** — pełna funkcjonalność bez połączenia z internetem (desktop)
-  **Wsparcie wieloplatformowe** — Android, iOS, Web, Windows, Linux, macOS

## Technologie

### Frontend
- **Flutter** 3.38.8 — framework UI
- **Riverpod** 3.2.1 — zarządzanie stanem
- **Dio** 5.7.0 — komunikacja HTTP
- **Flutter Secure Storage** — bezpieczne przechowywanie tokenów JWT

### Backend
- **FastAPI** 0.115.0 — framework REST API
- **SQLAlchemy** 2.0.35 — ORM
- **PostgreSQL** / **SQLite** — baza danych
- **JWT** — autoryzacja i autentykacja
- **BeautifulSoup4** — web scraping dla sugestii rymów

## Architektura

Aplikacja wykorzystuje **Clean Architecture** z wyraźnym podziałem na warstwy i organizacją feature-first. Backend i frontend komunikują się przez REST API z autoryzacją opartą na tokenach JWT.

```
SyllApp/
├── frontend/          # Aplikacja Flutter (mobile + desktop + web)
│   └── README.md     # Szczegółowa dokumentacja frontendu
│
├── Backend/          # REST API FastAPI
│   └── README.md     # Szczegółowa dokumentacja backendu
│
└── README.md         # Ten plik
```

## Dokumentacja

Szczegółowa dokumentacja dla każdego komponentu projektu znajduje się w odpowiednich folderach:

- **[Frontend Documentation](./frontend/README.md)** — architektura, instalacja, użytkowanie, konfiguracja aplikacji Flutter
- **[Backend Documentation](./Backend/README.md)** — API endpoints, baza danych, deployment, konfiguracja serwera

## Szybki start

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run -d <platform>  # windows | android | chrome
```

### Backend (FastAPI)

```bash
cd Backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Status projektu

| Platforma | Status | Funkcjonalność |
|-----------|--------|----------------|
| Android   | ✅ Gotowe | Pełna (online + sync) |
| Web       | ✅ Gotowe | Pełna (online + sync) |
| Windows   | ✅ Gotowe | Offline (bez syncu) |
| iOS       | ⚠️ Nietestowane | Teoretycznie działa |
| Linux     | ⚠️ Nietestowane | Teoretycznie działa |
| macOS     | ⚠️ Nietestowane | Teoretycznie działa |

## Licencja

Wszelkie prawa zastrzeżone ©

## Autorzy

Jakub Wilczek, Olek Wąsowicz

---

**Uwaga**: Aby uruchomić pełną funkcjonalność (synchronizacja, sugestie rymów online), wymagany jest działający backend. Aplikacja działa również w trybie offline z ograniczonymi funkcjami (tylko lokalne pliki i słownik offline).