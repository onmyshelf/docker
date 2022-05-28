# Dockerfile for OnMyShelf API

FROM php:8-apache

# Install requirements
RUN apt-get update && apt-get install -y libssl-dev unzip && \
    docker-php-ext-install mysqli && docker-php-ext-enable mysqli && \
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
