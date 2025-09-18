# Job Applier - Automatic Docker Setup Script for Windows PowerShell
# This script creates all necessary Docker files automatically

Write-Host "🚀 Job Applier - Automatic Docker Setup" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "composer.json") -or -not (Test-Path "artisan")) {
    Write-Host "❌ This doesn't look like a Laravel project directory!" -ForegroundColor Red
    Write-Host "ℹ️  Please run this script from your Laravel project root directory." -ForegroundColor Blue
    exit 1
}

Write-Host "✅ Laravel project detected" -ForegroundColor Green

# Create docker directory structure
Write-Host "ℹ️  Creating Docker directory structure..." -ForegroundColor Blue
New-Item -ItemType Directory -Path "docker\nginx" -Force | Out-Null
New-Item -ItemType Directory -Path "docker\supervisor" -Force | Out-Null

Write-Host "✅ Directory structure created" -ForegroundColor Green

# Create nginx configuration
Write-Host "ℹ️  Creating Nginx configuration..." -ForegroundColor Blue
$nginxConfig = @"
server {
    listen 80;
    server_name localhost;
    root /mnt/d/jobapplier/public;
    index index.php index.html;

    location / {
        try_files `$uri `$uri/ /index.php?`$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME `$realpath_root`$fastcgi_script_name;
        fastcgi_param PATH_INFO `$fastcgi_path_info;
        fastcgi_read_timeout 300;
    }

    location ~* \.(jpg|jpeg|png|gif|css|js|ico|svg)$ {
        expires 7d;
        access_log off;
    }
}
"@
$nginxConfig | Out-File -FilePath "docker\nginx\default.conf" -Encoding UTF8

Write-Host "✅ Nginx configuration created" -ForegroundColor Green

# Create supervisor configurations
Write-Host "ℹ️  Creating Supervisor configurations..." -ForegroundColor Blue

# PHP-FPM configuration
$phpFpmConfig = @"
[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
"@
$phpFpmConfig | Out-File -FilePath "docker\supervisor\php-fpm.conf" -Encoding UTF8

# Queue worker configuration
$queueConfig = @"
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
"@
$queueConfig | Out-File -FilePath "docker\supervisor\queue.conf" -Encoding UTF8

# Main supervisor configuration
$supervisorConfig = @"
[supervisord]
logfile=/dev/null
pidfile=/run/supervisord.pid
nodaemon=true

[include]
files = /etc/supervisor/conf.d/*.conf
"@
$supervisorConfig | Out-File -FilePath "docker\supervisor\supervisord.conf" -Encoding UTF8

Write-Host "✅ Supervisor configurations created" -ForegroundColor Green

# Create entrypoint script
Write-Host "ℹ️  Creating entrypoint script..." -ForegroundColor Blue
$entrypointScript = @"
#!/usr/bin/env bash
set -euo pipefail

role=`$1:-app}

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
if [ -n "`${DB_HOST:-}" ] && [ -n "`${DB_DATABASE:-}" ]; then
  echo "Waiting for database `$DB_HOST..."
  for i in {1..60}; do
    if php -r 'try{ `$conn=getenv("DB_CONNECTION"); `$dsn=(
        `$conn=="mysql" ? "mysql:host=".getenv("DB_HOST").";port=".getenv("DB_PORT").";dbname=".getenv("DB_DATABASE") : (
        `$conn=="pgsql" ? "pgsql:host=".getenv("DB_HOST").";port=".getenv("DB_PORT").";dbname=".getenv("DB_DATABASE") :
        "sqlite:".getenv("DB_DATABASE")
      )
    ); new PDO(`$dsn, getenv("DB_USERNAME"), getenv("DB_PASSWORD")); echo "ok"; }catch(Exception `$e){ echo ""; }' | grep -q ok; then
      break
    fi
    sleep 1
  done
fi

php artisan migrate --force || true

case "`$role" in
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
    exec "`$@"
    ;;
esac
"@
$entrypointScript | Out-File -FilePath "docker\entrypoint.sh" -Encoding UTF8

Write-Host "✅ Entrypoint script created" -ForegroundColor Green

# Create .dockerignore if it doesn't exist
if (-not (Test-Path ".dockerignore")) {
    Write-Host "ℹ️  Creating .dockerignore..." -ForegroundColor Blue
    $dockerIgnore = @"
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
"@
    $dockerIgnore | Out-File -FilePath ".dockerignore" -Encoding UTF8
    Write-Host "✅ .dockerignore created" -ForegroundColor Green
}

# Create quick start script
Write-Host "ℹ️  Creating quick start script..." -ForegroundColor Blue
$startScript = @"
# Job Applier - Quick Docker Start Script

Write-Host "🚀 Starting Job Applier with Docker..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Build and start
Write-Host "🏗️  Building containers..." -ForegroundColor Yellow
docker-compose build

Write-Host "🚀 Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait a bit for services to start
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Generate APP_KEY if needed
Write-Host "🔑 Generating APP_KEY..." -ForegroundColor Yellow
docker-compose exec app php artisan key:generate --force

# Run migrations
Write-Host "🗄️  Running migrations..." -ForegroundColor Yellow
docker-compose exec app php artisan migrate --force

# Clear cache
Write-Host "🧹 Clearing cache..." -ForegroundColor Yellow
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear

Write-Host ""
Write-Host "🎉 Setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Service URLs:" -ForegroundColor Cyan
Write-Host "   • Web Application: http://localhost:8000" -ForegroundColor White
Write-Host "   • PostgreSQL Database: localhost:5432" -ForegroundColor White
Write-Host "   • Redis: localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Cyan
Write-Host "   • View logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   • Stop services: docker-compose down" -ForegroundColor White
Write-Host "   • Restart services: docker-compose restart" -ForegroundColor White
Write-Host "   • Access container: docker-compose exec app bash" -ForegroundColor White
"@
$startScript | Out-File -FilePath "start-docker.ps1" -Encoding UTF8

Write-Host "✅ Quick start script created" -ForegroundColor Green

# Display summary
Write-Host ""
Write-Host "🎉 Docker Setup Complete!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Files created:" -ForegroundColor Cyan
Write-Host "   • docker\nginx\default.conf" -ForegroundColor White
Write-Host "   • docker\supervisor\supervisord.conf" -ForegroundColor White
Write-Host "   • docker\supervisor\php-fpm.conf" -ForegroundColor White
Write-Host "   • docker\supervisor\queue.conf" -ForegroundColor White
Write-Host "   • docker\entrypoint.sh" -ForegroundColor White
Write-Host "   • .dockerignore" -ForegroundColor White
Write-Host "   • start-docker.ps1" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Run: .\start-docker.ps1" -ForegroundColor White
Write-Host "   2. Or manually: docker-compose up -d --build" -ForegroundColor White
Write-Host "   3. Access: http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "📝 Note: Make sure your .env file is configured correctly!" -ForegroundColor Yellow
Write-Host "   • DB_HOST=postgres" -ForegroundColor White
Write-Host "   • DB_CONNECTION=pgsql" -ForegroundColor White
Write-Host "   • DB_DATABASE=laravel_queue" -ForegroundColor White
Write-Host "   • DB_USERNAME=postgres" -ForegroundColor White
Write-Host "   • DB_PASSWORD=hacken123" -ForegroundColor White
Write-Host ""
Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
