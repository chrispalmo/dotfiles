#!/bin/sh
set -eu

DOTFILES="$HOME/.files"

[ -d "$DOTFILES" ] || {
  echo "Expected dotfiles at $DOTFILES" >&2
  exit 1
}

# Required by shell config (gitignored); create before symlinking shell config
touch "$DOTFILES/.keys" "$DOTFILES/.scratch"

# Ensure target is a symlink to source; backup real files/dirs first.
link_dotfile() {
  _target=$1
  _source=$2
  if [ -L "$_target" ]; then
    _current=$(readlink "$_target")
    [ "$_current" = "$_source" ] && return 0
    rm "$_target"
  elif [ -e "$_target" ]; then
    mv "$_target" "$_target.backup"
  fi
  ln -s "$_source" "$_target"
}

# make symlinks for dotfiles
[ ! -e "$HOME/.config" ] && mkdir "$HOME/.config"

link_dotfile "$HOME/.config/karabiner"        "$DOTFILES/.config/karabiner"
link_dotfile "$HOME/.config/tmuxinator"       "$DOTFILES/.config/tmuxinator"
link_dotfile "$HOME/.config/nvim"             "$DOTFILES/.config/nvim"
link_dotfile "$HOME/.tmux.conf"               "$DOTFILES/.tmux.conf"
link_dotfile "$HOME/.vim"                     "$DOTFILES/.vim"
link_dotfile "$HOME/.vimrc"                   "$DOTFILES/.config/nvim/init.vim"
link_dotfile "$HOME/.zshenv"                  "$DOTFILES/.zshenv"
link_dotfile "$HOME/.zshrc"                   "$DOTFILES/.zshrc"
link_dotfile "$HOME/.gitignore_global"        "$DOTFILES/.gitignore_global"
git config --global core.excludesfile "$HOME/.gitignore_global"

# Cursor (macOS)
CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER"
link_dotfile "$CURSOR_USER/settings.json"    "$DOTFILES/.config/cursor/User/settings.json"
link_dotfile "$CURSOR_USER/keybindings.json" "$DOTFILES/.config/cursor/User/keybindings.json"
[ ! -e "$HOME/.cursor" ] && mkdir "$HOME/.cursor"
link_dotfile "$HOME/.cursor/commands" "$DOTFILES/.config/cursor/commands"

# import moom config (optional; requires Moom.app)
MOOM_PLIST="$DOTFILES/.config/moom/moom.plist"
if [ -f "$MOOM_PLIST" ] && { [ -d /Applications/Moom.app ] || [ -d "$HOME/Applications/Moom.app" ]; }; then
  defaults import com.manytricks.Moom "$MOOM_PLIST" || \
    echo "Note: Moom import failed; quit Moom and re-run install.sh." >&2
elif [ -f "$MOOM_PLIST" ]; then
  echo "Skipping Moom import (install Moom.app first, then re-run install.sh)." >&2
else
  echo "Skipping Moom import ($MOOM_PLIST not found)." >&2
fi

# install tmux plugins
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || \
    echo "Note: tmux plugin install skipped; start tmux and press prefix+I." >&2
fi

# install vim colorschemes
if [ ! -e "$DOTFILES/.vim/colors/dark-plus" ]; then
  git clone https://github.com/dunstontc/vim-vscode-theme.git "$DOTFILES/.vim/colors/dark-plus"
fi

# install vundle
if [ ! -e "$HOME/.vim/bundle/Vundle.vim" ]; then
  mkdir -p "$HOME/.vim/bundle"
  git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
fi

# install vim/neovim plugins with vundle
if command -v nvim >/dev/null 2>&1; then
  nvim +PluginInstall +qall || \
    echo "Note: nvim PluginInstall failed; run :PluginInstall in nvim." >&2
elif command -v vim >/dev/null 2>&1; then
  vim +PluginInstall +qall || \
    echo "Note: vim PluginInstall failed; run :PluginInstall in vim." >&2
fi

# set default location for screenshots
SCREENSHOT_PATH="$HOME/Desktop/screenshots"
[ ! -d "$SCREENSHOT_PATH" ] && mkdir "$SCREENSHOT_PATH"
defaults write com.apple.screencapture location "$SCREENSHOT_PATH"
killall SystemUIServer 2>/dev/null || true

# Cursor skills (separate repo → ~/.cursor/skills/)
DEV_ROOT="${DEV_ROOT:-$HOME/dev}"
SKILLS_REPO="$DEV_ROOT/skills"
if [ ! -d "$SKILLS_REPO/.git" ]; then
  if [ -e "$SKILLS_REPO" ]; then
    echo "Note: $SKILLS_REPO exists but is not a git repo; skip clone." >&2
  else
    mkdir -p "$DEV_ROOT"
    git clone git@github.com:chrispalmo/skills.git "$SKILLS_REPO" || \
      echo "Note: skills clone failed (SSH access to chrispalmo/skills?)." >&2
  fi
fi
if [ -x "$SKILLS_REPO/scripts/install.sh" ]; then
  "$SKILLS_REPO/scripts/install.sh" || \
    echo "Note: skills install failed; run $SKILLS_REPO/scripts/install.sh" >&2
else
  echo "Note: skills installer missing at $SKILLS_REPO/scripts/install.sh" >&2
fi

echo "Done."
