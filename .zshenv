# Machine baseline for every zsh shell (interactive, non-interactive, agent, human).
# See AGENTS.md before editing shell startup files in this repo.

if [[ -n "$CURSOR_AGENT" || -n "$CLAUDECODE" || -n "$CLAUDE_CODE_CHILD_SESSION" ]]; then
    export AI_AGENT_SHELL=1
fi

export DEV_ROOT="${DEV_ROOT:-$HOME/dev}"

# neovim (linux tarball install)
[[ -d /opt/nvim-linux64/bin ]] && export PATH="$PATH:/opt/nvim-linux64/bin"

# vscode
export PATH="/usr/local/bin/code:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Local Node.js via `n`
export N_PREFIX="$HOME/.n"
export PATH="$N_PREFIX/bin:$PATH"

# User-local CLI tools
export PATH="$HOME/.local/bin:$PATH"

# Must stay quiet: no echo, no prompt.
[ -f "$DEV_ROOT/dotfiles/.keys" ] && source "$DEV_ROOT/dotfiles/.keys"

if [[ -n "$AI_AGENT_SHELL" ]]; then
    export EDITOR=:
    export GIT_EDITOR=true
fi
. "$HOME/.cargo/env"
