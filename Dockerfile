FROM php:8.2-apache

# ------------------------------
# 1️⃣ Instalar dependências do sistema
# ------------------------------
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libonig-dev libzip-dev zip curl sqlite3 libsqlite3-dev \
    && docker-php-ext-install pdo_mysql mbstring zip pdo_sqlite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------
# 2️⃣ Habilitar mod_rewrite (Laravel precisa)
# ------------------------------
RUN a2enmod rewrite

# ------------------------------
# 3️⃣ Instalar Composer
# ------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ------------------------------
# 4️⃣ Diretório de trabalho
# ------------------------------
WORKDIR /var/www/html

# ------------------------------
# 5️⃣ Copiar projeto
# ------------------------------
COPY . .

# ------------------------------
# 6️⃣ Configurar Apache vhost
# ------------------------------
COPY ./docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# ------------------------------
# 7️⃣ Criar SQLite (se usado) e garantir dono correto
# ------------------------------
RUN touch database/database.sqlite \
    && chown -R www-data:www-data /var/www/html

# ------------------------------
# 8️⃣ Variáveis de ambiente padrão
# ------------------------------
ENV DB_CONNECTION=sqlite \
    DB_DATABASE=/var/www/html/database/database.sqlite \
    APP_ENV=production \
    APP_DEBUG=false \
    CACHE_DRIVER=file \
    SESSION_DRIVER=file \
    QUEUE_CONNECTION=sync

# ------------------------------
# 9️⃣ Instalar dependências do Laravel
# ------------------------------
RUN composer install --no-dev --optimize-autoloader

# ------------------------------
# 10️⃣ Limpar caches do Laravel
# ------------------------------
RUN php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear \
    && php artisan cache:clear || true

# ------------------------------
# 11️⃣ Garantir permissões corretas (produção segura)
# ------------------------------
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# ------------------------------
# 12️⃣ Apache escuta porta 80
# ------------------------------
EXPOSE 80

# ------------------------------
# 13️⃣ Iniciar Apache
# ------------------------------
CMD ["apache2-foreground"]
