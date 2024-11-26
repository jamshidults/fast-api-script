#!/bin/bash
 
# Exit on any error
set -e
 
# Configuration variables
CURRENT_USER=$USER
PROJECT_NAME="fls_backup"
APP_DIR="$HOME/$PROJECT_NAME"
GIT_REPO="https://github.com/jamshidults/fls_backup.git"
GIT_BRANCH="main"
 
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
 
# Function to print status messages
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
 
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}
 
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
 
# Update system and install dependencies
print_message "Updating system and installing required packages..."
sudo apt update
sudo apt install -y software-properties-common

# Add deadsnakes PPA for Python versions
print_message "Adding deadsnakes PPA for Python 3.12..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.12 and related packages
print_message "Installing Python 3.12..."
sudo apt install -y python3.12 python3.12-venv python3.12-dev

# Install git
print_message "Installing git..."
sudo apt install -y git
 
# Check if git repository already exists
if [ -d "$APP_DIR" ]; then
    print_message "Directory $APP_DIR already exists. Backing it up..."
    mv "$APP_DIR" "${APP_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi
 
# Clone the repository
print_message "Cloning repository from $GIT_REPO..."
git clone -b $GIT_BRANCH $GIT_REPO $APP_DIR
cd $APP_DIR
 
# Create and activate virtual environment
print_message "Creating virtual environment..."
python3.12 -m venv venv
source venv/bin/activate
 
# Upgrade pip and install dependencies
print_message "Installing dependencies..."
pip install --upgrade pip
 
# Install requirements if requirements.txt exists, otherwise install basic packages
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    print_message "No requirements.txt found, installing basic packages..."
    pip install fastapi[all] sqlalchemy[asyncio] asyncpg uvicorn
    pip freeze > requirements.txt
fi
 
# Create log directory for FastAPI
print_message "Creating log directory..."
sudo mkdir -p /var/log/fastapi
sudo chown $CURRENT_USER:$CURRENT_USER /var/log/fastapi
 
# Create the systemd service file
print_message "Creating systemd service file..."
sudo tee /etc/systemd/system/fastapi.service << EOF
[Unit]
Description=FastAPI Orders Application
After=network.target
 
[Service]
User=$CURRENT_USER
Group=$CURRENT_USER
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
Environment="DATABASE_URL=sqlite:///orders.db"
ExecStart=$APP_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 3
 
# Restart on failure
Restart=always
RestartSec=3
 
# Logging
StandardOutput=append:/var/log/fastapi/access.log
StandardError=append:/var/log/fastapi/error.log
 
[Install]
WantedBy=multi-user.target
EOF
 
# Create log rotation configuration
print_message "Setting up log rotation..."
sudo tee /etc/logrotate.d/fastapi << EOF
/var/log/fastapi/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 $CURRENT_USER $CURRENT_USER
}
EOF
 
# Setup the service
print_message "Setting up systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable fastapi
sudo systemctl start fastapi
 
# Create a deployment script for future updates
print_message "Creating deployment script..."
tee deploy.sh << EOF
#!/bin/bash
set -e
 
# Pull latest changes
git pull origin $GIT_BRANCH
 
# Activate virtual environment
source venv/bin/activate
 
# Install/update dependencies
pip install -r requirements.txt
 
# Restart service
sudo systemctl restart fastapi
 
echo "Deployment completed successfully!"
EOF
 
chmod +x deploy.sh
 
# Create a management script
print_message "Creating management script..."
tee manage_service.sh << EOF
#!/bin/bash
 
case "\$1" in
    start)
        sudo systemctl start fastapi
        ;;
    stop)
        sudo systemctl stop fastapi
        ;;
    restart)
        sudo systemctl restart fastapi
        ;;
    status)
        sudo systemctl status fastapi
        ;;
    logs)
        sudo journalctl -u fastapi -f
        ;;
    deploy)
        ./deploy.sh
        ;;
    *)
        echo "Usage: \$0 {start|stop|restart|status|logs|deploy}"
        exit 1
        ;;
esac
EOF
 
chmod +x manage_service.sh
 
# Print completion message and information
print_success "=== Setup Complete ==="
echo -e "\nProject Details:"
echo "Virtual Environment Path: $APP_DIR/venv"
echo "Python Interpreter Path: $(which python)"
echo "Project Path: $APP_DIR"
 
echo -e "\nService Status:"
sudo systemctl status fastapi
 
echo -e "\nUseful commands:"
echo "- Check service status: ./manage_service.sh status"
echo "- View logs: ./manage_service.sh logs"
echo "- Restart service: ./manage_service.sh restart"
echo "- Deploy updates: ./manage_service.sh deploy"
echo "- To activate the virtual environment: source venv/bin/activate"