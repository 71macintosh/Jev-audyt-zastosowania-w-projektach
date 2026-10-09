# Audyt: które decyzje może przejąć Jev

Stan na **2026-10-09**. Przeczytane: `Kaucja`, `animacje-java-script` (skill `animate` + Studio), `Mods` (3 mody, 7 agentów), `Automatyzacja-dla-firm`, `HUD_bot`, `auto_bot`, `crypto-lab` oraz 4 Routines na koncie.
Nie przeczytane: `Trading-bot` (sesja nie dostała dostępu; jego Routine YouTube jest uwzględniona na podstawie promptu), `AI` (puste).
Plików z sekretami (`.env`, `klucze.txt`, `Klucze.bat`) nie otwierano.

Pliki w `Kaucja` są zminifikowane (jedna funkcja = jedna linia), więc numer linii wskazuje funkcję.

## Top 5

Ranking: jak często się uruchamia × ile dziś kosztuje lub trwa.

| # | Gdzie | Decyzja | Kto dziś | Typ | Wygrana |
|---|---|---|---|---|---|
| 1 | `animacje-java-script/studio/studio.html:974` (i `:917`) | Których scen i czy muzyki dotyczy prośba o zmianę | Claude (tier `quick`) przy każdej poprawce; gdy nic nie wskaże, przerabia **wszystkie** sceny (`:979`, `:920`) | tak/nie na scenę + na muzykę + na plan | 10–25 s → 0,3 s; ~$0,03 → <$0,01 za routing i do ~$0,2–0,5 mniej na zbędnych przeróbkach scen |
| 2 | Routine „Analiza YouTube i artykułów”, krok 2 (repo `Trading-bot`) | Którą klatkę z audycji warto obejrzeć | Opus ogląda **każdą** klatkę (Read obrazu), codziennie w dni robocze | tak/nie na klatkę | ~50–70% mniej klatek; kilkadziesiąt tys. tokenów obrazu i ~1 min dziennie mniej |
| 3 | `Kaucja/importer.js:11` | Który produkt z bazy to ta pozycja faktury | Ja/sklep wybieram z 10 kandydatów (ranking po wspólnych słowach), potem opcjonalnie Jev porównuje parę | wybór z 10 + „żaden” | ~10 s ręcznej pracy na pozycję → wstępnie wybrane; 100 pozycji ≈ 15 min mniej na import |
| 4 | `Kaucja/import-core.js:8` | Czy linia faktury to piwo, opakowanie/kaucja, czy coś innego | Regex słów kluczowych (`piwo|beer|lager|…`) | wybór | Mniej pominiętych piw (np. marki bez słowa „piwo” w nazwie) i mniej ręcznego zaznaczania |
| 5 | `Mods/plugins/agents-panel/hooks/register.tsx:78` | Czy po tej turze warto uruchomić któregoś z 7 agentów, i którego | Ja (klikam ▶ run albo zapominam) | wybór z 7 + „żaden” | Podpowiedź po każdej turze za ułamek centa, bez wołania Opusa |

## #1: gotowe wywołanie Jev

Studio dziś woła Claude (`tier: 'quick'`) z całym planem i prośbą. Prosi o JSON z numerami scen, flagą muzyki i **przepisanym planem**. Jev przejmuje sam routing. Claude pisze tylko wtedy, gdy plan naprawdę trzeba zmienić, i tylko sceny wskazane przez Jev.

Endpoint i format jak w `Kaucja/jev.cjs` (OpenRouter `typesafe/jev-1.13`). Przykład dla planu z 4 scenami:

```json
{
  "model": "typesafe/jev-1.13",
  "state": "{\"plan\":{\"title\":\"Historia kawy\",\"duration\":20,\"eras\":[{\"n\":1,\"t0\":0,\"t1\":5,\"title\":\"Etiopia\",\"opis\":\"Pasterz Kaldi i kozy jedzące czerwone owoce\",\"tag\":\"IX wiek\",\"caption\":\"Legenda o Kaldim\"},{\"n\":2,\"t0\":5,\"t1\":10,\"title\":\"Jemen\",\"opis\":\"Sufi parzą kawę w nocy\",\"tag\":\"XV wiek\",\"caption\":\"Pierwsze napary\"},{\"n\":3,\"t0\":10,\"t1\":15,\"title\":\"Europa\",\"opis\":\"Kawiarnia w Wiedniu\",\"tag\":\"1683\",\"caption\":\"Kawa po oblężeniu\"},{\"n\":4,\"t0\":15,\"t1\":20,\"title\":\"Dziś\",\"opis\":\"Ekspres i kubek na biurku\",\"tag\":\"XXI wiek\",\"caption\":\"2 mld filiżanek dziennie\"}],\"bridges\":[\"czerwony owoc\",\"dzbanek\",\"filiżanka\"]},\"style\":\"akwarela\",\"change_request_pl\":\"Kozy w pierwszej scenie mają być białe, a muzyka spokojniejsza\"}",
  "questions": {
    "scope": {
      "type": "choice",
      "instructions": "The user asked (in Polish) for a change to a short animated video whose plan is in the state. Decide how much of the video the request touches.",
      "criteria": {
        "specific": "The request names or clearly describes specific scenes, objects, captions or the music.",
        "whole_video": "The request is about the whole video: pacing, overall colours, general tone, every scene.",
        "none_of_these": "The request is unclear, contradictory or not a change request; a person should clarify."
      }
    },
    "scene_1": { "type": "noul", "instructions": "The code of scene 1 (Etiopia, 0-5 s) must change to satisfy the request.", "criteria": { "true": "The request mentions something drawn, written or animated in scene 1, or a change to every scene.", "false": "Nothing in the request is visible in scene 1." } },
    "scene_2": { "type": "noul", "instructions": "The code of scene 2 (Jemen, 5-10 s) must change to satisfy the request.", "criteria": { "true": "The request mentions something drawn, written or animated in scene 2, or a change to every scene.", "false": "Nothing in the request is visible in scene 2." } },
    "scene_3": { "type": "noul", "instructions": "The code of scene 3 (Europa, 10-15 s) must change to satisfy the request.", "criteria": { "true": "The request mentions something drawn, written or animated in scene 3, or a change to every scene.", "false": "Nothing in the request is visible in scene 3." } },
    "scene_4": { "type": "noul", "instructions": "The code of scene 4 (Dziś, 15-20 s) must change to satisfy the request.", "criteria": { "true": "The request mentions something drawn, written or animated in scene 4, or a change to every scene.", "false": "Nothing in the request is visible in scene 4." } },
    "music": { "type": "noul", "instructions": "The music or sound must change to satisfy the request.", "criteria": { "true": "The request mentions music, tempo, mood of the sound, sound effects or silence.", "false": "The request is only about what is seen." } },
    "plan_text": { "type": "noul", "instructions": "The plan's text (titles, descriptions, tags, captions, characters or bridges) must be rewritten, not only the drawing code.", "criteria": { "true": "The request changes what a scene shows or says: a new object, caption, fact, character or bridge.", "false": "The request only changes how existing things look or move (colour, size, speed, style) or the music." } }
  }
}
```

Dla tego przykładu oczekiwany wynik: `scope=specific`, `scene_1` wysoko, `scene_2–4` nisko, `music` wysoko, `plan_text` nisko. Studio przerabia tylko scenę 1 i muzykę, bez wywołania routera Claude.

**Progi:**
- `scope = none_of_these` z prawdopodobieństwem ≥ 0,5 → zapytaj użytkownika, nic nie generuj.
- Każde `scene_k` i `music` ≥ 0,85 → przerób; ≤ 0,15 → nie ruszaj. Jeśli **którakolwiek** wartość jest pomiędzy, wołaj dzisiejszy router Claude (bez zmian).
- `plan_text` ≤ 0,2 → plan zostaje, Claude pisze tylko kod wskazanych scen. Powyżej → Claude przepisuje plan, ale dostaje listę scen od Jev.

**Co dalej robi Claude:** kod scen, muzykę, przepisanie planu, naprawy błędów.

**Przeszkoda do rozwiązania przed wdrożeniem:** Studio działa jako Artifact w przeglądarce. Klucz Jev nie może trafić do strony. Potrzebny jest pośrednik po stronie serwera, jak `/api/jev-match` w `Kaucja/import-api.cjs`, a strona musi mieć prawo go wołać.

## Pełna lista

### 1. Studio: routing prośby o zmianę (`studio/studio.html:974`, notatki ogólne do storyboardu `:917`)
- **Decyzja:** których scen, czy muzyki i czy tekstu planu dotyczy prośba użytkownika.
- **Kto dziś:** Claude `quick` (Sonnet 5.5 według `:282`), przy każdej poprawce i każdej notatce ogólnej do storyboardu. Kilka razy na animację.
- **Typ:** tak/nie na każdą scenę, na muzykę i na tekst planu, plus wybór `specific / whole_video / none_of_these`.
- **Kryteria:** jak w JSON wyżej.
- **Próg:** ≥ 0,85 / ≤ 0,15 na każde pytanie; pomiędzy → dzisiejszy router.
- **LLM dalej:** kod scen, muzyka, przepisanie planu.
- **Wygrana:** router 10–25 s (wypisuje cały plan) → 0,3 s. Do tego mniej przeróbek wszystkich scen „na wszelki wypadek”. Jedna scena według kalkulatora Studia (`:310–325`) to kilka do kilkunastu centów.

### 2. Routine YouTube: które klatki obejrzeć (prompt Routine, krok 2; kod w `Trading-bot`, nieprzeczytany)
- **Decyzja:** czy klatka pokazuje wykres, poziom lub tabelę, o których mowa w transkrypcie.
- **Kto dziś:** Opus czyta **każdą** klatkę jako obraz. Codziennie w dni robocze, kilkadziesiąt klatek na audycję.
- **Typ:** tak/nie na klatkę (pytanie o fragment transkryptu ±30 s wokół minuty klatki z `czasy.txt`).
- **Kryteria:** „The transcript around this moment discusses a specific instrument's chart, price level, table or indicator that is likely shown on screen. Talk about macro, news or the host's opinion without a visible chart is false. Intros, ads and talking heads are false.”
- **Próg:** ≥ 0,3 → obejrzyj (pominięcie wykresu boli bardziej niż zbędny odczyt). Brak `czasy.txt` → oglądaj wszystkie, jak dziś.
- **LLM dalej:** całą analizę, linie `SEDNO`/`OBSERWACJA`, commit.
- **Wygrana:** koszt i czas. ~50–70% klatek mniej, czyli kilkadziesiąt tys. tokenów obrazu i ~1 min dziennie.
- **Warunek:** klucz Jev w środowisku Routine i dostęp sieci do `openrouter.ai`.

### 3. Kaucja: który produkt z bazy to pozycja faktury (`importer.js:11`)
- **Decyzja:** która z 10 kandydatek (ranking po wspólnych słowach) to ta sama butelka.
- **Kto dziś:** sklep wybiera ręcznie, potem może kliknąć „Porównaj nazwy z Jev” (jedna para na klik). Każda pozycja przy każdym imporcie.
- **Typ:** wybór: 10 nazw z bazy + `none_of_these`.
- **Kryteria:** „Same beer, same variant (jasne/ciemne, niepasteryzowane, 0%), same volume and packaging (butelka zwrotna/bezzwrotna, puszka). Brand alone is not enough. Different volume or packaging means a different product.” Te same kryteria co dziś w `jev.cjs`.
- **Próg:** ≥ 0,8 → wstępnie wybierz w liście (człowiek dalej zatwierdza import). Poniżej → pusta lista jak dziś. `none_of_these` ≥ 0,6 → podpowiedź „nowy produkt, odczytaj EAN z butelki”.
- **LLM dalej:** nic. Zatwierdzenie i zapis bazy zostają przy człowieku (`merge` wymaga jawnego zaznaczenia).
- **Wygrana:** jedno wywołanie zamiast ręcznego wyboru i kliknięć par. ~10 s na pozycję.
- **Zgoda:** do Jev idą tylko nazwy produktów, w zakresie istniejącej zgody `jev-consent`.

### 4. Kaucja: rodzaj linii faktury (`import-core.js:8`)
- **Decyzja:** czy linia to piwo, opakowanie/kaucja/skrzynka, czy coś innego (nagłówek, adres, inny towar).
- **Kto dziś:** regex `piwo|pivo|beer|lager|budvar|pils|porter|ipa|lezak` zaznacza linię, drugi regex dodaje podpowiedź „opakowanie”. Każda linia każdego PDF lub zdjęcia faktury.
- **Typ:** wybór `beer / packaging_or_deposit / other_product / none_of_these` (nie pozycja towarowa).
- **Kryteria:** „A line of a Polish shop's purchase invoice, after OCR. beer: a beer or cider product line, even if only a brand is written (Tyskie, Perła, Kozel). packaging_or_deposit: crates, pallets, returnable bottle deposit, kaucja. other_product: any other goods. none_of_these: headers, totals, addresses, seller or buyer data.”
- **Próg:** ≥ 0,8 → zaznacz lub odznacz automatycznie. Poniżej → wynik regexu jak dziś.
- **LLM dalej:** nic.
- **Wygrana:** mniej pominiętych piw (marki bez słowa „piwo”), mniej ręcznego zaznaczania.
- **Warunek prywatności:** README obiecuje „faktury nie są wysyłane do AI”. Wysyłać tylko linie bez NIP, adresu i danych kontrahenta (wyciąć regexem przed wywołaniem), zmienić tekst zgody i README. Bez tego: ✗.

### 5. Mods: czy i którego agenta uruchomić po turze (`plugins/agents-panel/hooks/register.tsx:78`)
- **Decyzja:** czy po tej turze warto uruchomić `code-reviewer`, `test-writer`, `docs-writer`, `security-auditor`, `perf-profiler`, `dependency-doctor` lub `release-notes`.
- **Kto dziś:** ja, ręcznie. Hook `turn.complete` biegnie po każdej turze.
- **Typ:** wybór z 7 agentów + `none_of_these`.
- **Kryteria:** opisy agentów z ich frontmatteru plus: „Suggest an agent only when the last turn produced work it is meant for: code-reviewer after code edits, test-writer after new code paths, docs-writer after changed commands or options, security-auditor after auth, input handling or secrets code, dependency-doctor after manifest changes, release-notes after a tag. Questions, reading and planning turns are none_of_these.”
- **Próg:** ≥ 0,7 → podświetl przycisk ▶ run w panelu lub pokaż toast. **Nigdy nie uruchamiaj sam**: `test-writer` i `docs-writer` edytują pliki.
- **LLM dalej:** całą pracę agenta.
- **Wygrana:** podpowiedź za ułamek centa po każdej turze, bez pytania Opusa.

### 6. Mods: czy to dobry moment na handoff (`plugins/session-bar/hooks/register.tsx:144`)
- **Decyzja:** czy praca jest w naturalnym punkcie przerwy (zadanie skończone, zaraz nowy temat), a kontekst jest wysoko.
- **Kto dziś:** stały próg ostrzeżenia 40% kontekstu + ja.
- **Typ:** tak/nie.
- **Kryteria:** „The last turns finished a task (tests pass, commit made, question answered) and the next request starts a different topic, or the context is above 60%. Mid-debugging or mid-edit is false.”
- **Próg:** ≥ 0,8 → podświetl przycisk Handoff. Poniżej → jak dziś.
- **LLM dalej:** pisze `HANDOFF.md`.
- **Wygrana:** mniej zgubionych sesji. Szczególnie ważne przy `jev-compaction-plus`, który nie przetrwa `--resume`.

### 7. Kaucja: która linia OCR to nazwa piwa (`enrich.js:41`)
- **Decyzja:** która z linii z OCR przedniej etykiety jest nazwą produktu.
- **Kto dziś:** heurystyka: czarna lista słów (`skład|kcal|www|…`) i ranking wysokość × pewność OCR. Przy każdej butelce dodawanej przez sklep.
- **Typ:** wybór z do 8 linii + `none_of_these`.
- **Kryteria:** „The brand and product name a shopper would say, e.g. 'Żywiec Jasne Pełne'. Not ingredients, slogans, addresses, volume, alcohol content or legal text.”
- **Próg:** ≥ 0,7 → wpisz w pole nazwy (człowiek i tak potwierdza). Poniżej → heurystyka.
- **LLM dalej:** nic.
- **Wygrana:** mniej poprawiania nazwy, kilka sekund na butelkę.

### 8. Kaucja: czy etykieta mówi o kaucji (`enrich.js:33`, `import-core.js:6`)
- **Decyzja:** czy tekst etykiety lub faktury mówi „zwrotna”, „bezzwrotna”, czy nic.
- **Kto dziś:** regexy PL/CZ/DE (`zálohovaný obal`, `pfandfrei`, `bez kaucji`…).
- **Typ:** wybór `returnable / non_returnable / no_information / none_of_these` (nieczytelne).
- **Kryteria:** „Only an explicit statement about deposit or returnability of this container counts. Recycling symbols and 'recyclable' do not.”
- **Próg:** ≥ 0,85 → podpowiedź. To wyłącznie podpowiedź: status zwrotu nadal ustala CSV sklepu.
- **LLM dalej:** nic.
- **Wygrana:** inne języki i literówki z OCR bez dopisywania regexów. Mały wolumen.

### 9. animate: wybór formatu filmu (`plugins/animate/skills/animate/SKILL.md:32`)
- **Decyzja:** który format z `grammar/FORMATS.md` pasuje do tematu.
- **Kto dziś:** Opus, raz na film, po przeczytaniu `FORMATS.md`.
- **Typ:** wybór z formatów F1…Fn + `none_of_these`.
- **Kryteria:** krótki opis „silnika fabuły” każdego formatu z `FORMATS.md`.
- **Próg:** ≥ 0,7 → Opus dostaje format jako propozycję. Poniżej → Opus wybiera jak dziś. Użytkownik i tak zatwierdza na etapie 1.
- **LLM dalej:** tabela beatów, sprawdzenie faktów, wszystko inne.
- **Wygrana:** mała (raz na film); głównie krótszy kontekst Opusa.

### 10. Kaucja: mapowanie kolumn CSV (`import-core.js:4`)
- **Decyzja:** która kolumna to EAN, nazwa, zwrotność, aktywność.
- **Kto dziś:** lista aliasów + ręczna korekta.
- **Typ:** wybór na każde pole: nagłówki CSV + `none_of_these`. Do Jev nagłówki i 3 przykładowe wiersze.
- **Próg:** ≥ 0,9 → ustaw. Poniżej → aliasy jak dziś.
- **Wygrana:** mała; importy CSV są rzadkie, a aliasy zwykle wystarczą.

### 11. Kaucja: dopasowanie OCR przodu do butelki i kraj (`front-recognition.js:4`, `:11`, `:24`)
- Regexy i „wszystkie słowa muszą wystąpić”.
- `app.js` ładuje ten plik (`:172`), ale skaner klienta korzysta dziś z porównania obrazu (`/api/label-match`, `app.js:62–88`), a funkcja `scan()` nie jest nigdzie wołana. **Na razie pominąć.** Wraca na listę, jeśli OCR przodu wróci do użycia.

## Zaprojektowane, jeszcze niezbudowane (`Automatyzacja-dla-firm`)

Wszystkie projekty mają status „koncepcja”, więc dziś uruchamiają się zero razy. Warto je od razu projektować z Jev zamiast „klasyfikacji LLM”. Jev u klienta wymaga DPA z TypeSafe/OpenRouter (wymóg z `00-wspolna-infrastruktura`).

| Gdzie | Decyzja | Typ | LLM dalej |
|---|---|---|---|
| `28-monitoring-informacji-branzowych/README.md:11` | Czy news jest istotny dla profilu firmy (dziś zaplanowane: filtr słów → LLM → próg) | wynik 0–1 (0 = nie dotyczy firmy, 1 = wymaga reakcji) | streszczenie alertu |
| `05-agent-korespondencji/README.md:11` | Kategoria, priorytet, dział maila | wybór (kategorie + `none_of_these`) ×3 | podsumowanie, szkic odpowiedzi |
| `30-analiza-nastrojow-zgloszen/README.md:11` | Nastrój −2…+2, temat, pilność, ryzyko odejścia | wynik + wybór | alert i raport |
| `16-ratowanie-i-scoring-leadow/README.md:12` | Dopasowanie leada do ICP, pilność | wynik (0 = poza profilem, 1 = idealny) | odpowiedź do leada |
| `03-agent-dokumentow/README.md:12,14` | Typ dokumentu; „czytać całość / wystarczy streszczenie” | wybór; tak/nie | streszczenie |
| `15-dopasowanie-faktur-do-zamowien/README.md:12` | Czy nazwa pozycji faktury = pozycja PO | wybór z kandydatów + `none_of_these` | nic; płatność zatwierdza człowiek |
| `02-agent-rekrutacyjny/README.md:12–13` | Spełnienie każdego wymagania z ogłoszenia | tak/nie na wymaganie | uzasadnienie; **decyzja zawsze u rekrutera** (AI Act: wysokie ryzyko) |
| `09-monitoring-rozmow-sprzedazowych/README.md:12` | Czy padło każde kryterium karty oceny | tak/nie na kryterium | cytaty i raport |

## Pominięte i dlaczego

| Miejsce | Powód |
|---|---|
| `HUD_bot` `hud/verdict.py`, bramki | Stałe reguły na liczbach; kod wygrywa. Werdykt ma być jednym z dwóch słów z podanym powodem. |
| `auto_bot` `bot/bezpieczniki.py`, `bot/regula.py`, broker | Stałe reguły i nieodwracalne zlecenia. `CLAUDE.md`: „bezpieczniki są w kodzie, nie w promptcie”. |
| `crypto-lab` (lejek, sweep, permutacje) | Statystyka z góry zadeklarowana; osąd modelu podważyłby test. |
| `crypto-lab/scripts/zrodla.py` | Decyzja po rozszerzeniu i rozmiarze pliku; kod wystarcza. |
| `Kaucja/core.js` `lookup`, `validEAN` | Suma kontrolna i odczyt z bazy; kod. |
| Routine „Kurs USD/PLN do Studia animacji” | Decyzja „czy jest nowszy kurs” to porównanie dat. Uwaga poza Jev: cała Routine mogłaby być zwykłym skryptem bez sesji Claude. |
| Routine „Nocne testy Kaucji” (wyłączona) | Zaliczone/niezaliczone daje `node`. |
| Routine „Mini bot: 2 tygodnie odmów stopów” | Progi są stałe (1 na 20, 1 dzień w miesiącu); kod. Reszta to pisanie. |
| Routine YouTube: „czy już przeanalizowane”, „czy spółka w puli” | Sprawdzenie pliku i słownika `POOL`; kod. |
| Agenci w `Mods/.claude/agents/` (praca w środku) | Wynik to tekst lub edycje. Wybór agenta jest w punkcie 5. |
| `Kaucja/visual-*.cjs` | Dopasowanie obrazów; Jev pracuje na tekście. |
| `jev-compaction-plus` | Już używa Jev. |
