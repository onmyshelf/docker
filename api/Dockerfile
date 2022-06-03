# Dockerfile for OnMyShelf API

FROM php:8-apache

# Install requirements
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg-dev libpng-dev libssl-dev unzip zlib1g-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install exif gd mysqli && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN a2enmod rewrite

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Overwrite entrypoint
COPY docker-php-entrypoint /usr/local/bin/
RUN chown root:root /usr/local/bin/docker-php-entrypoint && \
    chmod 755 /usr/local/bin/docker-php-entrypoint

# Copy sources
RUN mkdir -p /var/www/html/api/v1
COPY src/ /var/www/html/api/v1
