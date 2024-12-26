#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
export EDITOR=nvim
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --bash)"
export FZF_COMPLETION_TRIGGER='~~'
export FZF_COMPLETION_OPTS='--info=inline'
export FZF_DEFAULT_OPTS='--bind "ctrl-y:execute-silent(printf {} | cut -f 2- | wl-copy --trim-newline)"'
fg() {
   rg --color=always --line-number --no-heading --smart-case "${*:-}" |
  fzf --ansi --info=inline \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --delimiter : \
      --preview 'bat --color=always {1} --style=plain --highlight-line {2}' \
      --preview-window 'right,60%,noborder' \
      --bind 'enter:become(nvim {1} +{2})'
}
# fkill - kill processes - list only the ones you can kill. Modified the earlier script.
fkill() {
    local pid 
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi  

    if [ "x$pid" != "x" ]
    then
        echo $pid | xargs kill -${1:-9}
    fi  
}
function cd() {
    if [[ "$#" != 0 ]]; then
        builtin cd "$@";
        return
    fi
    while true; do
        local lsd=$(echo ".." && ls -p | grep '/$' | sed 's;/$;;')
        local dir="$(printf '%s\n' "${lsd[@]}" |
            fzf --reverse --preview '
                __cd_nxt="$(echo {})";
                __cd_path="$(echo $(pwd)/${__cd_nxt} | sed "s;//;/;")";
                echo $__cd_path;
                echo;
                ls -p --color=always "${__cd_path}";
        ')"
        [[ ${#dir} != 0 ]] || return 0
        builtin cd "$dir" &> /dev/null
    done
}



# cd
shopt -s autocd
set -o noclobber
shopt -s checkwinsize

alias ls='ls --color=auto -Alh'
alias pacs='pacman --color always -Sl | sed -e "s: :/:; /installed/d" | cut -f 1 -d " " | fzf --multi --ansi --preview "pacman -Si {1}" | xargs -ro sudo pacman -S'
alias pars='paru --color always -Sl | sed -e "s: :/:; /installed/d" | cut -f 1 -d " " | fzf --multi --ansi --preview "paru -Si {1}" | xargs -ro paru -S'
alias pacr="pacman --color always -Qe | cut -f 1 -d ' ' | fzf --multi --ansi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias pacq="pacman --color always -Q | cut -f 1 -d ' ' | fzf --multi --ansi --preview 'pacman -Qi {1}' | xargs -ro sudo pacman -Rns"
alias paco="pacman -Qqdt | sudo pacman -Rns -"
alias pacu="sudo pacman -Syu"
alias kr='sudo keyd reload'
alias vi="fzf --bind 'enter:become(nvim {})'"
alias my_config="git --git-dir $HOME/.my_config --work-tree=$HOME"
[ "$(tty)" = "/dev/tty1" ] && exec sway
fastfetch

