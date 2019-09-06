#!/usr/bin/env bash
{
# clear any previous sudo permission
sudo -k

sudo sh <<SCRIPT
add-apt-repository ppa:ondrej/php -y > /dev/null 2>&1
SCRIPT

# Configure
phpv=$(php -r "echo substr(PHP_VERSION, 0, 3);")
echo "Configuring PHP ${phpv} for development"

for phpc in /etc/php/$phpv/{apache2,cgi,cli,fpm}; do
	phpi="${phpc}/php.ini"

	if [ ! -r $phpi ]; then
		echo "[skip] ${phpi} Not available"
		continue
	fi

	sudo sh <<SCRIPT
	echo "[conf] ${phpi}"
	echo " - error_reporting"
	sed -i -E "s~error_reporting = .*~error_reporting = E_ALL~" $phpi
	echo " - display_errors"
	sed -i -E "s~display_errors = .*~display_errors = stderr~" $phpi
	echo " - display_startup_errors"
	sed -i -E "s~display_startup_errors = .*~display_startup_errors = On~" $phpi
	echo " - log_errors"
	sed -i -E "s~log_errors = .*~log_errors = On~" $phpi
	echo " - error_log"
	sed -i -E "s~error_log = .*~error_log = On~" $phpi

	echo " - post_max_size"
	sed -i -E "s~post_max_size = .*~post_max_size = 128M~" $phpi
	echo " - upload_max_filesize"
	sed -i -E "s~upload_max_filesize = .*~upload_max_filesize = 100M~" $phpi
	echo " - max_file_uploads"
	sed -i -E "s~max_file_uploads = .*~max_file_uploads = 50~" $phpi
SCRIPT
done

unset phpv phpc phpi
}
