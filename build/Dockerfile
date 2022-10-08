# Dockerfile for OnMyShelf API

FROM php:8-apache

# Install requirements (+ mysql client commands for backups)
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg-dev libpng-dev libpq-dev libssl-dev libzip-dev unzip zlib1g-dev mariadb-client && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install exif gd pdo pdo_mysql pdo_pgsql zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN a2enmod rewrite

# Use the default production configuration and make some changes
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^\;*upload_max_filesize =/upload_max_filesize = 128M/; s/^\;*post_max_size =/post_max_size = 128M/' "$PHP_INI_DIR/php.ini"

# Overwrite entrypoint
COPY docker-php-entrypoint /usr/local/bin/
RUN chown root:root /usr/local/bin/docker-php-entrypoint && \
    chmod 755 /usr/local/bin/docker-php-entrypoint

# Copy backup script
COPY backup.sh /
RUN chown root:root /backup.sh && \
    chmod 700 /backup.sh

# Copy web interface sources
COPY web/dist/ /var/www/html
COPY .htaccess /var/www/html

# Copy API sources
RUN mkdir -p /var/www/html/api/v1
COPY api/ /var/www/html/api/v1
