FROM ubuntu:22.04

# Install packages
RUN apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    nginx \
    php8.1-fpm \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-curl \
    php8.1-mysql \
    php8.1-gd \
    php8.1-cli \
    unzip \
    nano \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Copy aplikasi
COPY . /var/www/html/

# Expose port
EXPOSE 80

# Jalankan service saat container running
CMD service php8.1-fpm start && nginx -g "daemon off;"
