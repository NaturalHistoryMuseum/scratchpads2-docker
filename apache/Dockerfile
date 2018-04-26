FROM php:5.6-apache

# Install packages
RUN apt-get update
RUN apt-get -y install wget libxml2-dev libpng-dev libmagickwand-dev imagemagick --no-install-recommends
RUN pecl install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-install pdo pdo_mysql xml gd mbstring

# Configure /app folder with scratchpads source
RUN mkdir /app
RUN chown www-data /app
RUN rm -fr /var/www/html && ln -s /app /var/www/html
USER www-data
RUN wget -qO- https://github.com/NaturalHistoryMuseum/scratchpads2/archive/2.9.1.tar.gz | tar xvz -C /app --strip 1

# Enable error logging
COPY php.ini /usr/local/etc/php/

# Configure for drupal install
ADD settings.php /app/sites/default/settings.php

# Clean up
USER root
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
