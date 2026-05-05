FROM ubuntu:22.04

# Mencegah prompt interaktif saat instalasi paket
ENV DEBIAN_FRONTEND=noninteractive

# 1. Update dan Install dependensi langsung dari repo default Ubuntu
RUN apt-get update && apt-get install -y \
    nginx \
    php8.1-fpm \
    php8.1-cli \
    php8.1-mysql \
    php8.1-xml \
    php8.1-curl \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-zip \
    unzip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Ambil Composer terbaru dari image resmi
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Set direktori kerja
WORKDIR /var/www/html

# 4. Copy semua file project ke dalam container
COPY . .

# 5. Jalankan Composer install
# Menggunakan --ignore-platform-reqs untuk menghindari error jika ada ekstensi yang terlewat
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 6. Atur izin akses folder (PENTING untuk Laravel)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 7. Konfigurasi Nginx untuk Laravel
RUN echo 'server { \n\
    listen 80; \n\
    root /var/www/html/public; \n\
    index index.php index.html; \n\
    location / { \n\
        try_files $uri $uri/ /index.php?$query_string; \n\
    } \n\
    location ~ \.php$ { \n\
        include snippets/fastcgi-php.conf; \n\
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; \n\
    } \n\
}' > /etc/nginx/sites-available/default

# 8. Ekspos port 80
EXPOSE 80

# 9. Jalankan PHP-FPM dan Nginx secara bersamaan
# Kita buat folder /run/php manual karena Ubuntu Docker sering tidak menyediakannya
CMD mkdir -p /run/php && service php8.1-fpm start && nginx -g "daemon off;"

