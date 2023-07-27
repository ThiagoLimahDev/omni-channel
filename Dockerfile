FROM php:8.1-fpm 

ARG user=omni
ARG uid=1000 

# Intala as dependências do sistema
RUN apt-get update && apt-get install -y git curl wget libpng-dev libonig-dev libxml2-dev zip unzip 

# Limpa o cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala as dependências do php
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Cria o usuário do sistema para rodar o composer e o artisan
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

# Instala o Redis
RUN pecl install -o -f redis &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis

# Seta o working directory
WORKDIR /var/www

# Copia as configurações personalizados do PHP
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

USER $user