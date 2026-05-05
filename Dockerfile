FROM ubuntu:22.04

# Agar tidak muncul prompt interaktif saat install
ENV DEBIAN_FRONTEND=noninteractive

# Ganti repository ke mirror UGM
RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://repo.ugm.ac.id/ubuntu|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu|http://repo.ugm.ac.id/ubuntu|g' /etc/apt/sources.list

# Install packages
RUN apt update -y && \
    apt install -y \
    nginx \
    php8.1-fpm \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-mysql \
    php8.1-gd \
    php8.1-cli \
    php8.1-zip \
    unzip \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Install Composer (PENTING: Agar kamu bisa install dependensi Laravel)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy aplikasi
COPY . .

# Install dependensi Laravel & atur permission
RUN composer install --no-dev --optimize-autoloader --no-interaction && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 storage bootstrap/cache

# Atur konfigurasi Nginx agar mengarah ke Laravel /public dan support PHP
RUN echo 'server { \n\
    listen 80; \n\
    server_name _; \n\
    root /var/www/html/public; \n\
    add_header X-Frame-Options "SAMEORIGIN"; \n\
    add_header X-Content-Type-Options "nosniff"; \n\
    index index.php; \n\
    charset utf-8; \n\
    location / { \n\
        try_files $uri $uri/ /index.php?$query_string; \n\
    } \n\
    location ~ \.php$ { \n\
        include snippets/fastcgi-php.conf; \n\
        fastcgi_pass unix:/run/php/php8.1-fpm.sock; \n\
    } \n\
    location ~ /\.ht { \n\
        deny all; \n\
    } \n\
}' > /etc/nginx/sites-available/default

EXPOSE 80

# Jalankan PHP-FPM dan Nginx
# Kita perlu membuat folder /run/php agar socket FPM bisa tercipta
CMD mkdir -p /run/php && service php8.1-fpm start && nginx -g "daemon off;"
