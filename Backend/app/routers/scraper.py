
from fastapi import APIRouter, HTTPException, Query
import httpx
from bs4 import BeautifulSoup
from urllib.parse import quote_plus

router = APIRouter(prefix="/scrape", tags=["scraper"])

def _empty(word: str) -> dict:
    return {"word": word, "sylab1": [], "sylab2": [], "sylab3": [], "sylab4": [], "sylab5": []}

def _bucket_key(n: int) -> str | None:
    if 1 <= n <= 5:
        return f"sylab{n}"
    return None

def _clean(token: str) -> str:
    return token.strip().rstrip(",").strip()

@router.get("/")
async def scrape(word: str = Query(..., min_length=1, description="Słowo do pobrania rymów")):
    encoded = quote_plus(word)
    url = f"https://polskierymy.pl/?rymy={encoded}"

    headers = {
        "User-Agent": "Mozilla/5.0 (compatible; NotesAPI-Scraper/1.0; +https://example.com)"
    }
    timeout = httpx.Timeout(12.0, connect=6.0)

    try:
        async with httpx.AsyncClient(timeout=timeout, headers=headers, follow_redirects=True) as client:
            resp = await client.get(url)
            resp.raise_for_status()
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=f"Błąd pobierania strony źródłowej: {e}")

    soup = BeautifulSoup(resp.text, "html.parser")
    result = _empty(word)

    for p in soup.find_all("p", attrs={"data-n_syllables": True}):
        try:
            n_syl = int(p.get("data-n_syllables", "").strip())
        except ValueError:
            continue

        key = _bucket_key(n_syl)
        if not key:
            continue

        for sp in p.find_all("span", class_="result"):
            text = _clean(sp.get_text(" ", strip=True))
            if text:
                result[key].append(text)

    return result
