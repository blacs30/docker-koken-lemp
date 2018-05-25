FROM php:7.1-fpm

ENV HOME /root
ENV DATABASE_PASSWORD koken
ENV DATABASE_HOST db
ENV DATABASE_NAME koken
ENV DATABASE_USER koken
ENV PHP_MAX_FILESIZE 100m

# Install required packages
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng16-16 \
        libpq-dev \
        busybox-static \
        netcat \
            && mkdir -p /var/spool/cron/crontabs; \
    echo '0 0 * * * find /var/www/html/storage/cache/images/* -atime +10 -exec rm  -r {} \;' > /var/spool/cron/crontabs/www-data

RUN set -ex; \
    apt-get update \
    && apt-get -y install \
        graphicsmagick \
        pwgen \
        wget \
        unzip \
        aptitude \
        libgraphicsmagick1-dev

RUN set -ex; \
    echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list.d/ffmpeg.list \
    && echo deb-src http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list.d/ffmpeg.list \
    && apt-get update \
    && apt-get install  deb-multimedia-keyring -y --allow-unauthenticated \
    && aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install ffmpeg

RUN set -ex; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    docker-php-ext-install \
        exif \
        intl \
        mbstring \
        mcrypt \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        zip \
        ; \
    pecl install \
        gmagick-beta;

# Configuration
RUN docker-php-ext-enable mcrypt gmagick

RUN    sed -i -e "s/;pm.max_requests\s*=\s*500/pm.max_requests = 500/g" /usr/local/etc/php-fpm.d/www.conf \
    && echo "cgi.fix_pathinfo=0" > /usr/local/etc/php/conf.d/pathinfo.ini \
    && echo "env[KOKEN_HOST] = 'koken-docker'" >> /usr/local/etc/php-fpm.d/www.conf \
    && cp /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/images.conf && \
    sed -i -e "s/\[www\]/[images]/" /usr/local/etc/php-fpm.d/images.conf && \
    sed -i -e "s#listen\s=\s127.0.0.1:9000.*#listen = 127.0.0.1:9090#" /usr/local/etc/php-fpm.d/images.conf &&\
    cp /usr/local/etc/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker-images.conf && \
    sed -i -e "s/\[www\]/[images]/" /usr/local/etc/php-fpm.d/zz-docker-images.conf && \
    sed -i -e "s#listen.*#listen = 9090#" /usr/local/etc/php-fpm.d/zz-docker-images.conf

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Installation helpers
ADD ./php/index.php /installer.php
ADD ./php/database.php /database.php
ADD ./php/user_setup.php /user_setup.php

# Cron
ADD ./shell/entrypoint.sh /entrypoint.sh
ADD ./shell/cron.sh /cron.sh

# Execute permissions where needed
RUN set -ex; \
    chmod +x /cron.sh \
    && chmod +x /entrypoint.sh

# Data volumes
VOLUME ["/var/www/html"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
