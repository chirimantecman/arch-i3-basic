#-----------------------------------------------------------------------
# .zshrc - local interactive shell startup script.
#
# versions:
#     0.9.0 - 20.12.18 - Created. Sets emacs key bindings and completion
#                        system.
#     0.9.1 - 21.12.18 - Adds some aliases for ls.
#     0.9.2 - 22.12.18 - Adds precmd function for newline after
#                        commands. Adds VCS info.
#
# author:
#     Cristian Orellana M. <cristian.orellana.m@gmail.com>
#-----------------------------------------------------------------------

# Set emacs-style key bindings for shell.
bindkey -e;

# Initialize completion system.
zstyle ':completion:*' completer _complete _ignored _approximate;
zstyle ':completion:*' list-colors '';
zstyle ':completion:*' menu select=1;
zstyle :compinstall filename '/home/chiri/.config/zsh/.zshrc';
autoload -U compinit;
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION;

# VCS contrib functions.
autoload -Uz vcs_info;
zstyle ':vcs_info:*' formats $'%F{013}\n[git]%f %F{183}%r%f %F{180}\ue725 %b%f%F{252}%u%c%f';
zstyle ':vcs_info:*' check-for-changes true;
zstyle ':vcs_info:*' stagedstr ' - staged changes to commit';
zstyle ':vcs_info:*' unstagedstr ' - unstaged changes';

# Functions.
## precmd - used to draw a newline before the Nth prompt, where N>1.
function precmd() {
    vcs_info;
    if [[ -v PAST_FIRST_PROMPT ]]; then
        echo '';
    else
        PAST_FIRST_PROMPT=1;
    fi
}

# Aliases.
## ls
alias ls='ls -lN --color --group-directories-first';
alias ld='ls -dN ~/.[^.]*';
alias la='ls -aN --color --group-directories-first';

## emacs
alias e='emacs';
alias en='emacs -nw';
alias eq='emacs -nw -Q';
alias se='sudoedit';

## pacman
alias paci='sudo pacman -S';
alias pacud='sudo pacman -Syu';
alias pacr='sudo pacman -Ru';
alias pacq='sudo pacman -Ss';

## General
alias x='exit';

## Star Wars Telnet
alias ep4='telnet towel.blinkenlights.nl';
