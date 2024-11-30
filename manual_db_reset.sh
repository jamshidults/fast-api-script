#!/bin/bash

# Interactive script for database reset
echo "=== FastAPI Database Reset ==="
echo "This script will:"
echo "1. Stop the FastAPI service"
echo "2. Delete the existing database"
echo "3. Restart the FastAPI service"
echo ""

read -p "Are you sure you want to reset the database? (y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    # Stop the FastAPI service
    sudo systemctl stop fastapi

    # Remove the existing database file
    DB_PATH="$HOME/shared_folder/LOG/current/orders.db"
    ARCHIVE_DIR="$HOME/shared_folder/LOG/archived"
    mkdir -p "$ARCHIVE_DIR"
    if [ -f "$DB_PATH" ]; then
        ARCHIVE_PATH="$ARCHIVE_DIR/orders.db"

        # Copy the database to archive location
        cp -f "$DB_PATH" "$ARCHIVE_PATH"
        echo "Database archived to: $ARCHIVE_PATH"
        rm "$DB_PATH"
        echo "Database file deleted: $DB_PATH"
    else
        echo "No existing database file found."
    fi

    # Restart the FastAPI service
    sudo systemctl start fastapi

    echo "Database reset complete."
else
    echo "Database reset cancelled."
fi