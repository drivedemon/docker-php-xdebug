ARG PHP_VERSION=8.1.3
ARG COMPOSER_VERSION=2.4.1

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-fpm

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV CHROMIUM_PATH=/usr/bin/chromium-browser

# Install system dependencies
RUN apt-get update -y
RUN apt-get install -y libenchant-2-dev
RUN apt-get install -y --no-install-recommends \
    chromium \
    curl \
    git \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libc-client-dev \
    libkrb5-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libmpc-dev \
    libldap2-dev \
    libpq-dev \
    libedit-dev \
    libsnmp-dev \
    libpspell-dev \
    libsqlite3-dev \
    libtidy-dev \
    libxslt-dev \
    aspell-en \
    unzip \
    unixodbc-dev \
    zip

# PDF
RUN apt-get install -y --allow-unauthenticated \
    libgtk2.0-0 \
    libgdk-pixbuf2.0-0 \
    libfontconfig1 \
    libxrender1 \
    libx11-6 \
    libglib2.0-0 \
    libxft2 \
    libfreetype6 \
    libc6 \
    zlib1g \
    libstdc++6 \
    libgcc1 \
    libpng-dev \
    libwebp-dev \
    libjpeg-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis
RUN docker-php-ext-configure imap \
        --with-imap \
        --with-kerberos \
        --with-imap-ssl \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug
RUN docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
RUN docker-php-ext-configure exif --enable-exif
RUN docker-php-ext-install \
    exif \
    bcmath \
    bz2 \
    curl \
    dba \
    enchant \
    gd \
    gmp \
    intl \
    imap \
    ldap \
    mbstring \
    pdo_odbc \
    opcache \
    pdo_mysql \
    pgsql \
    pspell \
    snmp \
    soap \
    pdo_sqlite \
    tidy \
    xml \
    xsl \
    pcntl \
    posix \
    zip
#    readline \

COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./php.ini "$PHP_INI_DIR/php.ini"

# Get Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install NodeJS from node_base
RUN curl --silent --location https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn
