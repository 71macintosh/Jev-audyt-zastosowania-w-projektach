# Instaluje komplet Jev dla wszystkich projektów (Windows): ustawienia globalne
# Claude Code (%USERPROFILE%\.claude\settings.json) i mody z 71macintosh/Mods.
$ErrorActionPreference = 'Stop'
$dir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$path = Join-Path $dir 'settings.json'
$plugins = @('jev-compaction-plus', 'jev-guard', 'drawer', 'jev-start', 'context-bar', 'session-bar')
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$key = ''
if (-not $env:TYPESAFE_API_KEY) {
  $secure = Read-Host 'Klucz Jev (TypeSafe albo OpenRouter sk-or-...), Enter = pomiń' -AsSecureString
  $key = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

function Ensure-Object($parent, [string]$name) {
  if (-not ($parent.PSObject.Properties.Name -contains $name) -or $null -eq $parent.$name) {
    $parent | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  return $parent.$name
}
function Ensure-Value($parent, [string]$name, $value) {
  if (-not ($parent.PSObject.Properties.Name -contains $name)) {
    $parent | Add-Member -NotePropertyName $name -NotePropertyValue $value
  }
}

$settings = [pscustomobject]@{}
if (Test-Path $path) {
  $raw = [IO.File]::ReadAllText($path)
  if ($raw.Trim()) {
    try { $settings = $raw | ConvertFrom-Json } catch {
      Write-Host "settings.json nie jest poprawnym JSON-em: popraw go i uruchom ponownie." -ForegroundColor Red; exit 1
    }
  }
  Copy-Item $path "$path.przed-jev" -Force
}

$envBlock = Ensure-Object $settings 'env'
Ensure-Value $envBlock 'CLAUDE_CODE_ENABLE_FUNCTION_HOOKS' '1'
if ($key) { $envBlock | Add-Member -NotePropertyName 'TYPESAFE_API_KEY' -NotePropertyValue $key -Force }
$markets = Ensure-Object $settings 'extraKnownMarketplaces'
Ensure-Value $markets 'mods' ([pscustomobject]@{ source = [pscustomobject]@{ source = 'github'; repo = '71macintosh/Mods' } })
$enabled = Ensure-Object $settings 'enabledPlugins'
foreach ($p in $plugins) { Ensure-Value $enabled "$p@mods" $true }

# UTF-8 bez BOM: Claude Code czyta settings.json jako czysty JSON.
[IO.File]::WriteAllText($path, ($settings | ConvertTo-Json -Depth 20), (New-Object Text.UTF8Encoding $false))
Write-Host "Zapisano ustawienia globalne: $path"

if (Get-Command claude -ErrorAction SilentlyContinue) {
  & claude plugin marketplace add 71macintosh/Mods *> $null
  foreach ($p in $plugins) {
    & claude plugin install "$p@mods" --scope user *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "  zainstalowano $p" }
    else { Write-Host "  ${p}: nie udało się teraz (zainstaluje się przy starcie Claude Code z ustawień)" }
  }
} else {
  Write-Host 'Brak polecenia claude: mody zainstalują się z ustawień przy następnym starcie Claude Code.'
}
if (-not $env:TYPESAFE_API_KEY -and -not $key) {
  Write-Host 'Uwaga: brak klucza TYPESAFE_API_KEY. Bez niego każda kompakcja wraca do wbudowanej.' -ForegroundColor Yellow
}
Write-Host 'Gotowe. Nowe sesje Claude Code mają kompakcję Jev, jev-guard, /drawer i jev-start.'
