# Claude Code — Sync Sessions Across Accounts

The Claude desktop app keeps a separate Code-tab session list for each account. If you switch accounts, your sessions seem to disappear. These scripts copy the sessions between every account signed in on the same computer, so you keep your sessions whichever account you use.

| File | Platform |
| --- | --- |
| `Sync Claude Sessions.command` | macOS |
| `Sync Claude Sessions.cmd` + `Sync-ClaudeSessions.ps1` | Windows (keep both files in the same folder) |

## Before you start

1. Sign in to the Claude desktop app with **each** account you want to sync.
2. Open the **Code** tab at least once on each account. This creates that account's session folder.

## macOS

1. Download `Sync Claude Sessions.command`.
2. Double-click it. If macOS says the file can't be opened, run this command in Terminal, then double-click it again:

   ```bash
   xattr -d com.apple.quarantine ~/Downloads/"Sync Claude Sessions.command"
   chmod +x ~/Downloads/"Sync Claude Sessions.command"
   ```

3. Reopen Claude and sign in with the account you want to use.

To preview the changes without copying anything:

```bash
~/Downloads/"Sync Claude Sessions.command" --dry
```

## Windows

1. Download `Sync Claude Sessions.cmd` and `Sync-ClaudeSessions.ps1` into the same folder.
2. Double-click `Sync Claude Sessions.cmd`. If SmartScreen warns you, choose **More info → Run anyway**.
3. Reopen Claude and sign in with the account you want to use.

To preview the changes, run `"Sync Claude Sessions.cmd" --dry` from Command Prompt in that folder.

> The Windows version assumes sessions are stored in `%APPDATA%\Claude\claude-code-sessions`. If the folder isn't found, the script stops without changing anything.

## What the script does

1. Finds every account folder under the Claude session folder:
   - macOS: `~/Library/Application Support/Claude/claude-code-sessions/<org-id>/<account-id>`
   - Windows: `%APPDATA%\Claude\claude-code-sessions\<org-id>\<account-id>`
2. Asks to quit the Claude app if it's running, because the app could overwrite files during the sync.
3. Backs up the whole session folder to `~/.claude-session-backups` (`%USERPROFILE%\.claude-session-backups` on Windows). Only the 10 most recent backups are kept.
4. Merges every account's sessions into the first account, then copies the result to all other accounts. When the same file exists in two places, the newer copy wins. Nothing is deleted.
5. Prints the number of sessions in each account.

## Restoring a backup

Quit Claude, then extract a backup over the session folder:

- macOS: `tar -xzf ~/.claude-session-backups/sessions-<timestamp>.tgz -C ~/Library/Application\ Support/Claude/claude-code-sessions`
- Windows: extract `sessions-<timestamp>.zip` into `%APPDATA%\Claude\claude-code-sessions`, replacing existing files.

## Notes

- Only the session list is synced. Each account's sign-in, settings and usage stay separate.
- Run the script again whenever you want to bring the accounts back in sync.
- This is an unofficial script that relies on the app's internal folder layout, which may change in future versions.
