#!/bin/sh
set -eu

# Prepare Laravel dirs on the mounted volume
mkdir -p /var/www/app/storage/logs \
         /var/www/app/storage/framework/cache \
         /var/www/app/storage/framework/sessions \
         /var/www/app/storage/framework/views \
         /var/www/app/bootstrap/cache

chown -R www-data:www-data /var/www/app/storage /var/www/app/bootstrap/cache

# Clear stale caches so runtime env is honored
php artisan optimize:clear
php artisan migrate --force

# Start php-fpm in background, nginx in foreground (PID 1)
php-fpm -D
exec nginx -g 'daemon off;'
