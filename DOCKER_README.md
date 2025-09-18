# Job Applier - Docker Setup

Aplikasi Laravel untuk mengelola aplikasi pekerjaan dengan setup Docker yang lengkap.

## Prerequisites

- Docker Desktop atau Docker Engine
- Docker Compose
- Git

## Quick Start

1. **Clone repository dan masuk ke direktori:**
   ```bash
   git clone <repository-url>
   cd JobApplier
   ```

2. **Setup environment:**
   ```bash
   cp .env.example .env
   ```
   
   Edit file `.env` dan sesuaikan konfigurasi sesuai kebutuhan:
   - `APP_KEY`: Generate dengan `php artisan key:generate`
   - `MAIL_USERNAME` dan `MAIL_PASSWORD`: Email SMTP credentials
   - Database credentials (sudah dikonfigurasi untuk Docker)

3. **Jalankan setup script (Windows):**
   ```powershell
   .\setup-docker.ps1
   ```
   
   Atau manual:
   ```bash
   docker-compose up -d --build
   ```

4. **Setup database:**
   ```bash
   docker-compose exec app php artisan migrate
   docker-compose exec app php artisan db:seed
   ```

5. **Akses aplikasi:**
   - Web Application: http://localhost:8000
   - Database: localhost:3306
   - Redis: localhost:6379

## Services

### Main Application (`app`)
- **Port:** 8000
- **Description:** Laravel aplikasi utama dengan Nginx dan PHP-FPM
- **Features:** Web server, API endpoints, file serving

### Database (`mysql`)
- **Port:** 3306
- **Database:** jobapplier
- **Username:** jobapplier
- **Password:** jobapplier_password

### Queue Worker (`queue`)
- **Description:** Background job processing
- **Features:** Email sending, job processing

### Scheduler (`scheduler`)
- **Description:** Laravel task scheduler
- **Features:** Cron jobs, scheduled tasks

### Redis (`redis`)
- **Port:** 6379
- **Description:** Cache dan session storage

## Development Commands

### Build aplikasi
```bash
docker-compose build
```

### Jalankan aplikasi
```bash
docker-compose up -d
```

### Stop aplikasi
```bash
docker-compose down
```

### Restart service tertentu
```bash
docker-compose restart app
```

### Lihat logs
```bash
docker-compose logs -f app
docker-compose logs -f queue
```

### Masuk ke container
```bash
docker-compose exec app bash
docker-compose exec mysql mysql -u jobapplier -p jobapplier
```

### Laravel Artisan commands
```bash
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker
docker-compose exec app php artisan queue:work
```

### Composer commands
```bash
docker-compose exec app composer install
docker-compose exec app composer update
```

### NPM commands
```bash
docker-compose exec app npm install
docker-compose exec app npm run dev
docker-compose exec app npm run build
```

## Production Deployment

1. **Update environment untuk production:**
   ```bash
   APP_ENV=production
   APP_DEBUG=false
   ```

2. **Build production image:**
   ```bash
   docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
   ```

3. **Setup SSL (opsional):**
   - Gunakan reverse proxy seperti Nginx atau Traefik
   - Update `APP_URL` ke domain production

## Troubleshooting

### Database connection issues
```bash
# Check database status
docker-compose exec mysql mysqladmin ping

# Reset database
docker-compose down -v
docker-compose up -d
```

### Permission issues
```bash
# Fix storage permissions
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Queue not processing
```bash
# Check queue worker
docker-compose exec queue php artisan queue:work --verbose

# Restart queue service
docker-compose restart queue
```

### Clear cache
```bash
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

## File Structure

```
JobApplier/
├── docker/
│   ├── entrypoint.sh          # Container startup script
│   ├── nginx/
│   │   └── default.conf       # Nginx configuration
│   └── supervisor/
│       ├── supervisord.conf   # Supervisor main config
│       ├── php-fpm.conf       # PHP-FPM process config
│       └── queue.conf         # Queue worker config
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yml         # Multi-service orchestration
├── .dockerignore             # Docker build exclusions
└── .env.example              # Environment template
```

## Performance Optimization

### Production optimizations:
- OPcache enabled
- Composer autoloader optimized
- Assets pre-built
- Multi-stage build untuk size optimization

### Scaling:
- Queue workers dapat di-scale secara terpisah
- Database dapat menggunakan external service
- Redis dapat menggunakan managed service

## Security Notes

- Change default passwords di production
- Use environment variables untuk sensitive data
- Enable SSL/TLS di production
- Regular security updates untuk base images
- Use secrets management untuk production credentials
