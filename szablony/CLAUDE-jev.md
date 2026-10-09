## Kompakcja Jev (jev-compaction-plus)

Status w tym projekcie: **włączona** / **wyłączona** (powód: …)

- Toast `kept … no summary` oznacza, że stare wyniki narzędzi trafiły do `.jev-drawer/<czas>/`.
  Gdy brakuje starego wyniku (testu, logu, pliku), najpierw przeczytaj `INDEX.md` w szufladzie, dopiero potem uruchamiaj ponownie.
- Przed zamknięciem długiej sesji zapisz `HANDOFF.md`, bo kompakcja Jev nie przetrwa `--resume`.
- Nie czytaj w sesji plików z kluczami ani z danymi klientów: ich podgląd trafiłby do TypeSafe/OpenRouter.
