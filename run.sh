#/bin/sh

# is a certain UID wanted?
if [ ! -z "$APACHE_UID" ]; then
    useradd --home /var/www --gid www-data -M -N --uid $APACHE_UID www-data
    echo "export APACHE_RUN_USER=www-data" >> /etc/apache2/envvars
    chown -R www-data /var/lib/apache2
fi


if [ ! -z "$PHP_DISPLAY_ERRORS" ]; then
	sed -e "s/display_errors = On/display_errors = $PHP_DISPLAY_ERRORS/g" -i /phpfarm/inst/php-*/lib/php.ini
fi
#start hhvm server
hhvm --mode daemon -vServer.Type=fastcgi -vServer.Port=9000 &

apache2ctl start
tail -f /var/log/apache2/error.log
