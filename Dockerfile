kFROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Mirror UGM & Install Paket Dasar
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://repo.ugm.ac.id/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://repo.ugm.ac.id/ubuntu|g' /etc/apt/sources.list

RUN apt update -y && apt install -y \
    nginx \
    php8.1-fpm \
    php8.1-cli \
    php8.1-common \
    php8.1-mysql \
    php8.1-xml \
    php8.1-xmlrpc \
    php8.1-curl \
    php8.1-gd \
    php8.1-imagick \
    php8.1-cli \
    php8.1-dev \
    php8.1-imap \
    php8.1-mbstring \
    php8.1-opcache \
    php8.1-soap \
    php8.1-zip \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Ambil Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 3. Copy file secara bertahap (PENTING untuk debugging)
COPY composer.json composer.lock* ./

# Jalankan install sebelum copy semua file (biar lebih cepat kalau ada perubahan code)
# Gunakan --ignore-platform-reqs jika masih rewel soal versi PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs || true

# 4. Baru copy semua sisa file
COPY . .

# 5. Fix Permissions & Laravel Setup
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 6. Nginx Config (Sama seperti sebelumnya)
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

EXPOSE 80

CMD mkdir -p /run/php && service php8.1-fpm start && nginx -g "daemon off;"
