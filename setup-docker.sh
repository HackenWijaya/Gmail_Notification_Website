#!/bin/bash

# Job Applier Docker Setup Script
# This script helps you set up the Docker environment for Job Applier

set -e

echo "🚀 Job Applier Docker Setup"
echo "=========================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "✅ Docker is running"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

# Generate APP_KEY if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating APP_KEY..."
    # We'll generate this inside the container
    echo "APP_KEY will be generated during first run"
else
    echo "✅ APP_KEY already set"
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p storage/framework/{cache,sessions,views}
mkdir -p storage/logs
mkdir -p bootstrap/cache
echo "✅ Directories created"

# Set permissions (for Linux/Mac)
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
    echo "🔐 Setting permissions..."
    chmod -R 775 storage bootstrap/cache
    echo "✅ Permissions set"
fi

# Build and start containers
echo "🏗️  Building Docker containers..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Generate APP_KEY inside container
echo "🔑 Generating APP_KEY..."
docker-compose exec app php artisan key:generate --force

# Run migrations
echo "🗄️  Running database migrations..."
docker-compose exec app php artisan migrate --force

# Clear cache
echo "🧹 Clearing cache..."
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Service URLs:"
echo "   • Web Application: http://localhost:8000"
echo "   • Database: localhost:3306"
echo "   • Redis: localhost:6379"
echo ""
echo "📝 Useful commands:"
echo "   • View logs: docker-compose logs -f"
echo "   • Stop services: docker-compose down"
echo "   • Restart services: docker-compose restart"
echo "   • Access container: docker-compose exec app bash"
echo ""
echo "🔧 Next steps:"
echo "   1. Update your .env file with email credentials"
echo "   2. Visit http://localhost:8000 to test the application"
echo "   3. Check logs if you encounter any issues"
