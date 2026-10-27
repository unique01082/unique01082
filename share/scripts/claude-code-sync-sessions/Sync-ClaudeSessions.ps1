# Sync the Claude Code session list (desktop app) across every account
# that has signed in on this PC. Each account's folder is found automatically.
# Usage:
#   Double-click "Sync Claude Sessions.cmd"        # sync all accounts (newer file wins)
#   "Sync Claude Sessions.cmd" --dry               # preview changes only
param([string]$Mode = "")
$ErrorActionPreference = "Stop"

$Base = Join-Path $env:APPDATA "Claude\claude-code-sessions"
$BackupDir = Join-Path $env:USERPROFILE ".claude-session-backups"
$Dry = $Mode -eq "--dry"

function Count-Sessions($dir) {
  @(Get-ChildItem -LiteralPath $dir -Filter "local_*" -ErrorAction SilentlyContinue).Count
}

function Sync-Dir($src, $dst) {
  # /E all subfolders, /XO skip files older than the destination (newer file wins)
  $rcArgs = @($src, $dst, "/E", "/XO", "/R:1", "/W:1", "/NJH", "/NJS", "/NDL", "/NP")
  if ($Dry) { $rcArgs += "/L" }
  robocopy @rcArgs | Where-Object { $_.Trim() } | ForEach-Object { "  $($_.Trim())" }
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed (code $LASTEXITCODE): $src -> $dst" }
}

try {
  if (-not (Test-Path -LiteralPath $Base)) { throw "Session folder not found: $Base" }

  # Each account is an <org-id>\<account-id> folder inside Base
  $Dirs = @(Get-ChildItem -LiteralPath $Base -Directory |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Directory } |
    Sort-Object FullName | ForEach-Object { $_.FullName })

  if ($Dirs.Count -lt 2) {
    throw ("Found only $($Dirs.Count) account(s). Sign in to the Claude app with your second account`n" +
           "(open the Code tab at least once), then run this script again.")
  }

  Write-Host "Found $($Dirs.Count) accounts:"
  for ($i = 0; $i -lt $Dirs.Count; $i++) {
    Write-Host ("  Account {0}: {1} ({2} sessions)" -f ($i + 1), $Dirs[$i].Substring($Base.Length + 1), (Count-Sessions $Dirs[$i]))
  }
  Write-Host ""

  # The app must be closed, or it may overwrite files during the sync
  if (-not $Dry -and (Get-Process -Name "Claude" -ErrorAction SilentlyContinue)) {
    $ans = Read-Host "The Claude app is running. Quit it to sync? [y/N]"
    if ($ans -notmatch '^[yY]$') { throw "Cancelled." }
    Get-Process -Name "Claude" -ErrorAction SilentlyContinue | ForEach-Object { [void]$_.CloseMainWindow() }
    $deadline = (Get-Date).AddSeconds(15)
    while ((Get-Process -Name "Claude" -ErrorAction SilentlyContinue) -and (Get-Date) -lt $deadline) { Start-Sleep 1 }
    Get-Process -Name "Claude" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 1
  }

  if (-not $Dry) {
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
    $ts = Get-Date -Format "yyyyMMdd-HHmmss"
    $zip = Join-Path $BackupDir "sessions-$ts.zip"
    Compress-Archive -Path (Join-Path $Base "*") -DestinationPath $zip
    # keep only the 10 most recent backups
    Get-ChildItem -LiteralPath $BackupDir -Filter "sessions-*.zip" |
      Sort-Object LastWriteTime -Descending | Select-Object -Skip 10 | Remove-Item -Force
    Write-Host "Backup: $zip"
  }

  # Merge everything into account 1, then copy account 1 out to the others
  $Hub = $Dirs[0]
  foreach ($d in $Dirs[1..($Dirs.Count - 1)]) {
    Write-Host "== $($d.Substring($Base.Length + 1)) -> Account 1"
    Sync-Dir $d $Hub
  }
  foreach ($d in $Dirs[1..($Dirs.Count - 1)]) {
    Write-Host "== Account 1 -> $($d.Substring($Base.Length + 1))"
    Sync-Dir $Hub $d
  }

  Write-Host ""
  for ($i = 0; $i -lt $Dirs.Count; $i++) {
    Write-Host ("Account {0}: {1} sessions" -f ($i + 1), (Count-Sessions $Dirs[$i]))
  }
  if (-not $Dry) { Write-Host "Done. Reopen the Claude app and sign in with the account you want to use." }
}
catch {
  Write-Host $_.Exception.Message -ForegroundColor Red
}
finally {
  Write-Host ""
  Read-Host "Press Enter to close" | Out-Null
}
