#!/bin/bash
set -eu

# Ensure storage directories exist
mkdir -p /var/www/app/storage/logs \
         /var/www/app/storage/framework/cache \
         /var/www/app/storage/framework/sessions \
         /var/www/app/storage/framework/views \
         /var/www/app/bootstrap/cache

chown -R www-data:www-data /var/www/app/storage /var/www/app/bootstrap/cache

# Validate required env vars
: "${APP_KEY:?APP_KEY is required}"
: "${APP_URL:?APP_URL is required}"
: "${DB_HOST:?DB_HOST is required}"
: "${DB_PORT:?DB_PORT is required}"
: "${DB_DATABASE:?DB_DATABASE is required}"
: "${DB_USERNAME:?DB_USERNAME is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"

# Ensure php-fpm passes environment variables through
if [ -f /usr/local/etc/php-fpm.d/www.conf ]; then
  sed -i 's/^[;[:space:]]*clear_env[[:space:]]*=.*/clear_env = no/' /usr/local/etc/php-fpm.d/www.conf
fi

# Laravel optimization
php artisan optimize:clear
php artisan migrate --force

# First-run: seed database and create initial account if no accounts exist
ACCOUNT_COUNT=$(php artisan tinker --execute="echo \App\Models\Account::count();" 2>/dev/null || echo "0")
if [ "$ACCOUNT_COUNT" = "0" ]; then
  echo "No accounts found — running first-time setup..."
  php artisan db:seed --force

  # Build create-account arguments from env vars
  ACCOUNT_ARGS=""
  if [ -n "${IN_USER_EMAIL:-}" ]; then
    ACCOUNT_ARGS="$ACCOUNT_ARGS --email ${IN_USER_EMAIL}"
  fi
  if [ -n "${IN_PASSWORD:-}" ]; then
    ACCOUNT_ARGS="$ACCOUNT_ARGS --password ${IN_PASSWORD}"
  fi

  php artisan ninja:create-account $ACCOUNT_ARGS
  php artisan cache:clear
  echo "Initial account created successfully."
fi

echo "=== Document root check ==="
DOCROOT="/var/www/app/public"
INDEX_FILE="$DOCROOT/index.php"
echo "pwd=$(pwd)"
echo "user=$(id -un)"
if [ -f "$INDEX_FILE" ]; then
  echo "FOUND $INDEX_FILE"
else
  echo "MISSING $INDEX_FILE"
fi
ls -ld /var/www/app "$DOCROOT" "$INDEX_FILE" 2>/dev/null || true
if [ -f /usr/local/etc/php-fpm.d/www.conf ]; then
  echo "php-fpm pool path settings:"
  awk -F= '/^[[:space:]]*(chroot|chdir)[[:space:]]*=/{k=$1;v=$2;gsub(/^[[:space:]]+|[[:space:]]+$/, "", k);gsub(/^[[:space:]]+|[[:space:]]+$/, "", v);print k"="v}' /usr/local/etc/php-fpm.d/www.conf || true
else
  echo "php-fpm pool config not found"
fi
echo "=== End document root check ==="

# Start services
php-fpm -D
exec nginx -g 'daemon off;'
