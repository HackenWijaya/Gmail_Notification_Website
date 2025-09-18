# Job Applier Docker Setup Script for Windows PowerShell
# This script helps you set up the Docker environment for Job Applier

Write-Host "🚀 Job Applier Docker Setup" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Create necessary directories
Write-Host "📁 Creating necessary directories..." -ForegroundColor Yellow
$directories = @(
    "storage\framework\cache",
    "storage\framework\sessions", 
    "storage\framework\views",
    "storage\logs",
    "bootstrap\cache"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✅ Directories created" -ForegroundColor Green

# Build and start containers
Write-Host "🏗️  Building Docker containers..." -ForegroundColor Yellow
docker-compose build

Write-Host "🚀 Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Generate APP_KEY inside container
Write-Host "🔑 Generating APP_KEY..." -ForegroundColor Yellow
docker-compose exec app php artisan key:generate --force

# Run migrations
Write-Host "🗄️  Running database migrations..." -ForegroundColor Yellow
docker-compose exec app php artisan migrate --force

# Clear cache
Write-Host "🧹 Clearing cache..." -ForegroundColor Yellow
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear

Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
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
Write-Host ""
Write-Host "🔧 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Update your .env file with email credentials" -ForegroundColor White
Write-Host "   2. Visit http://localhost:8000 to test the application" -ForegroundColor White
Write-Host "   3. Check logs if you encounter any issues" -ForegroundColor White
