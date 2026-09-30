# Easier navigation: .., ..., ...., ....., ~ and -
# alias ..="cd .."
# alias ...="cd ../.."
# alias ....="cd ../../.."
# alias .....="cd ../../../.."
# alias ~="cd $HOME" # `cd` is probably faster to type though

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

# eval $(dircolors -b ~/.dircolors)
alias grep='grep ${colorflag}'
alias fgrep='fgrep ${colorflag}'
alias egrep='egrep ${colorflag}'

# Always use color output for ls
if command -v eza >/dev/null 2>&1; then
    alias ls="eza --color --icons --group-directories-first"
fi

# List all files colorized in long format
alias l="ls -lh"
# List all files colorized in long format, including dot files
alias la="ls -lah"
