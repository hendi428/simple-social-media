FROM ubuntu:22.04

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

# Start PHP-FPM
RUN service php8.1-fpm start

# Copy aplikasi
COPY . /var/www/html/

# Copy startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
