#!/usr/bin/env bash
set -euo pipefail

role=${1:-app}

cd /mnt/d/jobapplier

# Ensure composer deps
if [ ! -d vendor ]; then
  composer install --no-interaction --no-progress --prefer-dist
fi

# Ensure .env
if [ ! -f .env ] && [ -f .env.example ]; then
  cp .env.example .env
fi

php artisan key:generate --force || true

# Storage permissions
mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache
chmod -R ug+rw storage bootstrap/cache || true

# Wait for DB if configured
if [ -n "${DB_HOST:-}" ] && [ -n "${DB_DATABASE:-}" ]; then
  echo "Waiting for database ${DB_HOST}..."
  for i in {1..60}; do
    if php -r 'try{ $conn=getenv("DB_CONNECTION"); $dsn=(
        $conn=="mysql" ? "mysql:host=".getenv("DB_HOST").";port=".getenv("DB_PORT").";dbname=".getenv("DB_DATABASE") : (
        $conn=="pgsql" ? "pgsql:host=".getenv("DB_HOST").";port=".getenv("DB_PORT").";dbname=".getenv("DB_DATABASE") :
        "sqlite:".getenv("DB_DATABASE")
      )
    ); new PDO($dsn, getenv("DB_USERNAME"), getenv("DB_PASSWORD")); echo "ok"; }catch(Exception $e){ echo ""; }' | grep -q ok; then
      break
    fi
    sleep 1
  done
fi

php artisan migrate --force || true

case "$role" in
  supervisor)
    echo "Starting Supervisor (php-fpm + queue worker)..."
    exec /usr/bin/supervisord -n -c /etc/supervisord.conf
    ;;
  web)
    echo "Starting Supervisor (php-fpm only)..."
    exec /usr/bin/supervisord -n -c /etc/supervisord.conf
    ;;
  app)
    echo "Starting PHP-FPM only..."
    exec php-fpm
    ;;
  queue)
    echo "Starting Queue Worker..."
    exec php artisan queue:work --sleep=1 --tries=3 --timeout=90
    ;;
  *)
    exec "$@"
    ;;
esac