# Stage 1: Composer dependencies
FROM composer:2 AS composer

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Stage 2: Build the application
FROM php:8.2-apache AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql zip

# Install Composer from the first stage
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy application code
COPY . /var/www/html

# Copy Composer vendor directory
COPY --from=composer /app/vendor /var/www/html/vendor

# Set the working directory
WORKDIR /var/www/html

# Run composer dump-autoload to regenerate autoloader
RUN composer dump-autoload --optimize

# Run artisan commands after code is in place
RUN php artisan config:clear
RUN php artisan cache:clear
RUN php artisan storage:link

# Run other setup tasks if necessary (e.g., npm install or migrations)
# RUN npm install && npm run prod

# Finish composer setup
RUN composer dump-autoload --optimize

# Stage 3: Production stage
FROM php:8.2-apache AS production

# Install runtime dependencies and PostgreSQL PHP extension
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat-openbsd \
    libzip-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo pdo_pgsql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Create a non-root user
RUN useradd -m -r -d /home/appuser appuser

# Copy application from builder stage
COPY --from=builder --chown=appuser:www-data /var/www/html /var/www/html

# Set the working directory
WORKDIR /var/www/html

# Set permissions for Laravel storage and cache
RUN chown -R appuser:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Ensure the non-root user has write access to the application
RUN chown -R appuser:www-data /var/www/html

# Ensure Laravel environment variables
ENV APP_ENV=production
ENV APP_DEBUG=false

# Apache runs on port 80 by default
EXPOSE 80

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint script as the container startup command
ENTRYPOINT ["/entrypoint.sh"]
