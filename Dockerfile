FROM php:8.2-fpm

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql mbstring zip pdo_sqlite

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Setar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos do projeto
COPY . .

ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=database/database.sqlite

# Instalar dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Permissões de storage e cache
RUN chown -R www-data:www-data storage bootstrap/cache

# Expor porta do PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]