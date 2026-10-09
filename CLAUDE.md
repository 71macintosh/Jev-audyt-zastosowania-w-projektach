# CLAUDE.md

## Kompakcja Jev

Status w tym projekcie: **włączona** (audyty: długie odczyty kodu innych repozytoriów). Audyt: `.claude/jev/AUDYT.md`.

- Toast `kept … no summary` oznacza, że stare wyniki narzędzi trafiły do `.jev-drawer/<czas>/`. Gdy brakuje starego wyniku (testu, logu, pliku), najpierw przeczytaj `INDEX.md` w szufladzie, dopiero potem uruchamiaj ponownie. `/drawer` pokazuje i czyści szufladę.
- Przed zamknięciem długiej sesji zrób Handoff (`/handoff`), bo kompakcja Jev nie przetrwa `--resume`.
- Nie czytaj w sesji plików z kluczami ani danych klientów: ich podgląd trafiłby do TypeSafe/OpenRouter. `jev-guard` blokuje typowe pliki z kluczami; przy danych klientów utwórz `.jev-off`.
