#!/usr/bin/env bash

if [[ "$MISE_TOOL_NAME" != "php" || -z "$DOTFILES_DIR" ]]; then
    echo "Skipping php setup"
    exit 0
fi

php_version="$MISE_TOOL_VERSION"
install_dir="$MISE_TOOL_INSTALL_PATH"
source_dir="$DOTFILES_DIR/config/php"
logs_dir="$DOTFILES_DIR/scripts/logs"

declare -A req_dirs
req_dirs['imagemagick']=`brew --prefix imagemagick`
req_dirs['libpq']=`brew --prefix libpq`
req_dirs['libevent']=`brew --prefix libevent`
req_dirs['msgpack']=`brew --prefix msgpack`
req_dirs['openssl']=`brew --prefix openssl@3`

export PKG_CONFIG_PATH="${req_dirs['libpq']}/lib/pkgconfig:${req_dirs['openssl']}/lib/pkgconfig"
export CXXFLAGS="-I`brew --prefix`/include"
export LDFLAGS="-L`brew --prefix`/lib"

declare -A ext_opts
ext_opts['ev']="enable-ev-debug='no'"
ext_opts['event']="with-event-ns='yes' with-event-libevent-dir='${req_dirs["libevent"]}' with-event-openssl='yes'"
ext_opts['imagick']="with-imagick='${req_dirs['imagemagick']}'"
ext_opts['lzf']="enable-lzf-better-compression='no'"
ext_opts['openswoole']="enable-sockets='yes' enable-openssl='yes --with-openssl-dir=${req_dirs["openssl"]}' enable-http2='yes' enable-mysqlnd='yes' enable-hook-curl='yes'"
ext_opts['redis']="enable-redis-igbinary='yes' enable-redis-lzf='yes' enable-redis-zstd='yes' enable-redis-msgpack='no' enable-redis-lz4='yes' with-liblz4='yes'"

beta_exts=(uv)
util_install_home="${XDG_DATA_HOME:-$HOME/.local/share}"
util_install_bin="$HOME/.local/bin"

function php_bin() {
    "$install_dir/bin/php" "$@"
}

function pecl_bin() {
    "$install_dir/bin/pecl" "$@"
}

# Install PIE - https://github.com/php/pie/
function install_pie() {
    if ! command -v gh >/dev/null 2>&1; then return; fi

    local pie_dir="$util_install_home/php-pie"
    mkdir -p "$pie_dir"

    {
        curl --silent -fLo "$pie_dir/pie.phar" https://github.com/php/pie/releases/latest/download/pie.phar
        gh attestation verify --owner php "$pie_dir/pie.phar" && chmod +x "$pie_dir/pie.phar"
        ln -sf "$pie_dir/pie.phar" $util_install_bin/pie
    } > "$logs_dir/pie.txt"

    echo -e "\e[32mPie\e[0m installed in \e[33m~/.local/share/php-pie\e[0m"
}

# Install Phive - https://phar.io/
function install_phive() {
    if ! command -v gpg >/dev/null 2>&1; then return; fi

    local PHIVE_HOME="$util_install_home/phive"
    mkdir -p "$PHIVE_HOME"

    {
        curl --silent -L https://phar.io/releases/phive.phar > "$PHIVE_HOME/phive.phar"
        curl --silent -L https://phar.io/releases/phive.phar.asc > "$PHIVE_HOME/phive.phar.asc"

        if [ ! -f "$PHIVE_HOME/phive.phar.asc" ]; then return; fi

        gpg --keyserver hkps://keys.openpgp.org --recv-keys 0x9D8A98B29B2D5D79
        gpg --verify "$PHIVE_HOME/phive.phar.asc" "$PHIVE_HOME/phive.phar"

        chmod +x "$PHIVE_HOME/phive.phar"
        ln -sf "$PHIVE_HOME/phive.phar" "$util_install_bin/phive"

        $PHIVE_HOME/phive.phar update-repository-list
    } > "$logs_dir/phive.txt"

    echo -e "\e[32mPhive\e[0m installed in \e[33m~/.local/share/phive\e[0m"
}

function install_ext() {
    local mode="$1"
    local ext="$2"
    local conf="$3"

    if in_beta $2; then
        ext="$2-beta"
    fi

    (
        set -e

        {
            if [[ ! -z ${ext_opts[$ext]+x} ]]; then
               	pecl_bin install --configureoptions="${ext_opts[$ext]}" $ext
            else
                pecl_bin install $ext
            fi
        } > "$logs_dir/php${php_version}_${ext}.txt"

        ln -sf "$source_dir/conf.d/$mode-$ext.ini" "$install_dir/conf.d/$conf.ini"

        echo -e " - Ext \e[32m$ext\e[0m installed via \e[33m$mode\e[0m"
    )
}

# Determine whether an extension is in beta
function in_beta() {
    for beta_ext in "${beta_exts[@]}"; do
        [[ $beta_ext == $1 ]] && return 0
    done

    unset beta_ext

    return 1
}

# Remove default php.ini and replace with custom version
if [[ -f "$install_dir/conf.d/php.ini" ]]; then
    rm "$install_dir/conf.d/php.ini"
    ln -sf "$source_dir/php.ini" "$install_dir/"
fi

if [[ ! -d "$logs_dir" ]]; then mkdir -p $logs_dir; fi

if ! command -v pie >/dev/null 2>&1; then install_pie; fi
if ! command -v phive >/dev/null 2>&1; then install_phive; fi

declare -A pecl_exts
declare -A pie_exts

for ext_conf in `ls $source_dir/conf.d/*.ini`; do
    # Split string by delimiter - credit: https://stackoverflow.com/a/918931
    IFS='-' read -ra conf_arr <<< `basename $ext_conf .ini`

    ext_name="${conf_arr[1]}"
    order=`[[ "$ext_name" == "xdebug" ]] && echo 99 || echo 01`

    if [[ "${conf_arr[0]}" == "pecl" ]]; then
        pecl_exts[$ext_name]=$order-ext-$ext_name
    else
        pie_exts[$ext_name]=$order-ext-$ext_name
    fi
done

echo "Installing PHP extensions"

pecl_bin update-channels 1> /dev/null

ext_dir=`php_bin -r "echo ini_get('extension_dir').PHP_EOL;"`
exts=( $( echo ${!pecl_exts[@]} | tr ' ' $'\n' | sort ) )

for ext in ${exts[@]}; do
    if [[ ! -f "$ext_dir/$ext.so" ]]; then
        install_ext pecl $ext ${pecl_exts[$ext]}; continue
    fi

    ln -sf "$source_dir/conf.d/pecl-$ext.ini" "$install_dir/conf.d/$conf.ini"
    echo -e " - Ext \e[32m$ext\e[0m configured"
done
