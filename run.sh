#!/bin/bash

# check if we have an elgg mount first
if [ ! -f /app/composer.json ]; then
    echo "No Elgg composer.json file found. Did you forget to mount /app?"
    exit 1
fi

# should we update composer packages?
export UPDATE_COMPOSER=${UPDATE_COMPOSER:-1}
if [ $UPDATE_COMPOSER -eq 1 ]; then
	pushd /app
	composer update 
	popd
fi

# decide if we're going to show credentials after creation
SHOW_CREDENTIALS=0
if [ -z "${MYSQL_USER}" -o -z "${MYSQL_PASS}" \
    -o -z "${ELGG_DB_USER}" -o -z "${ELGG_DB_PASS}" \
    -o -z "${ELGG_USERNAME}" -o -z "${ELGG_PASSWORD}" \
]; then
    SHOW_CREDENTIALS=1
fi

# set defaults or env vars for Elgg and MySQL
# MySQL
export MYSQL_USER=${MYSQL_USER:-"admin"}
export MYSQL_PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}

# required for installation
export ELGG_DB_HOST=${ELGG_DB_HOST:-"127.0.0.1"}
export ELGG_DB_USER=$MYSQL_USER
export ELGG_DB_PASS=$MYSQL_PASS
export ELGG_DB_NAME=${ELGG_DB_NAME:-"elgg"}

export ELGG_SITE_NAME=${ELGG_SITE_NAME:-"Elgg Site"}
# Elgg requires a FQDN for the email address.
export ELGG_SITE_EMAIL=${ELGG_SITE_EMAIL:-"elgg@${HOSTNAME}.docker"}
export ELGG_WWW_ROOT=${ELGG_WWW_ROOT:-"http://localhost:${PORT}"}
export ELGG_DATA_ROOT=${ELGG_DATA_ROOT:-"/media/"}

# admin user setup
export ELGG_DISPLAY_NAME=${ELGG_DISPLAY_NAME:-"admin"}
export ELGG_EMAIL=${ELGG_EMAIL:-"elgg_admin@${HOSTNAME}.docker"}
export ELGG_USERNAME=${ELGG_USERNAME:-"admin"}
export ELGG_PASSWORD=${ELGG_PASSWORD:-$(pwgen -s 12 1)}

# optional for installation
export ELGG_DB_PREFIX=${ELGG_DB_PREFIX:-"elgg_"}
export ELGG_PATH=${ELGG_PATH:-"/var/www/html/"}
# 2 is ACCESS_PUBLIC
export ELGG_SITE_ACCESS=2

# rewrite 
sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini

# test MySQL and set up if needed
VOLUME_HOME="/var/lib/mysql"
if [[ ! -f $VOLUME_HOME/ibdata1 ]] && [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    ls $VOLUME_HOME
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    . create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

#start mysql so we can check if elgg is installed.
service mysql start

echo "Testing Elgg installation"
php /check_install.php 

if [ "$?" -ne 0 ]; then
    echo "Needs installation"
    if [ -f "/app/engine/settings.php" -o -f "/app/.htaccess" ]; then
	export REINSTALL=${REINSTALL:-0}
        if [ $REINSTALL -eq 1 ]; then
            echo "Removing settings.php and .htaccess files and reinstalling as requested..."
            rm -f /app/engine/settings.php /app/.htaccess
            php -d error_reporting="E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED" /install.php
            if [ "$?" -ne 0 ]; then
                echo "Error installing."
                exit 1
            fi
            
            # upon access, need to rewrite the url and port
            # since we don't know what it will be until then.
            cat /settings_rewrite_url.php >> /app/engine/settings.php
        else
            echo "Aborting installation because a settings.php file already exists!"
            echo "Remove it or update it with the correct credentials and then try again,"
            echo "or set the env var REINSTALL=1 (docker run -e REINSTALL=1 ...) to overwrite it."
            exit 1;
        fi
    else
        echo "Installing Elgg."
        php -d error_reporting="E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED" /install.php
        if [ $? -ne 0 ]; then
            echo "Error installing."
            exit 1
        fi

        # upon access, need to rewrite the url and port
        # since we don't know what it will be until then.
        cat /settings_rewrite_url.php >> /app/engine/settings.php
    fi
fi

# stop again so the main process can manage it.
#service mysql stop
# the debian mysql user's password is wrong
mysqladmin shutdown

if [ "${SHOW_CREDENTIALS}" -eq 1 ]; then
    echo "Elgg and MySQL have been installed with the following credentials:"
    echo "  Elgg admin username: ${ELGG_USERNAME}"
    echo "  Elgg admin password: ${ELGG_PASSWORD}"
    echo "  MySQL username: ${MYSQL_USER}"
    echo "  MySQL password: ${MYSQL_PASS}"
fi

# start all services
exec supervisord -n
