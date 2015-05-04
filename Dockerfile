FROM akudan/docker-elgg-base
MAINTAINER Mike Jett <mjett@mitre.org>

# Install packages
RUN apt-get update && apt-get -y install phpmyadmin php5-xdebug

# package install is finished, clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# install custom config files
ADD xdebug.ini /etc/php5/mods-available/xdebug.ini

# Enable phpmyadmin
RUN printf "Include /etc/phpmyadmin/apache.conf\n" >> /etc/apache2/apache2.conf

# Set up phpmyadmin
ADD phpmyadmin_setup.sh /phpmyadmin_setup.sh
RUN chmod 755 /*.sh
CMD ["/phpmyadmin_setup.sh"]

# Allow developer unauthenticated access to phpmyadmin
ADD phpmyadmin.conf /
RUN rm -f /etc/phpmyadmin/config.inc.php && mv phpmyadmin.conf /etc/phpmyadmin/config.inc.php

# install from nodesource using apt-get
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-an-ubuntu-14-04-server
RUN curl -sSL https://deb.nodesource.com/setup | bash && apt-get install -yq nodejs build-essential

# fix npm - not the latest version installed by apt-get
RUN npm config set strict-ssl false --global && npm install -g npm

# clean up tmp files (we don't need them for the image)
RUN rm -rf /tmp/* /var/tmp/*

# Add volume for elgg
VOLUME  [ "/app" ]

# Install Elgg and run the servers
EXPOSE 80 3306 9876
ADD run.sh /
RUN chmod 755 /*.sh
ADD install.php /
ADD check_install.php /
ADD settings_rewrite_url.php /
ADD GetHost.php /
CMD ["/run.sh"]
