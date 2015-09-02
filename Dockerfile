FROM akudan/docker-elgg-base
MAINTAINER Mike Jett <mjett@mitre.org>

# Install packages
RUN apt-get update && apt-get -y install phpmyadmin php5-xdebug

# install custom config files
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini

# Enable phpmyadmin
RUN printf "Include /etc/phpmyadmin/apache.conf\n" >> /etc/apache2/apache2.conf
RUN dpkg-reconfigure phpmyadmin

# Allow developer unauthenticated access to phpmyadmin
ADD phpmyadmin.conf /
RUN rm -f /etc/phpmyadmin/config.inc.php && mv phpmyadmin.conf /etc/phpmyadmin/config.inc.php

# install from nodesource using apt-get
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
RUN curl -sSL https://deb.nodesource.com/setup | bash && apt-get install -yq nodejs build-essential

RUN npm config set proxy http://gatekeeper.mitre.org:80 && \
    npm config set https-proxy http://gatekeeper.mitre.org:80 

# fix npm - not the latest version installed by apt-get
RUN npm config set strict-ssl false --global && npm install -g npm

# Media directory is the data directory
RUN chown -R www-data:www-data /media

# clean up tmp files (we don't need them for the image)
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add volume for elgg
VOLUME  [ "/app" ]

# Install Elgg and run the servers
EXPOSE 80 3306 9876
ADD install.php /
ADD check_install.php /
ADD settings_rewrite_url.php /
ADD GetHost.php /
ADD wait.sh /
RUN chmod +x /wait.sh
RUN mkdir -p /etc/my_init.d
ADD run.sh /etc/my_init.d/run.sh
#RUN chmod +x /etc/my_init.d/run.sh
