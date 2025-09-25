# JobApplier Installation Guide

## Prerequisites

To run JobApplier, you need to have one of the following setups:

### Option 1: Using Docker (Recommended)

1. Install Docker Desktop for Windows: https://www.docker.com/products/docker-desktop
2. Make sure Docker Desktop is running
3. Open PowerShell in the project directory
4. Run the following command:
   ```
   docker-compose up -d
   ```
5. Access the application at http://localhost:8000

### Option 2: Using Local PHP Environment

1. Install PHP 8.2 or later:
   - Download from https://windows.php.net/download/
   - Or use XAMPP (https://www.apachefriends.org/index.html)

2. Install Composer:
   - Download from https://getcomposer.org/download/

3. Install project dependencies:
   ```
   composer install
   ```

4. Create and configure the .env file:
   ```
   cp .env.example .env
   ```

5. Generate application key:
   ```
   php artisan key:generate
   ```

6. Set up the database:
   - Configure your database settings in the .env file
   - Run migrations:
     ```
     php artisan migrate
     ```

7. Start the development server:
   ```
   php artisan serve
   ```

8. (Optional) Start the queue worker for email processing:
   ```
   php artisan queue:work
   ```

## Accessing the Application

After starting the server, access the application at:
- http://localhost:8000 (Docker)
- http://localhost:8000 (PHP built-in server)

## Default Credentials

- Email: Not applicable (registration required)
- Password: Set during registration

## Troubleshooting

1. If you encounter database connection issues:
   - Verify database credentials in .env file
   - Ensure the database server is running

2. If emails are not being sent:
   - Start the queue worker: `php artisan queue:work`
   - Check mail configuration in .env file

3. If you get permission errors:
   - Ensure the storage and bootstrap/cache directories are writable