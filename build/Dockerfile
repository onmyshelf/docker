# Dockerfile for OnMyShelf API

FROM php:8-apache

# Install requirements (+ mysql client commands for backups)
RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg-dev libpng-dev libpq-dev libssl-dev libzip-dev unzip zlib1g-dev mariadb-client && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install exif gd pdo pdo_mysql pdo_pgsql zip && \
    a2enmod rewrite && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^\;*upload_max_filesize =/upload_max_filesize = 128M/; s/^\;*post_max_size =/post_max_size = 128M/' "$PHP_INI_DIR/php.ini" && \
    mkdir -p /var/www/html/api/v1

HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl --fail http://localhost/api/v1/ || exit 1

# Overwrite entrypoint
COPY docker-php-entrypoint /usr/local/bin/
# Copy backup script
COPY backup.sh /

# Fix script permissions
RUN chown root:root /backup.sh /usr/local/bin/docker-php-entrypoint && \
    chmod 700 /backup.sh && \
    chmod 755 /usr/local/bin/docker-php-entrypoint

# Copy web interface sources
COPY web/dist/ /var/www/html
COPY .htaccess /var/www/html

# Copy API sources
COPY api/ /var/www/html/api/v1
