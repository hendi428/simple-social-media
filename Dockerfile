FROM php:8.2-fpm-alpine

# Install extension pendukung
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer secara otomatis
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Install dependensi Laravel (PENTING)
RUN composer install --no-dev --optimize-autoloader

RUN cp .env.example .env || true
RUN php artisan key:generate || true
RUN chmod -R 777 storage bootstrap/cache

# Sesuaikan port dengan gambar panduanmu (8000)
CMD php artisan serve --host=0.0.0.0 --port=8000
