#!/usr/bin/env bash
# Instaluje komplet Jev dla wszystkich projektów: ustawienia globalne Claude Code
# (~/.claude/settings.json) i mody z marketplace 71macintosh/Mods.
#
#   bash instalacja/instaluj.sh            # macOS / Linux, pyta o klucz
#   bash instalacja/instaluj.sh --chmura   # skrypt startowy środowiska w chmurze, bez pytań
#
# Klucz: zmienna TYPESAFE_API_KEY (TypeSafe albo OpenRouter sk-or-...). W chmurze
# ustaw ją w zmiennych środowiska; skrypt nie zapisuje jej wtedy do pliku.
set -u

CHMURA=0
[ "${1:-}" = "--chmura" ] && CHMURA=1
DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$DIR/settings.json"
PLUGINS="jev-compaction-plus jev-guard drawer jev-start context-bar session-bar"
mkdir -p "$DIR"

KEY=""
if [ -z "${TYPESAFE_API_KEY:-}" ] && [ "$CHMURA" = 0 ] && [ -t 0 ]; then
  printf 'Klucz Jev (TypeSafe albo OpenRouter sk-or-...), Enter = pomiń: '
  read -rs KEY
  echo
fi

MERGE='
import json, os, sys
path, key = sys.argv[1], sys.argv[2]
plugins = sys.argv[3].split()
cur = {}
if os.path.exists(path) and open(path, encoding="utf-8").read().strip():
    try:
        cur = json.load(open(path, encoding="utf-8"))
    except Exception:
        sys.exit("settings.json nie jest poprawnym JSON-em: popraw go i uruchom ponownie.")
if not isinstance(cur, dict):
    sys.exit("settings.json nie jest obiektem JSON.")
env = cur.setdefault("env", {})
env.setdefault("CLAUDE_CODE_ENABLE_FUNCTION_HOOKS", "1")
if key:
    env["TYPESAFE_API_KEY"] = key
cur.setdefault("extraKnownMarketplaces", {}).setdefault(
    "mods", {"source": {"source": "github", "repo": "71macintosh/Mods"}})
enabled = cur.setdefault("enabledPlugins", {})
for p in plugins:
    enabled.setdefault(p + "@mods", True)
tmp = path + ".tmp"
open(tmp, "w", encoding="utf-8").write(json.dumps(cur, indent=2, ensure_ascii=False) + "\n")
os.replace(tmp, path)
'
if command -v python3 >/dev/null 2>&1; then
  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.przed-jev"
  python3 -I -c "$MERGE" "$SETTINGS" "$KEY" "$PLUGINS" || exit 1
  echo "Zapisano ustawienia globalne: $SETTINGS"
else
  echo "Brak python3: dopisz ręcznie do $SETTINGS zawartość szablony/settings.user.json." >&2
  exit 1
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin marketplace add 71macintosh/Mods >/dev/null 2>&1 || true
  for p in $PLUGINS; do
    if claude plugin install "$p@mods" --scope user >/dev/null 2>&1; then echo "  zainstalowano $p"
    else echo "  $p: nie udało się teraz (zainstaluje się przy starcie Claude Code z ustawień)"; fi
  done
else
  echo "Brak polecenia claude: mody zainstalują się z ustawień przy następnym starcie Claude Code."
fi

if [ -z "${TYPESAFE_API_KEY:-}" ] && [ -z "$KEY" ]; then
  echo "Uwaga: brak klucza TYPESAFE_API_KEY. Bez niego każda kompakcja wraca do wbudowanej."
fi
echo "Gotowe. Nowe sesje Claude Code mają kompakcję Jev, jev-guard, /drawer i jev-start."
