#!/bin/bash
set -euo pipefail

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
  SHELLENV='eval "$(/usr/local/bin/brew shellenv)"'
fi

touch "$HOME/.zprofile"
grep -q 'brew shellenv' "$HOME/.zprofile" || echo "$SHELLENV" >> "$HOME/.zprofile"

brew update

brew install \
  bat bc fzf git git-lfs gh jq glab neovim \
  pyenv pyenv-virtualenv ripgrep the_silver_searcher \
  tmux tmuxinator tree python@3.12 pipx n

brew link --overwrite python@3.12

brew tap rakalex/mac-brightnessctl
brew install mac-brightnessctl

pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"
pipx install shell-gpt

export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"
mkdir -p "$N_PREFIX"
n stable

npm install --global yarn

if [[ "$(uname -m)" == arm64 ]]; then
  softwareupdate --install-rosetta --agree-to-license || true
fi

"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

echo "Done. Open a new terminal, then run ~/dev/dotfiles/install.sh"
