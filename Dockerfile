FROM ubuntu:trusty
MAINTAINER Mike Jett <mjett@mitre.org>

# Linux hosts with kernel > 3.15 have problems modifying users.
# This is the suggested fix
# See https://github.com/docker/docker/issues/6345
RUN mv /usr/bin/chfn /usr/bin/chfn.real && ln -s /bin/true /usr/bin/chfn

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install supervisor phpmyadmin apache2-utils git php5-xdebug apache2 curl php5-gd libapache2-mod-php5 mysql-server php5-mysql php5-curl pwgen php-apc php5-mcrypt && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# package install is finished, clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# install custom config files
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Create a space for Elgg
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

########################################
# PHPMYADMIN MODIFY BEGIN
########################################

# Enable phpmyadmin
RUN printf "Include /etc/phpmyadmin/apache.conf\n" >> /etc/apache2/apache2.conf

# Allow developer unauthenticated access to phpmyadmin
RUN sudo dpkg-reconfigure phpmyadmin
ADD phpmyadmin.conf /
RUN rm -f /etc/phpmyadmin/config.inc.php && mv phpmyadmin.conf /etc/phpmyadmin/config.inc.php

########################################
# PHPMYADMIN MODIFY END
########################################

# Install Composer. We run it in run.sh so the /app volume is mounted
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install from nodesource using apt-get
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
RUN curl -sSL https://deb.nodesource.com/setup | bash
RUN apt-get install -yq nodejs build-essential
 
# fix npm - not the latest version installed by apt-get
RUN npm install -g npm

RUN npm install -g karma karma-cli phantomjs
# Media directory is the data directory
RUN chown -R www-data:www-data /media

# Enviornment variables to configure php and elgg
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# clean up tmp files (we don't need them for the image)
RUN rm -rf /tmp/* /var/tmp/*

# Add volumes for MySQL 
# Removing this because docker stop and starts won't work
#VOLUME  ["/etc/mysql", "/var/lib/mysql"]

# Add volume for elgg
VOLUME  [ "/app" ]

# Install Elgg and run the servers
EXPOSE 80 3306
ADD install.php /
ADD check_install.php /
ADD settings_rewrite_url.php /
ADD GetHost.php /
CMD ["/run.sh"]
