@echo off
echo Checking for PHP...
php --version >nul 2>&1
if %errorlevel% == 0 (
    echo PHP is installed
    echo Starting Laravel development server...
    php artisan serve
) else (
    echo PHP is not installed on this system
    echo Please install PHP 8.2 or later to run this application
    echo Or use Docker to run the application
    pause
)