# Job Applier - Quick Docker Start Script

Write-Host "Starting Job Applier with Docker..." -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

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
Start-Sleep -Seconds 10

# Generate APP_KEY if needed
Write-Host "Generating APP_KEY..." -ForegroundColor Yellow
docker-compose exec app php artisan key:generate --force

# Run migrations
Write-Host "Running migrations..." -ForegroundColor Yellow
docker-compose exec app php artisan migrate --force

# Clear cache
Write-Host "Clearing cache..." -ForegroundColor Yellow
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear

Write-Host ""
Write-Host "Setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "   Web Application: http://localhost:8000" -ForegroundColor White
Write-Host "   PostgreSQL Database: localhost:5432" -ForegroundColor White
Write-Host "   Redis: localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "   View logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   Stop services: docker-compose down" -ForegroundColor White
Write-Host "   Restart services: docker-compose restart" -ForegroundColor White
Write-Host "   Access container: docker-compose exec app bash" -ForegroundColor White