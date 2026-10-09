# Audyt: gdzie zastosować `jev-compaction-plus`

Stan na **2026-10-09**. Badane narzędzie: [cth9191/jev-compaction-plus](https://github.com/cth9191/jev-compaction-plus) (v0.1.0, MIT).
Przejrzane repozytoria: `Kaucja`, `animacje-java-script`, `Mods`, `Automatyzacja-dla-firm`, `HUD_bot`, `auto_bot`, `crypto-lab`.
Nie przejrzane: `Trading-bot` (sesja nie dostała dostępu), `AI` (repozytorium jest puste).

## 1. Co to narzędzie robi (i czego nie robi)

`jev-compaction-plus` to **plugin do Claude Code**. Podmienia `/compact` (i sam włącza się przy 60% kontekstu).
Zamiast prosić Opusa o streszczenie, pyta model decyzyjny Jev (TypeSafe), który **stary wynik narzędzia** jest jeszcze potrzebny:

- potrzebny → zostaje słowo w słowo;
- niepotrzebny i ≥ 1500 znaków → trafia do pliku `.jev-drawer/<czas>/tNN-Narzędzie.txt`, a w sesji zostaje etykieta „przeniesiono do …, przeczytaj, jeśli trzeba”;
- wiadomości użytkownika, odpowiedzi Claude, pierwsza wiadomość i 6 najnowszych **nie są ruszane**;
- gdy Jev zawiedzie albo cięcie < 25% → normalna kompakcja wbudowana.

Wniosek dla audytu: **daje najwięcej tam, gdzie sesje Claude Code są pełne dużych wyników narzędzi** (czytanie dużych plików, logi, testy, CSV, wyniki sweepów).
W sesjach „gadanych” prawie nic nie zyskuje.

Druga, rzadziej przydatna forma: **biblioteka** `compact(messages, asker, options)` z `src/`, do własnej pętli agenta w TypeScript, w której narastają wyniki narzędzi.

### Wymagania
- Claude Code ≥ 2.1.274 z `CLAUDE_CODE_ENABLE_FUNCTION_HOOKS=1` (twoje mody w `Mods` i tak wymagają ≥ 2.1.287, więc wersja jest spełniona).
- Klucz TypeSafe **albo OpenRouter (`sk-or-…`)**. Masz już klucz OpenRouter do Jev w projekcie `Kaucja` (`jev.cjs` woła `typesafe/jev-1.13`). Ten sam rodzaj klucza działa w pluginie.

### Ograniczenia, które wpływają na decyzje
| Ograniczenie | Skutek dla ciebie |
|---|---|
| Kompakcja **nie przetrwa wznowienia sesji** (`--resume` przywraca pełną historię) | Przed zamknięciem długiej sesji rób handoff (masz go w `session-bar`). |
| **Prywatność**: tekst rozmowy, wejścia narzędzi i podglądy wyników (600 znaków z początku i końca) idą do TypeSafe/OpenRouter | Nie używać w sesjach, w których Claude czyta klucze, dane klientów, prawdziwe faktury. |
| Szuflada `.jev-drawer/` nie jest sprzątana | Trzeba ją czasem usuwać. Ma własny `.gitignore` (`*`), więc nie trafi do commita. |
| Hooki funkcyjne to wczesny dostęp | API może się zmienić. Trzymać wbudowaną kompakcję jako awaryjną (plugin robi to sam). |
| Sesje w chmurze (claude.ai/code) | Sieć środowiska musi przepuszczać `api.typesafe.ai` albo `openrouter.ai`; inaczej każda kompakcja spada na wbudowaną. |

## 2. Wyniki: gdzie stosować

Skala: **★★★** wdrażać od razu · **★★** warto · **★** tylko po spełnieniu warunku · **✗** nie stosować.

| Miejsce | Ocena | Forma | Dlaczego |
|---|---|---|---|
| **System: twoje sesje Claude Code (globalnie)** | ★★★ | plugin, `~/.claude/settings.json` | Jedno włączenie obejmuje wszystkie projekty, obecne i przyszłe. Wyłączasz tylko tam, gdzie zakazuje tego tabela niżej. |
| `crypto-lab` | ★★★ | plugin | 4,4 MB CSV w `data/`, 25 plików testów, sweepy, testy permutacyjne. Długie wyniki, które po analizie przestają być potrzebne słowo w słowo. |
| `HUD_bot` | ★★★ | plugin | 82 testy, `zmierz.py --siatka` (przeszukanie + null), pobieranie słupków. Ten sam profil co `crypto-lab`. |
| `Kaucja` | ★★★ (dev) / ✗ (dane sklepu) | plugin | 48 KB `DZIENNIK_ROZWIAZAN.md`, duże JSON-y (`reference-catalog.json`, `label-crops.json`), wyniki testów OCR. **Wyłączyć**, gdy w sesji są prawdziwe faktury sklepu. README obiecuje: „faktury nie są wysyłane do AI”. |
| `animacje-java-script` | ★★ | plugin | Skill `animate` to długie sesje (intake → storyboard → build → render). Logi buildów, ffmpeg i renderów są duże i jednorazowe. Obrazy klatek nie są kompaktowane (plugin tnie tylko tekst). |
| `Mods` | ★★★ jako miejsce na **rozszerzenia** | nowe mody | Patrz sekcja 3. `context-bar` i `session-bar` dotyczą dokładnie tego samego problemu. |
| `auto_bot` | ★ | plugin, z blokadą plików kluczy | Sesje z testami i dziennikiem pasują. Projekt ma jednak klucze brokera (`.env`, `klucze.txt`). **Warunek**: zablokować Claude czytanie tych plików (sekcja 4) albo wyłączyć plugin w tym repo. **Nigdy** w ścieżce decyzji bota: niezmiennik nr 3 (każda decyzja z powodem i stanem) wyklucza wycinanie kontekstu w runtime. |
| `Trading-bot` | ★★★ (przypuszczalnie) | plugin | Nie przejrzane. Według `CLAUDE.md` pozostałych repo to trzy laby z testami i paper tradingiem, czyli ten sam profil co `crypto-lab`. Do potwierdzenia po udzieleniu dostępu. |
| `Automatyzacja-dla-firm` (dev) | ★★ | plugin | Dziś to katalog README (status: koncepcja). Plugin pomoże przy budowie workflowów n8n, w których wyniki wykonań i JSON-y są długie. |
| `Automatyzacja-dla-firm` (runtime u klientów) | ★ | biblioteka `compact()` | Tylko agenci z pętlą narzędzi: **29 rozmowa z bazą danych** (duże wyniki SQL, najlepszy kandydat), **12 agent ERP/CRM**, **03 agent dokumentów**, **05 agent korespondencji**, **31 agent obsługi sklepu**. **Warunek**: DPA z TypeSafe/OpenRouter i potwierdzone miejsce przetwarzania (wymóg z `00-wspolna-infrastruktura`: „DPA z dostawcami API”). Bez tego ✗. |
| `Automatyzacja-dla-firm` 10 chatbot, 11 voicebot, 01 asystent spotkań | ✗ | — | Rozmowy bez dużych wyników narzędzi: plugin i tak spadnie na zwykłe streszczenie. |
| Studio animacji (`studio.html`) | ✗ | — | Pojedyncze wywołania Claude bez wyników narzędzi. Nie ma czego kompaktować. |
| `AI` | — | — | Puste repozytorium. Obejmie je ustawienie globalne. |

## 3. Hacki i automatyzacje do zbudowania w `Mods`

Twoje mody już obsługują `session.compact`. Oba wywołują najpierw `next(e)`, a potem odświeżają pasek, więc **nie kolidują** z pluginem Jev. Pasek odświeży się po kompakcji Jev tak samo jak po wbudowanej.

1. **`context-bar`: drugi znacznik progu.** Dziś pasek pokazuje próg *wbudowanej* auto-kompakcji. Przy Jev kompakcja startuje przy `compactAtPercent` (60%), czyli wcześniej. Bez drugiego znacznika pasek wprowadza w błąd. Do dodania: znacznik „Jev @60%”, gdy plugin jest włączony.
2. **`session-bar`: handoff po kompakcji Jev.** Kompakcja Jev nie przetrwa `--resume`. Po toaście `kept … no summary` przycisk Handoff powinien się podświetlić („zapisz HANDOFF.md przed zamknięciem”).
3. **Nowy mod `drawer`**: komenda `/drawer` pokazująca `INDEX.md` ostatnich szuflad, ich rozmiar i przycisk „wyczyść starsze niż N dni”. Rozwiązuje brak automatycznego sprzątania.
4. **Nowy mod `jev-guard`**: przy `session.start` sprawdza, czy w projekcie leżą pliki kluczy albo dane klientów (`.env`, `klucze.txt`, `faktury/`). Jeśli tak, ostrzega albo wyłącza kompakcję Jev dla tej sesji. Automatyzuje sekcję 4.
5. **Agent `security-auditor`** (`.claude/agents/`): dopisać punkt kontrolny, czy `.jev-drawer/` nie trafiło do repo, jeśli ktoś usunął jego `.gitignore`.

## 4. Kiedy NIE włączać (reguła dla wszystkich projektów)

Wyłącz plugin w projekcie albo zablokuj odczyt plików, gdy sesja może zobaczyć:
- klucze API i hasła (`auto_bot`, `.env` gdziekolwiek);
- prawdziwe dane klientów lub sklepu (faktury w `Kaucja`, wdrożenia `Automatyzacja-dla-firm`);
- cokolwiek, czego nie wolno wysłać do podmiotu trzeciego bez umowy.

Blokada odczytu w `.claude/settings.json` projektu (działa niezależnie od Jev i warto ją mieć zawsze):

```json
{
  "permissions": {
    "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./klucze.txt)"]
  }
}
```

## 5. Plan wdrożenia

1. Ustawienie globalne (`~/.claude/settings.json`, na Windowsie `%USERPROFILE%\.claude\settings.json`). Gotowy plik: [`szablony/settings.user.json`](szablony/settings.user.json).
2. Instalacja:
   ```
   claude plugin marketplace add cth9191/jev-compaction-plus
   claude plugin install jev-compaction-plus@jev-compaction-plus
   ```
   Przed instalacją przejrzyj kod pluginu i uruchom `claude plugin validate` (tak radzi `Mods/docs/POMYSLY.md`). W tym audycie przejrzano `hooks/fast-jev.ts`, `src/client.ts`, `src/request.ts`: plugin łączy się wyłącznie z endpointem Jev (TypeSafe/OpenRouter albo `baseUrl`) i zapisuje tylko pliki szuflady.
3. W `auto_bot` dodaj blokadę z sekcji 4. W `Kaucja` wyłącz plugin, gdy pracujesz na prawdziwych fakturach.
4. Pierwszy tydzień: obserwuj toasty. `fallback to built-in summary` w danym repo oznacza, że Jev nic tam nie daje.
5. Mody z sekcji 3, w kolejności 1 → 2 → 3 → 4.
6. Każdy nowy projekt: [`PROMPT-AUDYTU.md`](PROMPT-AUDYTU.md) i fragment [`szablony/CLAUDE-jev.md`](szablony/CLAUDE-jev.md) do jego `CLAUDE.md`.
