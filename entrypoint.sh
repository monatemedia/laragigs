#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Verify directory before running commands
echo "Changing to the correct directory..."
cd /var/www/html

echo "Current directory: $(pwd)"

# Verify artisan is present before running commands
echo "Checking for artisan file..."
ls -lah /var/www/html/artisan

if [ ! -f /var/www/html/artisan ]; then
    echo "artisan file not found!"
    exit 1
fi

# Set permissions for artisan
echo "Setting permissions for artisan..."
chmod +x /var/www/html/artisan

# Wait for PostgreSQL to be ready
echo "Waiting for database connection..."
until nc -z $DB_HOST $DB_PORT; do
  echo "Waiting for PostgreSQL at $DB_HOST:$DB_PORT..."
  sleep 5
done

echo "Database is up!"

# Check if the database has tables
TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USERNAME -d $DB_DATABASE -tAc "SELECT COUNT(*) FROM pg_tables WHERE schemaname = 'public';")

if [ "$TABLE_COUNT" -gt "0" ]; then
    echo "Database is not empty. Resetting..."

    # Disable foreign key checks, truncate all tables, and reset sequences
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USERNAME -d $DB_DATABASE <<EOSQL
    DO $$ DECLARE
        r RECORD;
    BEGIN
        -- Disable constraints
        SET session_replication_role = 'replica';

        -- Truncate all tables
        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
            EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' CASCADE;';
        END LOOP;

        -- Reset sequences
        FOR r IN (SELECT c.oid::regclass AS table_name, a.attname AS column_name
                  FROM pg_class c
                  JOIN pg_attribute a ON c.oid = a.attrelid
                  WHERE a.attnum > 0 AND a.attname = 'id' AND c.relkind = 'r') LOOP
            EXECUTE 'ALTER SEQUENCE ' || r.table_name || '_id_seq RESTART WITH 1;';
        END LOOP;

        -- Re-enable constraints
        SET session_replication_role = 'origin';
    END $$;
EOSQL
fi

# Run migrations and seeders
echo "Running migrations..."
php artisan migrate --force

echo "Running seeders..."
php artisan db:seed --force

# Clear and cache configuration
echo "Caching configuration..."
php artisan config:clear
php artisan config:cache

# Start Apache
echo "Starting Apache..."
exec apache2-foreground
