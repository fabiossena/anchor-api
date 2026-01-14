FROM php:8.2-apache

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    sqlite3 \
    libsqlite3-dev \
    && docker-php-ext-install pdo_mysql mbstring zip pdo_sqlite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Setar diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos do projeto
COPY . .

RUN a2enmod rewrite

COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf


# Variáveis de ambiente para SQLite
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/var/www/html/database/database.sqlite

# Instalar dependências PHP do Laravel
RUN composer install --no-dev --optimize-autoloader

# Permissões de storage e cache
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chown -R www-data:www-data /var/www/html

# Expor porta do PHP-FPM
EXPOSE 9000

CMD ["php-fpm"]
