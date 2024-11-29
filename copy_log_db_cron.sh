#!/bin/bash

# Database backup script
backup_database() {
    # Define paths
    DB_PATH="$HOME/fls_backup/orders.db"
    CURRENT_DIR="$HOME/shared_folder/LOG/Current"

    # Create Current directory if it doesn't exist
    mkdir -p "$CURRENT_DIR"

    # Define the backup path with the fixed filename
    BACKUP_PATH="$CURRENT_DIR/orders.db"

    # Check if the database exists before copying
    if [ -f "$DB_PATH" ]; then
        # Copy the database to Current location, replacing any existing file
        cp -f "$DB_PATH" "$BACKUP_PATH"
        echo "Database backed up to: $BACKUP_PATH"
    else
        echo "No database file found to backup."
    fi
}

# Save the function to a script
echo '#!/bin/bash' > ~/fls_backup/backup_current_db.sh
declare -f backup_database >> ~/fls_backup/backup_current_db.sh
echo 'backup_database' >> ~/fls_backup/backup_current_db.sh

# Make the script executable
chmod +x ~/fls_backup/backup_current_db.sh

# Set up cron job to run every hour
(crontab -l 2>/dev/null; echo "0 * * * * $HOME/fls_backup/backup_current_db.sh") | crontab -

echo "Database backup script created at ~/fls_backup/backup_current_db.sh"
echo "Cron job set up to run every hour"