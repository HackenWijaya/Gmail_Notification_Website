FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
    
# Install PHP extensions (without GD to avoid build issues)
RUN docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy supervisor configurations
COPY docker/supervisor/php-fpm.conf /etc/supervisor/conf.d/
COPY docker/supervisor/queue.conf /etc/supervisor/conf.d/
COPY docker/supervisor/supervisord.conf /etc/supervisor/
COPY docker/supervisor/supervisorctl.conf /etc/supervisor/

# Create log directory for supervisor
RUN mkdir -p /var/log/supervisor

# Set working directory
WORKDIR /var/www

# Copy existing application directory
COPY . /var/www

# Install PHP dependencies
RUN composer install --no-scripts

# Change ownership of files
RUN chown -R www-data:www-data /var/www

# Expose port 9000 and start supervisor
EXPOSE 9000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]