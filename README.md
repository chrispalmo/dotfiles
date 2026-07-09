# .files

Personal macOS dotfiles. Work through the sections below in order on a fresh Mac.

## git + ssh setup

```
git config --global user.name "chrispalmo"
git config --global user.email "34981948+chrispalmo@users.noreply.github.com"

ssh-keygen -t ed25519 -C "optional_comment"
pbcopy < ~/.ssh/id_ed25519.pub

# click `New SSH key` and paste the public key
open "https://github.com/settings/keys"
```

## clone this repo

```
git clone git@github.com:chrispalmo/.files.git ~/.files
```

## install deps

```
~/.files/install-deps.sh
```

Then open a new terminal (pick up brew / pipx / n paths).

## other apps and settings

```
# OS essentials
open "https://apps.apple.com/au/app/moom/id419330170?mt=12"
open "https://cursor.com/download"
open "https://www.google.com/chrome/"

brew install --cask karabiner-elements
brew install --cask meetingbar

# storage
open "https://www.dropbox.com/install"
open "https://support.google.com/a/users/answer/13022292?hl=en"

# media
open "https://www.spotify.com/au/download/mac/"

# torrents
open "https://transmissionbt.com/download.html"
```

## import terminal profile

1. open Terminal
2. `Terminal` → `settings` → `profiles` → `(...)` → `import` →
   `.terminal/terminal-profile.terminal` (Press `⌘ + Shift + .` to see hidden files)

## install

_⚠️ if Moom is installed, quit it before running. Import is skipped when Moom is not installed._

```
~/.files/install.sh
```

`install.sh` is idempotent. Symlinks dotfiles, imports Moom (when installed), bootstraps vim plugins, creates `.keys`/`.scratch`, sets screenshot folder, and clones [skills](https://github.com/chrispalmo/skills) into `~/dev/skills` then runs its installer (links into `~/.cursor/skills/`).

## after install

1. Cursor → **Shell Command: Install 'cursor' command in PATH** (VS Code too if you use `code`)
2. Paste each `*.md` from `.config/cursor/rules/` into **Cursor Settings → Rules → User Rules**
3. Clone [agent-chats](https://github.com/chrispalmo/agent-chats) and run `./scripts/install.sh` for hooks
4. Edit hardcoded paths if needed (Dropbox, Google Drive, `DEV_ROOT` in `.zshrc` / tmuxinator)
5. Set `AUTO_TMUX=1` to auto-start tmux outside Terminal/iTerm; uncomment TPM in `.tmux.conf` if wanted

## Cursor

Symlinked by `install.sh`:

- `.config/cursor/User/settings.json` → `~/Library/Application Support/Cursor/User/settings.json`
- `.config/cursor/User/keybindings.json` → `~/Library/Application Support/Cursor/User/keybindings.json`
- `.config/cursor/commands/` → `~/.cursor/commands/`

Skills: [skills](https://github.com/chrispalmo/skills) at `~/dev/skills` — cloned and installed by `install.sh`.
User rules: markdown in `.config/cursor/rules/` — paste into Cursor manually.
Hooks: [agent-chats](https://github.com/chrispalmo/agent-chats) repo, not dotfiles.
