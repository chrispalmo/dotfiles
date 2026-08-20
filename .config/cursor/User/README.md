# Cursor user settings

Editor settings and keybindings for Cursor on macOS. These files are the source of truth in dotfiles; `install.sh` symlinks them into the app.

## Installed paths

| File in this repo | Symlinked to |
|-------------------|--------------|
| `settings.json` | `~/Library/Application Support/Cursor/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` |

Run `~/.files/install.sh` on a new machine (after cloning to `~/.files`). Existing real files are moved to `*.backup` before the symlink is created.

## Day to day

Edit here (or in Cursor—the symlink means both paths are the same file). Commit and push `~/.files` when you want changes backed up.

## Not the same as VS Code

VS Code uses `~/Library/Application Support/Code/User/`. Changing VS Code settings does **not** update these files. Use [Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync) for VS Code separately, or copy settings manually if you want both editors aligned.

## Cursor-only settings

Keys prefixed with `cursor.` (and other Cursor-specific options) belong in `settings.json` here. VS Code ignores them.

## Optional extension paths

`settings.json` uses `${userHome}` for paths like Dropbox background and `eslint.runtime`. If an extension misbehaves after restore, confirm those files exist—or remove the setting if you no longer use the extension.

## Related config (other folders)

| Location | Purpose |
|----------|---------|
| [`../rules/`](../rules/) | User Rules markdown (paste into Cursor Settings → Rules) |
| [`../commands/`](../commands/) | User slash commands (`~/.cursor/commands/`) |
| [agent-config](https://github.com/chrispalmo/agent-config) | Global Cursor skills and file rules (`~/dev/agent-config` → `~/.cursor/skills/`, `~/.cursor/rules/`), cloned by `install.sh` |
| [agent-chats](https://github.com/chrispalmo/agent-chats) | Global hooks (`~/.cursor/hooks.json`), not in dotfiles |
