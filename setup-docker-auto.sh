#!/bin/bash

# Job Applier - Automatic Docker Setup Script
# This script creates all necessary Docker files automatically

set -e

echo "🚀 Job Applier - Automatic Docker Setup"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "composer.json" ] || [ ! -f "artisan" ]; then
    print_error "This doesn't look like a Laravel project directory!"
    print_info "Please run this script from your Laravel project root directory."
    exit 1
fi

print_status "Laravel project detected"

# Create docker directory structure
print_info "Creating Docker directory structure..."
mkdir -p docker/nginx
mkdir -p docker/supervisor

print_status "Directory structure created"

# Create nginx configuration
print_info "Creating Nginx configuration..."
cat > docker/nginx/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /mnt/d/jobapplier/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_read_timeout 300;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|svg)$ {
        expires 7d;
        access_log off;
    }
}
EOF

print_status "Nginx configuration created"

# Create supervisor configurations
print_info "Creating Supervisor configurations..."

# PHP-FPM configuration
cat > docker/supervisor/php-fpm.conf << 'EOF'
[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

# Queue worker configuration
cat > docker/supervisor/queue.conf << 'EOF'
[program:laravel-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /mnt/d/jobapplier/artisan queue:work --sleep=1 --tries=3 --timeout=90
autostart=true
autorestart=true
numprocs=1
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stopwaitsecs=3600
EOF

# Main supervisor configuration
cat > docker/supervisor/supervisord.conf << 'EOF'
[supervisord]
logfile=/dev/null
pidfile=/run/supervisord.pid
nodaemon=true

[include]
files = /etc/supervisor/conf.d/*.conf
EOF

print_status "Supervisor configurations created"

# Create entrypoint script
print_info "Creating entrypoint script..."
cat > docker/entrypoint.sh << 'EOF'
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
  app)
    echo "Starting PHP-FPM only..."
    exec php-fpm
    ;;
  queue)
    echo "Starting Supervisor queue worker..."
    exec /usr/bin/supervisord -n -c /etc/supervisord.conf
    ;;
  *)
    exec "$@"
    ;;
esac
EOF

# Make entrypoint executable
chmod +x docker/entrypoint.sh

print_status "Entrypoint script created and made executable"

# Create .dockerignore if it doesn't exist
if [ ! -f ".dockerignore" ]; then
    print_info "Creating .dockerignore..."
    cat > .dockerignore << 'EOF'
# Git
.git
.gitignore
.gitattributes

# Documentation
README.md
*.md
DOCKER_README.md
ENV_CONFIG.md

# Environment files
.env
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
storage/logs/*
!storage/logs/.gitkeep

# Cache
storage/framework/cache/*
!storage/framework/cache/.gitkeep
storage/framework/sessions/*
!storage/framework/sessions/.gitkeep
storage/framework/views/*
!storage/framework/views/.gitkeep

# Node modules
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build artifacts (will be built in container)
public/build/
public/hot
public/storage
public/mix-manifest.json

# Testing
coverage/
.phpunit.result.cache
phpunit.xml

# Docker
docker-compose.override.yml
docker-compose.*.yml
!docker-compose.yml

# Temporary files
tmp/
temp/

# Setup scripts
setup-docker.sh
setup-docker.ps1
EOF
    print_status ".dockerignore created"
fi

# Create quick start script
print_info "Creating quick start script..."
cat > start-docker.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Job Applier with Docker..."
echo "====================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Build and start
echo "🏗️  Building containers..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Wait a bit for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Generate APP_KEY if needed
echo "🔑 Generating APP_KEY..."
docker-compose exec app php artisan key:generate --force

# Run migrations
echo "🗄️  Running migrations..."
docker-compose exec app php artisan migrate --force

# Clear cache
echo "🧹 Clearing cache..."
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear

echo ""
echo "🎉 Setup completed!"
echo ""
echo "📋 Service URLs:"
echo "   • Web Application: http://localhost:8000"
echo "   • PostgreSQL Database: localhost:5432"
echo "   • Redis: localhost:6379"
echo ""
echo "📝 Useful commands:"
echo "   • View logs: docker-compose logs -f"
echo "   • Stop services: docker-compose down"
echo "   • Restart services: docker-compose restart"
echo "   • Access container: docker-compose exec app bash"
EOF

chmod +x start-docker.sh

print_status "Quick start script created"

# Display summary
echo ""
echo "🎉 Docker Setup Complete!"
echo "========================"
echo ""
echo "📁 Files created:"
echo "   • docker/nginx/default.conf"
echo "   • docker/supervisor/supervisord.conf"
echo "   • docker/supervisor/php-fpm.conf"
echo "   • docker/supervisor/queue.conf"
echo "   • docker/entrypoint.sh"
echo "   • .dockerignore"
echo "   • start-docker.sh"
echo ""
echo "🚀 Next steps:"
echo "   1. Run: ./start-docker.sh"
echo "   2. Or manually: docker-compose up -d --build"
echo "   3. Access: http://localhost:8000"
echo ""
echo "📝 Note: Make sure your .env file is configured correctly!"
echo "   • DB_HOST=postgres"
echo "   • DB_CONNECTION=pgsql"
echo "   • DB_DATABASE=laravel_queue"
echo "   • DB_USERNAME=postgres"
echo "   • DB_PASSWORD=hacken123"
echo ""
print_status "Setup completed successfully!"
