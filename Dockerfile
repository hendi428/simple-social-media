FROM php:8.2-fpm-alpine

# 1. Install sistem dependensi untuk Alpine (PENTING)
RUN apk add --no-cache \
    git \
    unzip \
    libzip-dev \
    icu-dev \
    $PHPIZE_DEPS

# 2. Install extension PHP
RUN docker-php-ext-install pdo pdo_mysql zip

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# 4. Install dependensi Laravel
# Tambahkan --ignore-platform-reqs jika masih ada error ekstensi
RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN cp .env.example .env || true
RUN php artisan key:generate || true
RUN chmod -R 777 storage bootstrap/cache

CMD php artisan serve --host=0.0.0.0 --port=8000
