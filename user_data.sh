#!/bin/bash
# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Update Ubuntu
apt-get update -y

# Install Docker
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ubuntu

# Install Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable docker
curl -Lfo /home/ubuntu/docker-compose.yaml 'https://raw.githubusercontent.com/lopesdiego12/Wiki/master/airflow_datasprints_2.yaml' 
mkdir /home/ubuntu/dags /home/ubuntu/logs /home/ubuntu/plugins
# Permissions
chmod -R 777 /home/ubuntu/dags
chmod -R 777 /home/ubuntu/logs
chmod -R 777 /home/ubuntu/plugins
# Env (On Linux, the mounted volumes in container use the native Linux filesystem user/group permissions, so you have to make sure the container and host computer have matching file permissions.)
echo -e "AIRFLOW_UID=50000\nAIRFLOW_GID=50000" >> .env
sleep 10
# Airflow init
docker-compose -f /home/ubuntu/docker-compose.yaml up airflow-init 
sleep 40
# On all operating system, you need to run database migrations and create the first user account.
docker-compose -f /home/ubuntu/docker-compose.yaml up -d

###https://airflow.apache.org/docs/apache-airflow/stable/start/docker.html?highlight=compose