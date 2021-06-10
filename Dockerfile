ARG PHP_VERSION=8.0
ARG COMPOSER_VERSION=2.0.12

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    libenchant-dev \
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
RUN docker-php-ext-configure gd --enable-gd --with-jpeg
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
RUN docker-php-ext-install \
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
    readline \
    snmp \
    soap \
    pdo_sqlite \
    tidy \
    xml \
    xsl \
    zip

COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY  ./php.ini "$PHP_INI_DIR/php.ini"

# Get Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install NodeJS from node_base
RUN curl --silent --location https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn
