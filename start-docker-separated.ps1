# Job Applier - Quick Docker Start Script (Separated Containers)

Write-Host "Starting Job Applier with Separated Containers..." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Build and start
Write-Host "Building containers..." -ForegroundColor Yellow
docker-compose build

Write-Host "Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait a bit for services to start
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Generate APP_KEY if needed
Write-Host "Generating APP_KEY..." -ForegroundColor Yellow
docker-compose exec web php artisan key:generate --force

# Run migrations
Write-Host "Running migrations..." -ForegroundColor Yellow
docker-compose exec web php artisan migrate --force

# Clear cache
Write-Host "Clearing cache..." -ForegroundColor Yellow
docker-compose exec web php artisan config:clear
docker-compose exec web php artisan cache:clear

Write-Host ""
Write-Host "Setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Container Architecture:" -ForegroundColor Cyan
Write-Host "   Web Container: Nginx + PHP-FPM (Port 8000)" -ForegroundColor White
Write-Host "   Queue Container: Laravel Queue Worker" -ForegroundColor White
Write-Host "   Database Container: PostgreSQL (Port 5432)" -ForegroundColor White
Write-Host "   Cache Container: Redis (Port 6379)" -ForegroundColor White
Write-Host "   Scheduler Container: Laravel Cron Jobs" -ForegroundColor White
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "   Web Application: http://localhost:8000" -ForegroundColor White
Write-Host "   PostgreSQL Database: localhost:5432" -ForegroundColor White
Write-Host "   Redis: localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "   View all logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   View web logs: docker-compose logs -f web" -ForegroundColor White
Write-Host "   View queue logs: docker-compose logs -f queue" -ForegroundColor White
Write-Host "   Stop all services: docker-compose down" -ForegroundColor White
Write-Host "   Restart web only: docker-compose restart web" -ForegroundColor White
Write-Host "   Restart queue only: docker-compose restart queue" -ForegroundColor White
Write-Host "   Scale queue workers: docker-compose up -d --scale queue=3" -ForegroundColor White
Write-Host "   Access web container: docker-compose exec web bash" -ForegroundColor White
Write-Host "   Access queue container: docker-compose exec queue bash" -ForegroundColor White
