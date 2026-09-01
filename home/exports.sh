# ==============================================================================
# This litle helper when /sbin, /usr/sbin & /usr/local/sbin dir
# doesn't included in $PATH, I found this issue on WSL
# ==============================================================================
# for sbin_dir in {/sbin,/usr/sbin,/usr/local/sbin,$HOME/.local/bin}; do
#     [[ -d $sbin_dir && -z "${PATH##*$sbin_dir*}" ]] && PATH=$sbin_dir:$PATH
# done
# unset sbin_dir

_shell_name=$(basename "$SHELL")

# ==============================================================================
# HomeBrew
# ==============================================================================
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # add auto completions
    # See https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
    FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

    if [[ -d `brew --prefix`/share/zsh-syntax-highlighting ]]; then
        source `brew --prefix`/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    fi
fi

if [[ -d "$HOME/.local/bin" ]]; then
	export PATH="$HOME/.local/bin:$PATH"
fi

# ==============================================================================
# Essentials
# ==============================================================================
# Zoxide | https://github.com/ajeetdsouza/zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init $_shell_name)"
fi

# Bat - Better version of cat
if command -v bat >/dev/null 2>&1; then
    export BAT_THEME=OneHalfDark
fi

# FZF - Better version of find
if command -v fzf >/dev/null 2>&1; then
    # export FZF_DEFAULT_OPTS="--color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7"

    _fzf_comprun() {
        local command="$1"
        shift
        case "$command" in
            cd) fzf --preview 'eza --tree --color=always {}' "$@" ;;
            *)  fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'""$@" ;;
        esac
    }
fi

# OrbStack
if [[ -d "$HOME/.orbstack/shell" ]]; then
	_orbstack_init_file="$HOME/.orbstack/shell/init.$_shell_name"
    [[ -f "$_orbstack_init_file" ]] && source "$_orbstack_init_file" 2>/dev/null || :
    unset _orbstack_init_file
fi

# ==============================================================================
# Composer | https://getcomposer.org/
# ==============================================================================
if command -v composer >/dev/null 2>&1; then
    export COMPOSER_HOME="$XDG_CONFIG_HOME/composer"
    [[ -d "$COMPOSER_HOME/vendor/bin" ]] && PATH="$COMPOSER_HOME/vendor/bin:$PATH"
fi

# ==============================================================================
# Bun | https://bun.sh/
# ==============================================================================
if command -v bun >/dev/null 2>&1; then
    # bun completions
    [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ==============================================================================
# Ruby
# ==============================================================================
if [[ -d "`brew --prefix ruby`" ]]; then
    PATH="`brew --prefix ruby`/bin:$PATH"
    PATH="`gem env home`/bin:$PATH"
fi

# ==============================================================================
# Ngrok | https://ngrok.com
# ==============================================================================
# if command -v ngrok >/dev/null 2>&1; then
#     eval "$(ngrok completion)"
# fi

# ==============================================================================
# Android SDK
# ==============================================================================
# if [[ -d "$XDG_DATA_HOME/android" ]]; then
#     export ANDROID_HOME="$XDG_DATA_HOME/android"
#     export ANDROID_USER_HOME="$XDG_CONFIG_HOME/android"
#     export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android"

#     for sdk_path in {cmdline-tools/latest/bin,platform-tools,emulator}; do
#         [[ -d $ANDROID_HOME/$sdk_path ]] && PATH="$PATH:$ANDROID_HOME/$sdk_path"
#     done
#     unset sdk_path
# fi

# ==============================================================================
# Vite+ | https://viteplus.dev
# ==============================================================================
# [ -f "$HOME/.vite-plus/env" ] && source "$HOME/.vite-plus/env"
