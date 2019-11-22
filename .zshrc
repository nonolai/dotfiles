fpath=( ~/scripts/zsh "${fpath[@]}" )

# Set up the prompt
autoload -Uz promptinit
autoload -U colors && colors
promptinit

setopt prompt_subst
function hg_prompt {
  if [[ $(hg root 2> /dev/null) ]]; then
    #hg prompt "{ {status}}"
  fi
}
function collapse_path {
  echo $(
    pwd \
      | sed "s#$HOME#~#" \
      | sed "s#~/dev/geneva/*#[geneva%F{104}$(hg_prompt)%F{96}] #" \
      | sed 's#~/dev/\([^/]*\)/*\(.*\)#[dev:\1] \2#' \
      | sed "s#~/dev#[dev:no repo] #"
  )
}
PROMPT='%F{104}%n@%m:%{$reset_color%}%F{96}$(collapse_path)%{$reset_color%}
%# '
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
export HOMEBREW_GITHUB_API_TOKEN="39a5f68a10b27f3ca05b4933eb41d4af345d66f0"
export GOPATH=$HOME/dev/go
export ANDROID_HOME=$HOME/Library/Android/sdk

export PATH=$PATH:$GOPATH/bin
export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/bin/flutter/bin

# Remove after you switch back to pre built godot
export PKG_CONFIG_PATH=/Library/Frameworks/Mono.framework/Versions/5.4.1/lib/pkgconfig/

source ~/.common_aliases

if [[ -a ~/.machine_aliases ]]; then
  source ~/.machine_aliases
fi

alias geneva='. ~/scripts/geneva.sh'
alias contrib='. ~/scripts/contrib.sh'
alias adb='/Users/cameron/Library/Android/sdk/platform-tools/adb'

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
