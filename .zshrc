# https://wiki.gentoo.org/wiki/Zsh/Guide
# Human-only interactive setup. Machine baseline lives in ~/.zshenv (see AGENTS.md).

if [[ -n "$AI_AGENT_SHELL" ]] || [[ ! -o interactive ]]; then
    return 0
fi

export EDITOR=nvim
export GIT_EDITOR=nvim

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

autoload -U colors compinit promptinit
colors
compinit
promptinit

# Enabling and setting git info var to be used in prompt config.
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:git*' formats "- (%b) "
precmd() {
    vcs_info
}

function set-prompt {
    VENV=""
    if [ -n "$VIRTUAL_ENV" ]; then
        BN=$(basename $VIRTUAL_ENV)
	VENV="%{%B%F{39}%}($BN)%{%f%b%} "
    fi
    BRANCH=$(echo "${vcs_info_msg_0_}" | sed 's/.*(//;s/).*//;')
    PROMPT="$VENV%{$fg_bold[green]%}%n%{$reset_color%} %{$fg_bold[yellow]%}%~%{$fg_bold[magenta]%} ${BRANCH}%{$reset_color%} $1 "
}

setopt auto_cd # cd by directly typing directory name
setopt inc_append_history # update history after each command, from multiple shells
setopt menu_complete
setopt share_history
setopt NO_BEEP

zstyle ':completion:*' menu select
zstyle ':completion:*' ignored-patterns '*?.pyc' '__pycache__' '*.class' '.zcompdump' '.zsh_history'

bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# Zsh Line Editor (visual mode)
## Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1

function zle-line-init zle-keymap-select {
    set-prompt "${${KEYMAP/vicmd/N}/(main|viins)/\$}"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# =================== #
# Functions & Aliases #
# =================== #

# Keyboard brightness controls
alias kbb='mac-brightnessctl'
kbb-get() { kbb | awk '{print $3}'; }
kbb-max() { kbb 1.0; }
kbb-min() { [[ "$(kbb-get)" == "0.01" ]] && kbb 0 || kbb 0.01; }
kbb-up() { kbb $(echo "$(kbb-get) + 0.2" | bc | awk '{print ($1>1.0)?"1.0":$1}'); }
kbb-down() { kbb $(echo "$(kbb-get) - 0.2" | bc | awk '{print ($1<0)?"0":$1}'); }

# Get names of all repos (public and private) from a github user (provided as first arg)
alias gh_repos='gh repo list "$1" --limit 1000 --json name --jq ".[].name"'

ghcf() {
  # ghcf: Fuzzy-select and clone a GitHub repo via SSH.
  # Usage:
  #   ghcf [user] [-f folder]
  # Examples:
  #   ghcf
  #   ghcf someuser
  #   ghcf -f myfolder
  #   ghcf someuser -f myfolder
  u=chrispalmo; [ "$1" != "-f" ] && [ "$1" != "--folder" ] && [ -n "$1" ] && u=$1 && shift
  [ "$1" = "-f" ] || [ "$1" = "--folder" ] && f="$2"
  f="${f## }"  # Remove leading space if present
  r=$(gh repo list "$u" --limit 1000 --json name --jq ".[].name" | fzf --prompt="Select repo to clone: ")
  [ "$r" ] && gh repo clone "$u/$r" ${f:+"$f"}
}

ghc() {
  # ghc: Clone a GitHub repo via SSH.
  # Usage:
  #   ghc <user> <repo> [-f folder]
  # Examples:
  #   ghc chrispalmo repo-name
  #   ghc chrispalmo repo-name -f mydir
  [ $# -lt 2 ] && return 1
  [ "$3" = "-f" ] || [ "$3" = "--folder" ] && git clone "git@github.com:$1/$2.git" "$4" && return
  git clone "git@github.com:$1/$2.git"
}

# Safe rm procedure
safe_rm()
{
    # Cycle through each argument for deletion
    for file in $*; do
        if [ -e $file ]; then
            # Target exists and can be moved to Trash safely
            if [ ! -e ~/.Trash/$file ]; then
                mv $file ~/.Trash
            # Target exists and conflicts with target in Trash
            elif [ -e ~/.Trash/$file ]; then
                # Increment target name until
                # there is no longer a conflict
                i=1
                while [ -e ~/.Trash/$file.$i ];
                do
                    i=$(($i + 1))
                done
                # Move to the Trash with non-conflicting name
                mv $file ~/.Trash/$file.$i
            fi
        # Target doesn't exist, return error
        else
            echo "rm: $file: No such file or directory";
        fi
    done
}

# Web search
function explainshell() {
    open -na "Google Chrome" --args "https://explainshell.com/explain?cmd=$*"
}
function localhostHTTPS() {
    open "https://localhost:$*"
}
function localhostHTTP() {
    open "http://localhost:$*"
}
function google() {
    open -na "Google Chrome" --args "https://www.google.com/search?q=$*"
}
function stackoverflow() {
    open -na "Google Chrome" --args "https://www.google.com/search?q=site:stackoverflow.com $*"
}

# Add aliases on the fly
function add { echo "alias $@" >> $HOME/.zshrc; source $HOME/.zshrc;}
function adds { echo "alias $@" >> $HOME/.scratch; source $HOME/.zshrc;}

# Make new directory and navitgate into it
function mcd() { mkdir -p $1 && cd $1 ;}

# Virtual environment deactivation
function deactivate_venv() {
    venv_active=$(which deactivate)
    if [[ $venv_active != *"deactivate not found"* ]]; then deactivate; fi
}

# Search for files in the current folder
function lag() {
    ls -lAh | ag $*
}

# Navigate to a directory, print the current path, and list files.
cdl() { builtin cd "$@" && pwd && ls -lAh; }

# Web search
alias es=explainshell
alias gg=google
alias lh=localhostHTTPS
alias lhs=localhostHTTPS
alias lhh=localhostHTTP
alias soa='open https://stackoverflow.com/questions/ask'
alias so=stackoverflow

# Nav
alias .f="cd ~/.files/"
alias df="cd ~/.files/"
alias db="cd ~/Dropbox/"
alias dt="cd ~/Desktop/"
alias gdrive='cd "$HOME/Google Drive/My Drive"'
alias dl="cd ~/Downloads/"
alias dv='cd "$DEV_ROOT"'

# Misc
alias l='pwd && ls -lAh'
alias lc='clear && pwd && ls -lAh'
alias cl='lc'
alias cp='cp -i'
alias mv='mv -i'
mvpi() { mkdir -p "$(dirname "$2")" && mv -i "$1" "$2"; }
cppi() { mkdir -p "$(dirname "$2")" && cp -i "$1" "$2"; }
cppir() { mkdir -p "$(dirname "$2")" && cp -i -r "$1" "$2"; }
tp() { mkdir -p "$(dirname "$1")" && touch "$1"; }
alias x='xargs'
alias e='echo'
alias pbc='pbcopy'

alias ..="cd .."
alias ..2="cd ../../"
alias ..3="cd ../../../"
alias b='cd -'
alias ~='cd ~'
alias o='open'
alias o.='open .'
alias of='nvim $(fzfp)'
alias cdf="fzf | cd"
alias catf='fzf | xargs cat'
alias batf='fzf | xargs bat'

alias trash='safe_rm'
alias t='safe_rm'
alias grep='grep -H -n'

if command -v pbcopy &>/dev/null; then
  # mac
  copy() { tr -d '\n' | pbcopy; }
elif command -v xclip &>/dev/null; then
  # linux (X11)
  copy() { tr -d '\n' | xclip -selection clipboard; }
fi
alias cwd='pwd | copy'

alias h='history'
alias ppath="echo $PATH | tr ':' '\n'" # print path
alias q="exit"
alias c="clear"

alias d="deactivate_venv"

# Tmux
alias qa='tmux kill-server && exit' # kill all tmux sessions
alias t8='tmuxinator'
alias t8s='tmuxinator start'

alias vc='nvim ~/.vimrc'
alias zc='nvim ~/.zshrc'
alias .zc='source ~/.zshrc'

alias v='nvim'
alias v.="nvim ."

alias c.='code .'
alias cs='cursor'
alias cs.='cursor .'

alias chrome='open -na "Google Chrome" --args' # example usage: chrome "https://example.xyz"

# Yarn
alias y='yarn'
alias ys='yarn start'
alias yt='yarn test'
alias ytw='yarn test:watch'

# Github
alias ghcp='o https://github.com/chrispalmo'

## Git standards
alias ga='git add'
alias gb='git branch' # list branches
alias gba='git branch -a' # list all branches
alias gbd='git branch --delete'
alias gbdr='git push origin --delete' # delete remote branch. use: gbdr [branch-name]
alias gbl='git branch --list'
alias gcnv='git commit --no-verify'
alias gcnvm='git commit --no-verify -m'
alias gcp='git cherry-pick'
alias gc='git commit'
alias gca='git commit --amend' # overwrite last commit
alias gd='git diff'
alias gdn='git diff --name-only'
alias gds='git diff --staged'
alias gdsn='gd --staged --name-only'
alias gf='git fetch'
alias gl='git log'
alias glf='git log --name-only' # log includes list of files changed
alias glm='git log --merge' # list of commits that conflict during merge
alias gm='git merge'
alias go='git checkout' # switch branch
alias gob='git checkout -b' # create new branch, switch to it
alias go-='git checkout -'
alias gp='git push'
alias gpf='git push --force'
alias grc='git reset HEAD^' # reset to state before last commit, keeping changes
alias gr='git reset && git status'
alias grh='git reset --hard; git status'
alias grbi="git rebase --interactive" # use: `grbi [commit-hash-before-changes]. effect: Merge together all commits AFTER [commit-hash]. Refer: https://www.internalpointers.com/post/squash-commits-into-one-git. Use `git push --force origin [branch-name], but this isn't great... aim to avoid rebasing and squashing with by using git commit --amend in the first place.
alias gs='git status'
alias gsd='git status; git diff'
alias gss='git status -s' # git status --short
alias gsn="git status -s | sed 's#.*/##'" # git status --short
alias gsh='git show'
alias gshn='git show --name-only' # list files changed in latest commit
alias gst='git stash save; git status' # `gst "message"` locally save uncommited changes (both staged and unstaged)
alias gsta='git stash apply; git status' # apply stashed changes to working copy, without deleting from stash.
alias gstd='git stash drop' # delete a stash
alias gstk='git stash save --keep-index; git status' # keeps staged changes and stashes un-tracked changes
alias gstl="git stash list"
alias gstls="git stash list --stat" # list files changed for each stash
alias gstp='git stash pop' # delete stash; apply stashed changes to working copy
alias gu='git pull --rebase'
alias git-undo-last-commit='git reset --soft HEAD~1'
alias git-redo-next-commit='git reset ORIG_HEAD'
alias gulc='git-undo-last-commit'
alias grnc="git-redo-next-commit"
gll() {
# usage: gll OR gll n (to show latest n logs)
  if [[ -n "$1" ]]; then
    git log --oneline head -n "$1"
  else
    git log --oneline
  fi
}

## Git helpers
alias fzf8="fzf -m --height=8"
function gcm() {
    # If arguments are provided, use them as the commit message
    if [[ -n "$*" ]]; then
        git commit -m "$*"
        return
    fi

    # Check if sgpt is installed
    if ! command -v sgpt &>/dev/null; then
        echo -e "\033[1;31msgpt is not installed. Opening the standard editor for the commit message.\033[0m"
        git commit
        return
    fi

    local files_changed diff_output prompt_body
    local context_budget=12000 diff_truncated=0
    local diff_header=$'git_diff:\n' marker=$'\n[git_diff truncated]'
    local remaining diff_budget

    files_changed=$(git status --short 2>/dev/null)
    diff_output=$(git diff --staged)

    # If no staged diff is available, fallback to the standard editor
    if [[ -z "$diff_output" ]]; then
        echo "No staged changes detected. Opening the standard editor for the commit message."
        git commit
        return
    fi

    prompt_body=$'Context (optional - use only if relevant to the request; otherwise ignore entirely):\n'
    prompt_body+="cwd: $PWD"$'\n'
    local git_branch
    git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$git_branch" ]]; then
        prompt_body+="git_branch: $git_branch"$'\n'
    fi
    if [[ -n "$files_changed" ]]; then
        prompt_body+=$'git_files_changed:\n'"$files_changed"$'\n'
    fi

    remaining=$(( context_budget - ${#prompt_body} ))
    if (( remaining > ${#diff_header} + ${#marker} )); then
        diff_budget=$(( remaining - ${#diff_header} ))
        if (( ${#diff_output} > diff_budget )); then
            diff_output="${diff_output:0:$(( diff_budget - ${#marker} ))}$marker"
            diff_truncated=1
        fi
        prompt_body+="$diff_header$diff_output"$'\n'
    else
        # Keep the full file list; skip diff rather than trimming files.
        diff_truncated=1
    fi

    prompt_body+=$'\nRequest:\nGenerate a concise and meaningful one-line commit message summarizing these changes. Only state changes made, NEVER assume WHY or HOW they were made. Reply ONLY with the suggested message - do not enclose it in quotation marks. NEVER respond with more than 80 characters.'

    local commit_message sgpt_err_file sgpt_err sgpt_status sgpt_err_summary
    sgpt_err_file=$(mktemp)
    # gpt-5.6-luna rejects temperature=0 (sgpt default); pass 1.
    commit_message=$(sgpt --temperature 1 <<<"$prompt_body" 2>"$sgpt_err_file")
    sgpt_status=$?
    sgpt_err=$(<"$sgpt_err_file")
    rm -f "$sgpt_err_file"
    commit_message=${commit_message%%$'\n'}

    # Fallback if sgpt fails or generates an empty response
    if [[ -z "$commit_message" || $sgpt_status -ne 0 ]]; then
        echo -e "\033[1;31msgpt failed to generate a commit message. Opening the standard editor.\033[0m"
        sgpt_err_summary=$(print -r -- "$sgpt_err" | rg -m1 "Error code:|BadRequestError:|AuthenticationError:|RateLimitError:|APIConnectionError:|Error:" || true)
        if [[ -z "$sgpt_err_summary" && -n "$sgpt_err" ]]; then
            sgpt_err_summary=$(print -r -- "$sgpt_err" | tail -n 8)
        fi
        if [[ -n "$sgpt_err_summary" ]]; then
            echo -e "\033[1;31m$sgpt_err_summary\033[0m"
        elif [[ $sgpt_status -ne 0 ]]; then
            echo -e "\033[1;31msgpt exited with status $sgpt_status (no stderr captured).\033[0m"
        else
            echo -e "\033[1;31msgpt returned an empty commit message.\033[0m"
        fi
        git commit
        return
    fi

    # Display the suggested commit message with formatting
    if (( diff_truncated )); then
        echo -e "\n\033[1;31mWarning: git diff was truncated; proposed commit message is based on incomplete information.\033[0m"
    fi
    echo -e "\n\033[1;34mSuggested commit message:\033[0m"
    echo -e "\033[1;32m$commit_message\033[0m\n"
    echo -n "Press Enter to accept, or type an alternative commit message: "

    # Prompt the user for input
    read -r user_input

    # Use the suggested message if the user presses Enter, otherwise use the provided input
    git commit -m "${user_input:-$commit_message}"
}
function gcnvm () { [[ $@ != '' ]] && { COMMIT_MESSAGE="$@" ; git commit --no-verify -m "$COMMIT_MESSAGE" } || git commit --no-verify ;}
function gcam () { [[ $@ != '' ]] && { COMMIT_MESSAGE="$@" ; git commit --amend -m "$COMMIT_MESSAGE" } || git commit --amend ;}
function gcamp () { COMMIT_MESSAGE=$(git reflog -1 | sed 's/^.*: //') ; gcam "$COMMIT_MESSAGE" ;}
get_default_branch() {
  local branch
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  if [ -n "$branch" ]; then
    echo "$branch"
  elif git show-ref --quiet refs/heads/main; then
    echo "main"
  elif git show-ref --quiet refs/heads/master; then
    echo "master"
  else
    echo "Error: No default branch found." >&2
    return 1
  fi
}

alias gmm='git merge $(get_default_branch); git status'
alias gom='git checkout $(get_default_branch)'
alias gomu='gom && git pull --rebase'

alias gcd='$(git rev-parse --show-toplevel)' # cd to repo root
alias gbn="git rev-parse --abbrev-ref HEAD" # return current branch name
alias gfiles='git diff --name-only --cached; git diff --name-only; git ls-files --others --exclude-standard'
alias gfiles-unstaged='git diff --name-only'
alias gfiles-unstaged-untracked='(git diff --name-only; git ls-files --others --exclude-standard)'
alias gbranches='git for-each-ref --format="%(refname:short)" refs/' # list all branches
alias gbranches_raw='{branches=$(gbranches); echo ${branches//origin\/};}' # list all branches, sans 'origin/' prefix

## Git (helper-assisted)
alias ga.='gcd; ga .; gs; cd -'
### compare current branch to master on github website
alias ghbc='{CURRENT_BRANCH=$(gbn); CURRENT_REPO=$(cut -d . -f 1 <<< $(cut -d : -f 2 <<< $(git config --get remote.origin.url))); o https://github.com/"$CURRENT_REPO"/compare/"$CURRENT_BRANCH";}'
### compare current branch to master on gitlab website
alias glbc='{CURRENT_BRANCH=$(gbn); CURRENT_REPO=$(cut -d / -f 2,3 <<< $(cut -d . -f 2 <<< $(git config --get remote.origin.url))); o https://gitlab.com/"$CURRENT_REPO"/-/compare/master..."$CURRENT_BRANCH";}'
### misc
alias gbnc='gbn | copy'
alias gpu='git push --set-upstream origin $(gbn)'
alias glag='gl | ag'
function gac() { ga. ; gcm "$@" ;}
function gacp() { ga. ; gcm "$@" ; gp ;}
function gacpu() { ga. ; gcm "$@" ; gpu ;}
function gacnvp() { ga. ; gcnvm "$@" ; gp ;}
function gacnvpu() { ga. ; gcnvm "$@" ; gpu ;}
alias gtree='git ls-files --cached --others --exclude-standard | tree --fromfile'

### fzf
alias gaf='gcd ; gfiles-unstaged-untracked | fzf8 | xargs git add ; gs; -' # fzf-assisted git add
alias gbdf='gcd ; gbranches_raw | fzf8 | xargs git branch --delete' # fzf-assisted git delete branch
alias gbdrf='gcd ; gbranches_raw | fzf8 | xargs git push origin --delete' # fzf-assisted git delete remote branch
alias gdf='gcd ; gfiles | fzf8 | xargs git diff --staged ; -' # fzf-assisted git diff
alias gdsf='gcd ; gfiles | fzf8 | xargs git diff --staged ; -' # fzf-assisted git diff
alias gof='gcd; gfiles-unstaged | sort -u | fzf8 | xargs -r -I{} git checkout -- {}; gs; -'
alias gobf='gbranches_raw | fzf8 | xargs git checkout' # fzf-assisted git checkout branch
alias grf='gcd ; git diff --staged --name-only | fzf -m --height=8 | xargs -r -I{} git reset -- {}; gs; cd -'

alias grmf='gcd ; git diff --name-only --diff-filter=U | fzf -m --height=8 | xargs git rm ; gs; -'

## Github CLI
alias ghprv='gh pr view --web'
alias ghprc='gh pr create --fill --draft ; gh pr view --web'
alias ghprc-nodraft='gh pr create --fill ; gh pr view --web'
alias ghprs='gh search prs'
alias ghprscp='gh search prs "author:chrispalmo"'
alias ghprscpo='gh search prs "author:chrispalmo" "is:open"'
alias ghprscpm='gh search prs "author:chrispalmo" "is:merged"'

## Gitlab CLI
alias glmrv='glab mr view'
alias glmrc='glab mr create'
alias glprv='glmrv'
alias glprc='glmrc'

# ==== #
# Path #
# ==== #

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
export FZF_DEFAULT_OPTS='--bind ctrl-s:select-all'
alias fzfp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# Open tmux in Terminal.app / iTerm only (or when AUTO_TMUX=1).
# IDE integrated terminals and SSH stay plain zsh.
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && \
  { [ "${AUTO_TMUX:-}" = 1 ] || [ "$TERM_PROGRAM" = Apple_Terminal ] || [ "$TERM_PROGRAM" = iTerm.app ]; }; then
  exec tmux
fi

# Shell-GPT integration ZSH v0.2
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    local _sgpt_prev_cmd=$BUFFER
    local _sgpt_context _sgpt_git_branch

    _sgpt_context=$'Context (optional - use only if relevant to the request; otherwise ignore entirely):\n'
    _sgpt_context+="cwd: $PWD"$'\n'

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        _sgpt_git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [[ -n "$_sgpt_git_branch" ]]; then
            _sgpt_context+="git_branch: $_sgpt_git_branch"$'\n'
        fi
    fi

    BUFFER+="⌛"
    zle -I && zle redisplay
    # gpt-5.6-luna rejects temperature=0 (sgpt default); pass 1.
    BUFFER=$(sgpt --shell --temperature 1 --no-interaction <<< "$_sgpt_context"$'\nRequest:\n'"$_sgpt_prev_cmd")
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey '^o' _sgpt_zsh
# </Shell-GPT integration ZSH v0.2>

# Import ad-hoc aliases
source ~/.files/.scratch
