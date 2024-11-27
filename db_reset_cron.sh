#!/bin/bash

# Database reset and service management script
reset_database() {
    # Stop the FastAPI service
    sudo systemctl stop fastapi

    # Remove the existing database file
    DB_PATH="$HOME/fls_backup/orders.db"
    if [ -f "$DB_PATH" ]; then
        rm "$DB_PATH"
        echo "Database file deleted: $DB_PATH"
    else
        echo "No existing database file found."
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

# Set up cron job to run at 10 PM every day
(crontab -l 2>/dev/null; echo "0 22 * * * $HOME/fls_backup/reset_fastapi_db.sh") | crontab -

echo "Database reset script created at ~/fls_backup/reset_fastapi_db.sh"
echo "Cron job set up to run daily at 10 PM"