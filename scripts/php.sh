#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

install=1
display_errors='stderr'
log_errors='STDERR'
post_max_size='128M'
upload_max_filesize='100M'
max_file_uploads='50'
user_ini_filename='.user.ini'

_usage() {
	cat <<USAGE
  Usage:
    command [option]

  Available Options:
    --no-install                  Skip the installation.
    --post-max-size <value>       php.ini 'post_max_size' value, default: ${post_max_size}
    --upoad-max-filesize <value>  php.ini 'upload_max_filesize' value, default: ${upload_max_filesize}
    --max-file-upload <value>     php.ini 'max_file_upload' value, default: ${max_file_upload}
    --user-ini-filename <value>   php.ini 'user_ini.filename' value, default: ${user_ini_filename}
    --help | -h                   Show this usage help
USAGE
}

_OPTS=''
while [ $# -ne 0 ]; do
	case $1 in
		--no-install)
			install=0
			shift
		;;
		--post-max-size)
			post_max_size="${2}"
			shift 2
		;;
		--upload-max-filesize)
			upload_max_filesize="${2}"
			shift 2
		;;
		--max-file-upload)
			max_file_uploads="${2}"
			shift 2
		;;
		--user-ini-filename)
			user_ini_filename="${2}"
			shift 2
		;;
		-h|--help)
			_usage
			exit 0
		;;
		-?*)
			echo "Invalid argument: $1" 1>&2
			exit 1
		;;
		*)
			break
		;;
	esac
done

echo $_OPTS
# Configure
phpv=$(php -r "echo substr(PHP_VERSION, 0, 3);")
echo "Configuring PHP ${phpv} for development"

if [ $install = 1 ]; then
	sudo sh <<SCRIPT
	# add-apt-repository ppa:ondrej/php -y > $_LOG_FILE 2>&1
SCRIPT
else
	echo '[skip] No install'
fi

for phpc in /etc/php/$phpv/{apache2,cgi,cli,fpm}; do
	phpi="${phpc}/php.ini"

	if [ ! -r $phpi ]; then
		echo "[skip] ${phpi} Not available"
		continue
	fi

	sudo sh <<SCRIPT
	echo "[conf] ${phpi}"
	echo " - error_reporting"
	sed -i -E "s~error_reporting =.*~error_reporting = E_ALL~" $phpi
	echo " - display_errors : ${display_errors}"
	sed -i -E "s~display_errors =.*~display_errors = stderr~" $phpi
	echo " - display_startup_errors"
	sed -i -E "s~display_startup_errors =.*~display_startup_errors = On~" $phpi
	echo " - log_errors"
	sed -i -E "s~log_errors =.*~log_errors = On~" $phpi
	echo " - error_log : ${error_log}"
	sed -i -E "s~error_log =.*~error_log = STDERR~" $phpi

	echo " - post_max_size : ${post_max_size}"
	sed -i -E "s~post_max_size =.*~post_max_size = ${post_max_size}~" $phpi
	echo " - upload_max_filesize : ${upload_max_filesize}"
	sed -i -E "s~upload_max_filesize =.*~upload_max_filesize = ${upload_max_filesize}~" $phpi
	echo " - max_file_uploads : ${max_file_uploads}"
	sed -i -E "s~max_file_uploads =.*~max_file_uploads = ${max_file_uploads}~" $phpi

	# echo " - sendmail_path"
	# sed -i -E "s~;sendmail_path.*~sendmail_path = ''~" $phpi
	# sed -i -E "s~sendmail_path =.*~sendmail_path = mhsendmail~" $phpi

	echo " - user_ini.filename : ${user_ini_filename}"
	sed -i -E "s~;user_ini.filename.*~user_ini.filename = ''~" $phpi
	sed -i -E "s~user_ini.filename =.*~user_ini.filename = ${user_ini_filename}~" $phpi
SCRIPT
done

unset phpv phpc phpi
}
