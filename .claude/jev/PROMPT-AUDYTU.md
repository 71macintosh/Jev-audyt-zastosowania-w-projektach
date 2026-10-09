# Prompt audytu Jev

Ten plik wkleił mod `jev-start` (marketplace `71macintosh/Mods`). Wyniki wcześniejszych audytów: [71macintosh/Jev-audyt-zastosowania-w-projektach](https://github.com/71macintosh/Jev-audyt-zastosowania-w-projektach) (`AUDYT.md`, `JEV-DECYZJE.md`).

Uruchom w sesji Claude Code w tym repozytorium: „Wykonaj `.claude/jev/PROMPT-AUDYTU.md`”.

---

## Część A: kompakcja Jev (jev-compaction-plus)

1. **Profil sesji.** Czy praca tutaj generuje duże wyniki narzędzi (pliki > 1500 znaków, logi, testy, CSV/JSON, buildy)? Podaj konkretne pliki i komendy.
2. **Dane wrażliwe.** Czy Claude może zobaczyć klucze, hasła, dane klientów albo inne dane, których nie wolno wysłać do TypeSafe/OpenRouter? Wypisz ścieżki. Klucze blokuje `jev-guard`; przy danych klientów utwórz plik `.jev-off` albo sprawdź, czy `jev-guard` wyłączył Jev w `.claude/settings.local.json`.
3. **Runtime.** Czy projekt ma własną pętlę agenta LLM z narastającymi wynikami narzędzi? Czy biblioteka `compact()` ma tam sens i czy jest DPA z dostawcą Jev?
4. **Kolizje.** Czy projekt ma własne hooki `session.compact` / `turn.complete`? Czy wołają `next(e)`?
5. **Werdykt** ★★★ / ★★ / ★ / ✗, forma (plugin / biblioteka / nic), warunki.

## Część B: decyzje, które może przejąć Jev

WHAT JEV IS: Jev (TypeSafe's System One model) doesn't write text. You send it the situation plus questions. Each question is yes/no, pick-one-from-a-list, or a score, with instructions and criteria. It answers in about 0.2-0.5 s with a probability for every option, for a fraction of a cent. It is good at judgment calls on messy text. It is the wrong tool for anything that needs words out, for fixed rules (plain code wins), and for irreversible actions on its own.

1. Read what is built here: skills, slash commands, hooks, scripts, automations, agents, scheduled jobs, prompts. Never open secrets (.env, credentials, tokens, keys).
2. Find every decision hiding in there: any place a model, a person, or brittle keyword code answers "which one?", "is this relevant?", "should I...?", "how good is this?" or "is this done?".
3. For each one, fill in:
   - Where: file and line
   - The decision, in one sentence
   - Who decides today (which LLM / me / keyword code) and roughly how often it runs
   - Question type: yes/no, choice (list the options and ALWAYS include a "none of these" option), or score (say what each end of the scale means)
   - Draft criteria: 2-4 sentences Jev gets with every call
   - Threshold: how sure Jev must be to act alone, and what takes over below it (usually whatever decides today)
   - What the LLM still does: the writing, the tool calls, anything irreversible
   - The win: speed, cost, or both, with a rough number
4. Skip anything that must produce text, anything plain code already handles, and anything irreversible without a check.
5. Rank by (how often it runs x how slow or expensive it is today). Give the top 5 as a table, then the full list. For #1, write the actual Jev call (state + questions as JSON).

## Na koniec

- Wyniki zapisz w `.claude/jev/AUDYT.md`.
- Wklej `.claude/jev/CLAUDE-jev.md` do `CLAUDE.md` tego projektu i uzupełnij status oraz powód. Ta sekcja oznacza, że audyt jest zrobiony (`jev-start` przestaje o nim przypominać).
