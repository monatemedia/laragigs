#!/bin/bash

set -e

echo "Changing to the correct directory..."
cd /var/www/html
echo "Current directory: $(pwd)"

echo "Checking for artisan file..."
if [ ! -f artisan ]; then
    echo "artisan file not found!"
    exit 1
fi

echo "Setting permissions for artisan..."
chmod +x artisan

echo "Waiting for database connection..."
until nc -z $DB_HOST $DB_PORT; do
    echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
    sleep 5
done

echo "Database is up!"

# Check if any public tables exist
TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USERNAME -d $DB_DATABASE -tAc "SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';")

if [ "$TABLE_COUNT" -gt "0" ]; then
    echo "✅ Database already has $TABLE_COUNT tables. Skipping migrations and seeders."
else
    echo "⚙️ No tables found. Running migrations and seeders..."

    echo "Running migrations..."
    php artisan migrate --force

    echo "Running seeders..."
    php artisan db:seed --force
fi

echo "Caching configuration..."
php artisan config:clear
php artisan config:cache

echo "Starting Apache..."
exec apache2-foreground
