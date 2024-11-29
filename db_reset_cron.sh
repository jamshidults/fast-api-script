#!/bin/bash

# Database reset and service management script
reset_database() {
    # Stop the FastAPI service
    sudo systemctl stop fastapi

    # Define paths
    DB_PATH="$HOME/fls_backup/orders.db"
    ARCHIVE_DIR="$HOME/shared_folder/LOG/archived"

    # Create archive directory if it doesn't exist
    mkdir -p "$ARCHIVE_DIR"

    # Archive the existing database file with timestamp
    if [ -f "$DB_PATH" ]; then
        # Create timestamp for unique filename

        ARCHIVE_PATH="$ARCHIVE_DIR/orders.db"

        # Copy the database to archive location
        cp -f "$DB_PATH" "$ARCHIVE_PATH"
        echo "Database archived to: $ARCHIVE_PATH"

        # Remove the existing database file
        rm "$DB_PATH"
        echo "Original database file deleted: $DB_PATH"
    else
        echo "No existing database file found to archive."
    fi

    # Restart the FastAPI service
    sudo systemctl start fastapi

    echo "FastAPI service restarted. A new database will be created if it doesn't exist."
}

# Save the function to a script
echo '#!/bin/bash' > ~/fls_backup/reset_fastapi_db.sh
declare -f reset_database >> ~/fls_backup/reset_fastapi_db.sh
echo 'reset_database' >> ~/fls_backup/reset_fastapi_db.sh

# Make the script executable
chmod +x ~/fls_backup/reset_fastapi_db.sh

# Set up cron job to run at 10 PM every wednesday
(crontab -l 2>/dev/null; echo "0 22 * * 3 $HOME/fls_backup/reset_fastapi_db.sh") | crontab -

echo "Database reset script created at ~/fls_backup/reset_fastapi_db.sh"
echo "Cron job set up to run every Wednesday at 10 PM"