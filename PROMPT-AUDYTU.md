# Prompt audytu: jev-compaction-plus w nowym projekcie

Wklej to do sesji Claude Code w nowym repozytorium (albo przy nowym skillu, skrypcie, automatyzacji):

---

Sprawdź, czy w tym projekcie stosować [jev-compaction-plus](https://github.com/cth9191/jev-compaction-plus).
Kryteria i wcześniejsze wyniki są w `71macintosh/Jev-audyt-zastosowania-w-projektach/AUDYT.md`.

1. **Profil sesji.** Czy praca tutaj generuje duże wyniki narzędzi (pliki > 1500 znaków, logi, testy, CSV/JSON, buildy)? Podaj konkretne pliki i komendy.
2. **Dane wrażliwe.** Czy Claude może w sesji zobaczyć klucze, hasła, dane klientów lub inne dane, których nie wolno wysłać do TypeSafe/OpenRouter? Wypisz ścieżki. Jeśli tak, zaproponuj `permissions.deny` albo wyłączenie pluginu.
3. **Runtime.** Czy projekt ma własną pętlę agenta LLM z narastającymi wynikami narzędzi? Jeśli tak, czy biblioteka `compact()` ma sens i czy jest DPA z dostawcą Jev? Czy kompakcja nie wytnie dowodów potrzebnych do audytu decyzji?
4. **Kolizje.** Czy projekt ma własne hooki `session.compact` / `turn.complete` (np. mody z `71macintosh/Mods`)? Czy wywołują `next(e)`?
5. **Werdykt** w skali ★★★ / ★★ / ★ / ✗, forma (plugin / biblioteka / nic), warunki.
6. Dopisz fragment `szablony/CLAUDE-jev.md` do `CLAUDE.md` tego projektu ze statusem i powodem, a wiersz z werdyktem do tabeli w `AUDYT.md`.

---
