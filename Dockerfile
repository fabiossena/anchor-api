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

# Habilitar mod_rewrite (Laravel precisa)
RUN a2enmod rewrite

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Diretório de trabalho
WORKDIR /var/www/html

# Copiar projeto
COPY . .

# RUN php artisan key:generate || true && \
#     php artisan migrate --force || true && \
#     php artisan optimize:clear && \
#     php artisan config:clear && \
#     php artisan route:clear && \
#     php artisan view:clear

# Configuração do Apache (DocumentRoot /public)
COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Variáveis de ambiente (SQLite)
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/var/www/html/database/database.sqlite

# Instalar dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Apache escuta na porta 80
EXPOSE 80

# Iniciar Apache
CMD ["apache2-foreground"]
