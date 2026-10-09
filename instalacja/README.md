# Instalacja kompletu Jev

Jedna instalacja obejmuje wszystkie projekty, obecne i przyszłe: ustawienia globalne Claude Code i mody z marketplace [71macintosh/Mods](https://github.com/71macintosh/Mods).

| Mod | Co robi |
|---|---|
| `jev-compaction-plus` | Kompakcja przez Jev w ~0,5 s; usunięte wyniki narzędzi trafiają do `.jev-drawer/`. |
| `jev-guard` | Nie wczytuje plików z kluczami do rozmowy; w projektach z danymi klientów (`faktury/`, `.jev-off`…) wyłącza Jev. |
| `drawer` | `/drawer`: zawartość i czyszczenie `.jev-drawer/`. |
| `jev-start` | W każdym nowym repo wkleja `.claude/jev/` (prompt audytu, szablony, ustawienia globalne) i ustawienia projektu; przypomina o audycie. |
| `context-bar`, `session-bar` | Próg Jev na pasku kontekstu; podświetlony Handoff po kompakcji Jev. |

## Twój komputer

- **Windows:** kliknij dwa razy `Instaluj-Jev.bat`.
- **macOS / Linux:** `bash instalacja/instaluj.sh`.

Instalator pyta o klucz Jev (TypeSafe albo OpenRouter `sk-or-…`; Enter pomija), dopisuje do `~/.claude/settings.json` tylko brakujące wpisy (kopia: `settings.json.przed-jev`) i instaluje mody, jeśli jest polecenie `claude`. Bez niego mody zainstalują się z ustawień przy następnym starcie Claude Code.

## Sesje w chmurze (claude.ai/code)

W ustawieniach środowiska (menu środowiska w pasku tytułu sesji → Edit):

1. **Setup script:** `curl -fsSL https://raw.githubusercontent.com/71macintosh/Jev-audyt-zastosowania-w-projektach/main/instalacja/instaluj.sh | bash -s -- --chmura`
   Działa po scaleniu tej gałęzi do `main`. Jeśli sieć środowiska blokuje `raw.githubusercontent.com`, wklej w pole setup script całą treść `instaluj.sh`: bez terminala skrypt i tak nie pyta o klucz.
2. **Zmienna środowiska** `TYPESAFE_API_KEY` z kluczem (najlepiej w sekcji sekretów).
3. **Network access:** dodaj `openrouter.ai` (klucz `sk-or-…`) albo `api.typesafe.ai` (klucz TypeSafe) do dozwolonych domen.

Repozytoria z `.claude/settings.json` (wszystkie obecne po scaleniu gałęzi `claude/jev-setup`) włączają mody także bez kroku 1; krok 1 obejmuje repozytoria, które dopiero powstaną.

## Wyłączenie

- W jednym projekcie: pusty plik `.jev-off` w katalogu głównym (zrobi to `jev-guard`) albo `"jev-compaction-plus@mods": false` w `.claude/settings.local.json`.
- Wszędzie: `claude plugin disable jev-compaction-plus@mods`.
