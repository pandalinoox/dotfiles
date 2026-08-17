# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/panda/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOME/.tmuxifier/bin:$PATH"

eval "$(oh-my-posh init zsh --config ~/.cache/oh-my-posh/themes/dracula.omp.json)"
eval "$(tmuxifier init -)"
#compdef
compdef eza=ls

# Aliases
alias ls='eza -l --icons=auto'
alias lsh='eza -lah --icons=auto'
alias tree='eza --tree --icons=always --color=always'
alias treeh='eza --tree --icons=always --color=always --git-ignore'
alias cat="bat"
alias sl="sl -l"
alias lg="lazygit"

fzfcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --preview 'eza -T -L 2 --color=always {} | head -200')
  [[ -n "$dir" ]] && cd "$dir"
}
alias fcd="fzfcd"

fzfcdhome() {
  local dir
  dir=$(cd "$HOME" && \
        fd --type d --hidden --follow --exclude .git . 2>/dev/null | \
        fzf --preview 'eza -T -L 2 --color=always ~/{} | head -200')
  [[ -n "$dir" ]] && cd "$HOME/$dir"
}
alias fcdh="fzfcdhome"

fzfnvim() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git 2>/dev/null | \
    fzf --preview 'bat --style=numbers --color=always --line-range :300 {}')
  [[ -n "$file" ]] && nvim "$file"
}
alias fnvim="fzfnvim"

# Zsh plugins

# Autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Better history behavior
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# FZF keybindings
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

