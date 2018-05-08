FROM php:5.6-apache

# Install packages
RUN apt-get update
RUN apt-get -y install wget libxml2-dev libpng-dev libmagickwand-dev \
                       imagemagick libgmp-dev zlib1g-dev --no-install-recommends
RUN pecl install imagick && docker-php-ext-enable imagick
# Fixing "configure: error: Unable to locate gmp.h"
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN docker-php-ext-install pdo pdo_mysql xml gd mbstring gmp zip

# Enable mod_rewrite
RUN a2enmod rewrite
COPY sp2.conf /etc/apache2/conf-enabled/sp2.conf

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