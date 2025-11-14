FROM php:7-apache

ARG BUILD_DATE
ARG JOONTE_VERSION

LABEL maintainer="Sergey Sedov <serge.eximius@gmail.com>" \
      org.opencontainers.image.title="JBS" \
      org.opencontainers.image.description="Joonte Billing System - Free billing system for hosting providers. Docker image with automatic updates." \
      org.opencontainers.image.version="$JOONTE_VERSION" \
      org.opencontainers.image.authors="Sergey Sedov <serge.eximius@gmail.com>" \
      org.opencontainers.image.source="https://github.com/sergeeximius/joonte-docker" \
      org.opencontainers.image.licenses="Free" \
      org.opencontainers.image.created="$BUILD_DATE"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions apcu gd geoip imap json libxml mailparse mbstring memcached mysqli openssl tidy xml zlib && \
    a2enmod rewrite && \
    apt-get update && \
    apt-get install -y \
        cron \
        curl \
        git \
        imagemagick \
        ipmitool \
        mariadb-client \
        memcached \
        supervisor \
        unzip \
        wget \
        wkhtmltopdf && \
    rm -rf /var/lib/apt/lists/* && \
    echo "*/1 * * * * sh /var/www/html/scripts/billing/check.cron.run.sh >/dev/stdout 2>&1" > /etc/cron.d/joonte && \
    chmod 644 /etc/cron.d/joonte && \
    crontab /etc/cron.d/joonte

USER www-data
WORKDIR /var/www/html
RUN git clone https://github.com/joonte/jbs.git .

# Switch back to root for running multiple services under supervisord
USER root

# Supervisor configuration to manage services (apache, cron, memcached)
COPY supervisor/jbs.conf /etc/supervisor/conf.d/jbs.conf

# Installer patches (cache config & symlink absolute paths)
COPY patches/01-cache-config.patch /tmp/01-cache-config.patch
COPY patches/02-symlink-absolute.patch /tmp/02-symlink-absolute.patch
RUN echo "Applying installer patches (cache & symlink fixes)" && \
        patch -p0 --no-backup-if-mismatch < /tmp/01-cache-config.patch && \
        patch -p0 --no-backup-if-mismatch < /tmp/02-symlink-absolute.patch && \
        rm /tmp/*.patch || { echo 'Patch application failed'; exit 1; }

CMD ["/usr/bin/supervisord", "-n"]
