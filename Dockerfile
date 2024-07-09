FROM php:8.3-fpm-alpine
WORKDIR /var/www

LABEL maintainer="Jeffrey Santoso <jeffrey.k.santoso@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
ENV PHP_DISPLAY_ERRORS  off
ENV PHP_ERROR_REPORTING  E_ALL & ~E_NOTICE
ENV XDEBUG_HOST host.docker.internal
ENV XDEBUG_PORT 9000
ENV XDEBUG_IDE_KEY PHPSTORM

RUN apk update && apk upgrade 
RUN apk add --no-cache \
        vim \
        libpng-dev \
        libldap \
        libcurl \
        libbz2 \ 
        libpq-dev \
        libxml2-dev \
        libzip \
        libzip-dev \
        libmemcached-dev \
        libmcrypt-dev \
        readline \
        librabbitmq-dev \
        unzip \
        oniguruma \
        oniguruma-dev \
        iproute2 \
        iputils-ping \
        imagemagick \
        imagemagick-dev \
        lftp \
        poppler-utils \
        zip \
        pdftk \
        expect \
        xorriso \
        dcmtk \
        unixodbc \
        unixodbc-dev

RUN  apk cache clean && rm -rf /var/cache/apk/* && rm -rf /etc/apk/cache/*

RUN  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo alias ll=\'ls -lF\' >> /root/.bashrc

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN /usr/local/bin/docker-php-ext-install mbstring
RUN /usr/local/bin/docker-php-ext-install iconv
RUN /usr/local/bin/docker-php-ext-install gd
RUN /usr/local/bin/docker-php-ext-install bz2
RUN /usr/local/bin/docker-php-ext-install pdo
RUN /usr/local/bin/docker-php-ext-install pdo_pgsql
RUN /usr/local/bin/docker-php-ext-install pgsql
RUN /usr/local/bin/docker-php-ext-install soap
RUN /usr/local/bin/docker-php-ext-install xml
RUN /usr/local/bin/docker-php-ext-install zip
RUN /usr/local/bin/docker-php-ext-install bcmath
RUN /usr/local/bin/docker-php-ext-install ldap
RUN /usr/local/bin/docker-php-ext-install curl
RUN /usr/local/bin/docker-php-ext-install sockets
RUN /usr/local/bin/docker-php-ext-install ctype

RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
RUN docker-php-ext-install pdo_odbc

ADD etc/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

RUN pecl install xmlrpc-beta
RUN docker-php-ext-enable xmlrpc

RUN pecl install redis
RUN docker-php-ext-enable redis

RUN pecl install amqp-beta
RUN docker-php-ext-enable amqp

RUN pecl install xdebug

RUN pecl install memcached
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN pecl install imagick
RUN docker-php-ext-enable imagick

ADD conf.d/php.ini /etc/php/8.3/php.ini
ADD conf.d/xdebug.ini /etc/php/8.3/xdebug.ini

RUN mkdir -p /etc/php/8.3/fpm/conf.d
RUN ln -s /etc/php/8.3/php.ini /etc/php/8.3/fpm/conf.d/90-tris.ini
RUN ln -s /etc/php/8.3/xdebug.ini /etc/php/8.3/fpm/conf.d/90-xdebug.ini

RUN mkdir -p /etc/php/8.3/cli/conf.d
RUN ln -s /etc/php/8.3/php.ini /etc/php/8.3/cli/conf.d/90-tris.ini
RUN ln -s /etc/php/8.3/xdebug.ini /etc/php/8.3/cli/conf.d/90-xdebug.ini

RUN mkdir -p /usr/local/etc/php/conf.d
RUN ln -s /etc/php/8.3/php.ini /usr/local/etc/php/conf.d/90-tris.ini
RUN ln -s /etc/php/8.3/xdebug.ini /usr/local/etc/php/conf.d/90-xdebug.ini

WORKDIR /var/www/html

EXPOSE 9000

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh", "php-fpm"]
