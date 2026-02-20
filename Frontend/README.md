# SyllApp — Lyrics IDE

> Zaawansowane środowisko do tworzenia i analizowania tekstów muzycznych, szczególnie w stylu rap/hip-hop, z pełnym wsparciem dla języka polskiego.

---

## Spis treści

- [Opis aplikacji](#opis-aplikacji)
- [Zastosowane technologie](#zastosowane-technologie)
- [Architektura](#architektura)
- [Opis działania](#opis-działania)
- [Funkcje i zalety](#funkcje-i-zalety)
- [Platformy](#platformy)
- [Instalacja i uruchomienie](#instalacja-i-uruchomienie)
- [Skróty klawiszowe](#skróty-klawiszowe)
- [Konfiguracja i ustawienia](#konfiguracja-i-ustawienia)

---

## Opis aplikacji

**SyllApp** to wieloplatformowe środowisko programistyczne (IDE) dedykowane twórcom tekstów muzycznych. Aplikacja łączy funkcje edytora tekstu z zaawansowanymi narzędziami analitycznymi, umożliwiając twórcom pisanie, analizowanie i doskonalenie tekstów bezpośrednio w edytorze — w czasie rzeczywistym.

Aplikacja jest skierowana przede wszystkim do raperów, beatmakerów i autorów tekstów, którym zależy na precyzyjnej kontroli nad metryką (liczba sylab) i strukturą rymów. Obsługuje pełen zestaw znaków języka polskiego, w tym litery diakrytyczne (ą, ę, ó, ź, ż, ś, ć, ń).

---

## Zastosowane technologie

### Framework i język
| Technologia | Wersja     | Zastosowanie |
|---|------------|---|
| **Flutter** | SDK 3.38.8 | Framework UI, wieloplatformowość |
| **Dart** | ^3.10.7    | Język programowania |

### Zarządzanie stanem
| Pakiet | Wersja | Zastosowanie |
|---|---|---|
| **flutter_riverpod** | ^3.2.1 | Reaktywne zarządzanie stanem (Notifier, NotifierProvider, Provider) |

### Sieć i backend
| Pakiet | Wersja | Zastosowanie |
|---|---|---|
| **dio** | ^5.7.0 | Klient HTTP, interceptory, tokeny JWT |

### Przechowywanie danych
| Pakiet | Wersja | Zastosowanie |
|---|---|---|
| **shared_preferences** | ^2.2.0 | Ustawienia użytkownika, onboarding |
| **flutter_secure_storage** | ^9.2.4 | Bezpieczne przechowywanie tokenów JWT |
| **path_provider** | ^2.1.5 | Dostęp do katalogów systemowych |
| **file_picker** | ^8.1.6 | Wybieranie plików i folderów |

### Zasoby
| Zasób | Opis                                                        |
|---|-------------------------------------------------------------|
| `assets/logo.png` | Logo aplikacji                                              |
| `assets/polish_words.txt` | Słownik słów polskich dla trybu offline (podpowiedzi rymów) |

### Narzędzia deweloperskie
- **flutter_lints** ^6.0.0 — analiza statyczna kodu
- **flutter_launcher_icons** ^0.14.1 — generowanie ikon aplikacji
- **benchmark_harness** ^2.4.0 — testy wydajnościowe

---

## Architektura

Projekt stosuje **Clean Architecture** z podziałem na warstwy, zorganizowany według funkcjonalności (feature-first):

```
lib/
├── core/                        # Współdzielona logika i narzędzia
│   ├── config/                  # Konfiguracja aplikacji (tryb offline/online)
│   ├── error/                   # Obsługa błędów (Result<T>, Failure)
│   ├── network/                 # Klient HTTP, interceptory, stałe API
│   ├── project/                 # Model projektu
│   ├── settings/                # Ustawienia (Notifier, State)
│   ├── theme/                   # Motyw aplikacji (aktualnie jedynie ciemny)
│   ├── usecases/                # Bazowy interfejs UseCase
│   ├── utils/                   # Narzędzia: licznik sylab, detektor rymów,
│   │                            #            tokenizer, utils platform/pliki
│   └── widgets/                 # Współdzielone widżety (FloatingGlassSheet, Toast)
│
└── features/
    ├── auth/                    # Uwierzytelnianie
    │   ├── application/         # AuthNotifier, AuthState
    │   ├── data/                # DataSources, Models, Repository Impl
    │   ├── domain/              # Entities, Repository interfaces, UseCases
    │   └── presentation/        # LoginPage, RegisterPage, widżety
    │
    ├── editor/                  # Edytor tekstów
    │   ├── application/         # EditorNotifier, RhymeNotifier
    │   ├── data/                # DataSources (plik, API rymów), Repository Impl
    │   ├── domain/              # Lyric, Verse, RhymeResult, UseCases
    │   └── presentation/        # EditorPage, VerseEditor, StatsPanel i in.
    │
    ├── onboarding/              # Ekran powitalny
    │
    └── project/                 # Zarządzanie projektami
        ├── application/         # ProjectNotifier, SyncNotifier
        ├── data/                # Cloud + lokalne datasource, Repository Impl
        ├── domain/              # Repozytoria (lokalne i chmura)
        └── presentation/        # WelcomeScreen, dialogi tworzenia projektu
```

### Wzorce projektowe
- **Repository Pattern** — oddzielenie logiki dostępu do danych od domeny
- **Use Case Pattern** — enkapsulacja logiki biznesowej
- **Notifier + NotifierProvider** — reaktywna aktualizacja UI
- **Conditional Imports** — osobne implementacje dla Web, Native i Stub (platform_utils, native_file_utils, lyrics_repository_factory)
- **Result<T>** — typ zwracany przez operacje, eliminuje rzucanie wyjątków

---

## Opis działania

### Uruchomienie

1. Przy pierwszym uruchomieniu wyświetlany jest ekran **onboardingu** (4 slajdy prezentujące funkcje).
2. Następnie użytkownik trafia na **ekran powitalny** (WelcomeScreen), gdzie może:
   - Stworzyć nowy projekt
   - Otworzyć istniejący projekt z dysku (desktop)
   - Zalogować się / zarejestrować (tryb online)
3. Po wybraniu lub otwarciu projektu ładowany jest **edytor**.

### Edytor

Edytor działa w dwóch układach:
- **Desktop** (szerokość > próg responsywności) — trójpanelowy układ z możliwością zmiany rozmiarów
- **Mobile** — uproszczony, jednokolumnowy układ z dolnym paskiem narzędzi

#### Panele (desktop)
| Panel | Zawartość |
|---|---|
| **Lewy** | Drzewo plików projektu (native) lub lista ostatnich projektów (web) |
| **Centralny** | Edytor wersu (`VerseEditor`) z numerami linii i licznikiem sylab |
| **Prawy** | Panel statystyk (`StatsPanel`) |

#### Analiza w czasie rzeczywistym
Każda zmiana tekstu wyzwala:
1. **Liczenie sylab** — dla każdej linii osobno, wyświetlane w rynnie edytora
2. **Wykrywanie rymów** — grupowanie wersów rymujących się; kolorowe podświetlanie w edytorze
3. **Schemat rymów** — notacja literowa (np. `AABB`, `ABAB`) widoczna w panelu statystyk i pasku statusu

### Synchronizacja z chmurą

Na platformach z włączonym trybem online (Android, iOS, Web):
- Po zalogowaniu automatycznie uruchamiana jest **synchronizacja dwukierunkowa**
- Lokalne projekty bez `cloudId` są **wysyłane** do serwera
- Projekty z chmury nieistniejące lokalnie są **pobierane**
- Zmodyfikowane projekty są **aktualizowane**
- Tymczasowy serwer REST API: `https://syllapp.onrender.com`

> Na **Windows** aplikacja działa wyłącznie w trybie offline (`kOfflineOnly = true`), ze wzglęu na
> eksplorator.

---

## Funkcje i zalety

### Licznik sylab
- Oblicza liczbę sylab w każdej linii na bieżąco
- Wyświetla wynik w rynnie edytora (obok numeru linii)
- Obsługuje polskie samogłoski: `a, ą, e, ę, i, o, ó, u, y`
- Pokazuje sumaryczną i średnią liczbę sylab w panelu statystyk

### Detektor rymów
- Wykrywa **rymy dokładne** (identyczne zakończenia)
- Wykrywa **rymy przybliżone** — na podstawie podobieństwa zakończeń (próg konfigurowalny)
- Wykrywa **asonanse** — rymy samogłoskowe (opcjonalne, domyślnie włączone)
- Generuje **schemat rymów** w notacji literowej (A, B, C…)
- Koloruje rymujące się wersy unikalnym kolorem per grupa

### Sugestie rymów
- Kliknięcie prawym przyciskiem (desktop) lub długie przytrzymanie (mobile) na słowie otwiera popup z sugestiami rymów
- Sugestie pobierane są z zewnętrznego API (`/scrape/`), bądź z lokalnej polskich słów dla trybu offline.
- W popupie widoczne są słowa z tej samej grupy rymów (kolorowe oznaczenie)
- Sugestię można skopiować i wstawić do tekstu jednym kliknięciem

### Zarządzanie projektami
- Tworzenie nowych projektów z nazwą
- Otwieranie istniejących folderów (desktop native)
- Wieloplikowy projekt z drzewem plików (native)
- Lista ostatnich projektów (web/mobile)
- Automatyczny zapis (`autoSave`, domyślnie co 1 minutę)
- Ręczny zapis (`Ctrl+S`)

### Synchronizacja z chmurą *(tryb online)*
- Rejestracja i logowanie z tokenami JWT (access + refresh)
- Automatyczne odświeżanie tokenów przez interceptor Dio
- Dwukierunkowa synchronizacja projektów
- Wykrywanie i obsługa wygaśnięcia sesji z powiadomieniem użytkownika

### Interfejs użytkownika
- **Ciemny motyw** (jedyny, zoptymalizowany pod długą pracę)
- **Responsywny layout** — automatyczne przełączanie między widokiem desktop i mobile
- **Panele o zmiennym rozmiarze** (resizable) z uchwytem przeciągania
- **Pasek statusu** — Inspirowany VSC - linia, kolumna, liczba linii, sylab, schemat rymów, nazwa pliku
- **Onboarding** — jednorazowy ekran powitalny przy pierwszym uruchomieniu
- **Glassmorphism** — efekty przezroczystości w dialogach i tle ekranów auth

### Dostosowanie (Ustawienia)
| Ustawienie | Opis | Domyślnie |
|---|---|---|
| `rhymeThreshold` | Próg podobieństwa rymów (0.0–1.0) | 0.6 |
| `enableAssonance` | Wykrywanie asonansów | tak |
| `autoSave` | Automatyczny zapis | tak |
| `autoSaveIntervalMinutes` | Interwał auto-zapisu | 1 min |
| `fontSize` | Rozmiar czcionki edytora | 16 px |

---

## Platformy

| Platforma | Obsługa | Tryb    | Uwagi                                 |
|---|--|---------|---------------------------------------|
| **Android** | ✅ | Online  | Pełna funkcjonalność + sync           |
| **iOS** | ⚠️ | Online  | Nietestowane                          |
| **Web** | ✅ | Online  | Lista projektów zamiast drzewa plików |
| **Windows** | ✅ | Offline | Brak auth i sync (kOfflineOnly)       |
| **Linux** | ⚠️ | Offline | Nietestowane                          |
| **macOS** | ⚠️ | Offline | Nietestowane                          |

---

## Instalacja i uruchomienie

### Wymagania
- Flutter SDK ^3.10.7
- Dart SDK ^3.10.7

### Kroki

```bash
# Klonowanie repozytorium
git clone <url-repo>
cd SyllApp

# Instalacja zależności
flutter pub get

# Uruchomienie (wybierz platformę)
flutter run -d windows
flutter run -d android
flutter run -d chrome
```

### Budowanie

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## Skróty klawiszowe

| Skrót | Akcja |
|---|---|
| `Ctrl + S` | Zapisz plik |
| `Ctrl + N` | Nowy plik / projekt |
| `Ctrl + O` | Otwórz plik *(tylko native)* |
| `Ctrl + B` | Przełącz panel eksploratora |
| `Ctrl + Shift + S` | Przełącz panel statystyk |

---

## Konfiguracja i ustawienia

Ustawienia są przechowywane w **SharedPreferences** i dostępne z poziomu dialogu ustawień w aplikacji (ikona koła zębatego w pasku tytułu).

Tryb online/offline kontrolowany jest przez zmienną `kOfflineOnly` w [lib/core/config/app_config.dart](./lib/core/config/app_config.dart), która sprawdza bieżącą platformę.

Tokeny JWT są przechowywane w **flutter_secure_storage** (szyfrowany magazyn specyficzny dla platformy).
