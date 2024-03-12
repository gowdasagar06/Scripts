#cloud-boothook 
#!/bin/bash

# Increase kernel parameters and limits
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Add lines to increase the limit of open files in limits.conf
echo 'sonarqube   -   nofile   65536' | sudo tee -a /etc/security/limits.conf
echo 'sonarqube   -   nproc    4096' | sudo tee -a /etc/security/limits.conf

# Update package repositories
sudo apt update

# Install required libraries
sudo apt install -y libc6-x32 libc6-i386

# Download and install Java 17
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb
sudo dpkg -i jdk-17_linux-x64_bin.deb
sudo apt-get update
sudo apt-get clean
sudo apt-get autoremove
sudo apt --fix-broken install
sudo dpkg -i jdk-17_linux-x64_bin.deb
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-17/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-17/bin/javac 1

# Set environment variables for Java 17
echo 'export SONAR_JAVA_PATH=/usr/lib/jvm/jdk-17/bin/java' | sudo tee -a /etc/profile.d/sonar_java.sh
source /etc/profile.d/sonar_java.sh

# Install OpenJDK 17
sudo apt install -y openjdk-17-jre-headless

# Set JAVA_HOME environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/jdk-17' | sudo tee -a /etc/environment
source /etc/environment

# Add PostgreSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

# Update package repositories
sudo apt-get update

# Install PostgreSQL and unzip
sudo apt-get -y install postgresql postgresql-contrib unzip

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set PostgreSQL password for the default user
echo 'postgres:sonar' | sudo chpasswd

# Create a new user and database for SonarQube
sudo -u postgres createuser sonar
sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED password 'sonar';"
sudo -u postgres createdb sonarqube -O sonar

# Download and install SonarQube
sonar_link=$(curl -s https://www.sonarsource.com/products/sonarqube/downloads/success-download-community-edition/ | grep -o 'https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-[0-9.]*.zip')
sudo wget "$sonar_link" -P /tmp
sudo unzip -o "/tmp/$(basename "$sonar_link")" -d /opt
sudo rm -rf /opt/sonarqube    # Remove existing directory if exists
sudo mv /opt/sonarqube-* /opt/sonarqube

# Create a group and user for SonarQube
if ! getent group sonar > /dev/null 2>&1; then
    sudo groupadd sonar
fi

if ! id -u sonar > /dev/null 2>&1; then
    sudo useradd -c "user to run SonarQube" -d /opt/sonarqube -g sonar sonar
fi

sudo chown sonar:sonar /opt/sonarqube -R

# Configure SonarQube properties
sudo sed -i 's/#sonar.jdbc.username=/sonar.jdbc.username=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.password=/sonar.jdbc.password=sonar/' /opt/sonarqube/conf/sonar.properties
sudo sed -i 's/#sonar.jdbc.url=jdbc:postgresql:\/\/localhost:5432\/sonarqube/sonar.jdbc.url=jdbc:postgresql:\/\/localhost:5432\/sonarqube/' /opt/sonarqube/conf/sonar.properties

# Set RUN_AS_USER in sonar.sh
sudo sed -i 's/RUN_AS_USER=/RUN_AS_USER=sonar/' /opt/sonarqube/bin/linux-x86-64/sonar.sh

# Start SonarQube
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start
