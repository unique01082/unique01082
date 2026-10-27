#!/bin/zsh
# Sync the Claude Code session list (desktop app) across every account
# that has signed in on this Mac. Each account's folder is found automatically.
# Usage:
#   Double-click this file                     # sync all accounts (newer file wins)
#   ./Sync\ Claude\ Sessions.command --dry     # preview changes only
set -euo pipefail

BASE="$HOME/Library/Application Support/Claude/claude-code-sessions"
BACKUP_DIR="$HOME/.claude-session-backups"

pause() { echo; read -k1 "?Press any key to close..." || true; }
trap pause EXIT

DRY=""
[[ "${1:-}" == "--dry" ]] && DRY="--dry-run"

[[ -d "$BASE" ]] || { echo "Session folder not found: $BASE"; exit 1; }

# Each account is an <org-id>/<account-id> folder inside BASE
DIRS=("$BASE"/*/*(N/))
if (( ${#DIRS} < 2 )); then
  echo "Found only ${#DIRS} account(s). Sign in to the Claude app with your second account"
  echo "(open the Code tab at least once), then run this script again."
  exit 1
fi

echo "Found ${#DIRS} accounts:"
for i in {1..${#DIRS}}; do
  echo "  Account $i: ${DIRS[$i]#$BASE/} ($(ls "${DIRS[$i]}" | grep -c '^local_' || true) sessions)"
done
echo

# The app must be closed, or it may overwrite files during the sync
if [[ -z "$DRY" ]] && pgrep -xq "Claude"; then
  read "ans?The Claude app is running. Quit it to sync? [y/N] "
  [[ "$ans" == [yY] ]] || { echo "Cancelled."; exit 1; }
  osascript -e 'quit app "Claude"'
  while pgrep -xq "Claude"; do sleep 1; done
fi

if [[ -z "$DRY" ]]; then
  mkdir -p "$BACKUP_DIR"
  ts=$(date +%Y%m%d-%H%M%S)
  tar -czf "$BACKUP_DIR/sessions-$ts.tgz" -C "$BASE" .
  # keep only the 10 most recent backups
  ls -t "$BACKUP_DIR"/sessions-*.tgz | tail -n +11 | while read -r f; do rm -f "$f"; done
  echo "Backup: $BACKUP_DIR/sessions-$ts.tgz"
fi

# Merge everything into account 1, then copy account 1 out to the others
HUB="${DIRS[1]}"
for d in "${DIRS[@]:1}"; do
  echo "== ${d#$BASE/} -> Account 1"
  rsync -a --update --itemize-changes $DRY "$d/" "$HUB/"
done
for d in "${DIRS[@]:1}"; do
  echo "== Account 1 -> ${d#$BASE/}"
  rsync -a --update --itemize-changes $DRY "$HUB/" "$d/"
done

echo
for i in {1..${#DIRS}}; do
  echo "Account $i: $(ls "${DIRS[$i]}" | grep -c '^local_' || true) sessions"
done
[[ -z "$DRY" ]] && echo "Done. Reopen the Claude app and sign in with the account you want to use."
