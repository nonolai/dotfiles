# Set up the prompt
autoload -Uz promptinit
autoload -U colors && colors
promptinit

setopt prompt_subst
function collapse_path {
  echo $(
    pwd \
      | sed "s#$HOME#~#" \
      | sed 's#~/dev/\([^/]*\)/*\(.*\)#[dev:\1] \2#' \
      | sed "s#~/dev#[dev:no repo] #"
  )
}
PROMPT='%F{96}$(collapse_path)%{$reset_color%} %# '
setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Fix home/end
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Bazel
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=104'

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export VISUAL="vim"

if [[ -a ~/.path_extensions ]]; then
  source ~/.path_extensions
fi

if [[ -a ~/.common_aliases ]]; then
  source ~/.common_aliases
fi
