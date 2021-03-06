FROM php:5.6-apache

# Depend on host user's uid being 1000 so we can write to mounted volumes
RUN usermod -u 1000 www-data

# Install packages
RUN apt-get update
RUN apt-get -y install wget libxml2-dev libpng-dev libmagickwand-dev \
                       imagemagick libgmp-dev zlib1g-dev ssmtp \
                       libfreetype6-dev libjpeg62-turbo-dev \
                       libgd-dev libpng12-dev cron \
                       --no-install-recommends
RUN pecl install imagick && docker-php-ext-enable imagick
# Fixing "configure: error: Unable to locate gmp.h"
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo pdo_mysql xml gd mbstring gmp zip

RUN apt-get install -y \
        libmcrypt-dev \
    && docker-php-ext-install mcrypt \
    && apt-get remove -y \
        libmcrypt-dev \
    && apt-get install -y \
        libmcrypt4 \
&& apt-get autoremove -y

RUN apt-get install -y mysql-client

# Enable mod_rewrite
RUN a2enmod rewrite
COPY sp2.conf /etc/apache2/conf-enabled/sp2.conf

# Install drush
RUN wget https://github.com/drush-ops/drush/releases/download/8.1.17/drush.phar
# Test your install.
RUN php drush.phar core-status

# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH.
RUN chmod +x drush.phar
RUN mv drush.phar /usr/local/bin/drush

# Optional. Enrich the bash startup file with completion and aliases.
# RUN drush init

# Configure /app folder with scratchpads source
RUN mkdir /app
RUN chown www-data /app
RUN rm -fr /var/www/html && ln -s /app /var/www/html
USER www-data
ARG VERSION=none
RUN (\
      wget -qO- https://github.com/NaturalHistoryMuseum/scratchpads2/archive/${VERSION}.tar.gz\
      || echo "wget: Release version \"$VERSION\" not found" 1>&2\
     ) | tar xvz -C /app --strip 1

# Enable error logging
COPY php.ini /usr/local/etc/php/

# Configure for drupal install
ADD settings.php /app/sites/default/settings.php
ADD drushrc.php /app/sites/default/drushrc.php

USER root

# Clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./entrypoint.sh /
CMD ["/bin/sh", "-c", "/entrypoint.sh"]

ENV MYSQL_PASSWORD=platypodes \
      MYSQL_DATABASE=sp2 \
      MYSQL_USER=root \
      MYSQL_HOST=db \
      SOLR_HOSTNAME=solr \
      SOLR_CORE=scratchpads2 \
      BASE_URL=http://localhost \
      SMTP_MAILHUB=smtp
