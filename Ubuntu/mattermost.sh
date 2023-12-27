#!/bin/bash

# Mattermost version to install (change as needed)
MATTERMOST_VERSION="5.38.1"

# Set up dependencies
sudo apt-get update
sudo apt-get install -y mysql-server mysql-client jq

# Set MySQL root password in an environment variable
export MYSQL_ROOT_PASSWORD="Sagar@123"

# Configure MySQL non-interactively
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"

# Install MySQL server
sudo apt-get install -y mysql-server

# Create a MySQL database and user for Mattermost
MYSQL_DATABASE="mattermost"
MYSQL_USER="mmuser"
MYSQL_PASSWORD="mmuser_password"

sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<MYSQL_SCRIPT
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Download and install Mattermost
sudo mkdir -p /opt/mattermost/data /opt/mattermost/logs /opt/mattermost/config

wget https://releases.mattermost.com/$MATTERMOST_VERSION/mattermost-team-$MATTERMOST_VERSION-linux-amd64.tar.gz
tar -xvzf mattermost-team-$MATTERMOST_VERSION-linux-amd64.tar.gz

# Remove existing Mattermost directory
sudo rm -rf /opt/mattermost

# Move Mattermost files
sudo mv mattermost /opt

# Configure Mattermost using jq
sudo cp /opt/mattermost/config/config.json /opt/mattermost/config/config.json.bak
sudo jq '.SqlSettings.DataSource = "mmuser:mmuser_password@tcp(localhost:3306)/mattermost?charset=utf8mb4,utf8\u0026readTimeout=30s\u0026writeTimeout=30s" | .SiteURL = "http://localhost" | .SqlSettings.DriverName = "mysql"' /opt/mattermost/config/config.json > /opt/mattermost/config/config.json.tmp && sudo mv /opt/mattermost/config/config.json.tmp /opt/mattermost/config/config.json

# Set up Mattermost service
sudo useradd --system --user-group mattermost
sudo chown -R mattermost:mattermost /opt/mattermost
sudo chmod -R g+w /opt/mattermost

# Create Mattermost systemd service
sudo tee /etc/systemd/system/mattermost.service > /dev/null <<EOL
[Unit]
Description=Mattermost
After=network.target
After=mysql.service

[Service]
Type=simple
User=mattermost
ExecStart=/opt/mattermost/bin/mattermost
Restart=always
SyslogIdentifier=mattermost

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start Mattermost
sudo systemctl daemon-reload
sudo systemctl start mattermost
sudo systemctl enable mattermost

# Clean up downloaded files
rm mattermost-team-$MATTERMOST_VERSION-linux-amd64.tar.gz

echo "Mattermost installed successfully!"
