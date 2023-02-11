# Set master image
FROM php:8.1-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www
#RUN apk update && apk add --no-cache zip unzip build-base shadow curl 


# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Install PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions mbstring pdo_mysql exif pcntl gd bcmath
RUN docker-php-ext-configure gd --with-freetype --with-jpeg



# Install PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


#give composer executable permissions
RUN chmod +x /usr/local/bin/composer


# Add UID '1000' to www-data
RUN usermod -u 1000 www-data


# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www


# Install composer
RUN chmod +x artisan
RUN composer install

# Change current user to www
USER www-data

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
