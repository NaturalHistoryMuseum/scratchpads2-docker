FROM ubuntu:16.04

# Install packages
ENV TERM xterm # for nano to work
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -y install software-properties-common
RUN LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/php
RUN LC_ALL=C.UTF-8 apt-add-repository ppa:ondrej/apache2
RUN apt-get update && \
  apt-get -y install nano supervisor build-essential wget git php5.6-mysql apache2 apache2-dev libapache2-mod-php5.6 pwgen php5.6-apc php5.6-xml php5.6-gd php5.6-mbstring && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf
  
# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
# Redirect logs to stdout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

# Configure /app folder with scratchpads source
RUN mkdir /app
RUN wget -qO- https://github.com/NaturalHistoryMuseum/scratchpads2/archive/2.9.1.tar.gz | tar xvz -C /app --strip 1
RUN rm -fr /var/www/html && ln -s /app /var/www/html
RUN chown -R www-data /app

# Configure for drupal install
ADD settings.php /app/sites/default/settings.php
RUN chown -R www-data /app/sites/default/settings.php

# See if anything goes wrong
RUN echo "display_errors = on" >> /etc/php/5.6/apache2/php.ini

# Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

EXPOSE 80
CMD ["/run.sh"]

# Clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
