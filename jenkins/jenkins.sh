#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https fontconfig openjdk-21-jdk wget maven

# Docker Setup
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

# Jenkins Setup
mkdir -p /etc/apt/keyrings
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc trusted=yes] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

usermod -aG docker jenkins

echo 'JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64' >> /etc/environment
echo 'PATH=$JAVA_HOME/bin:$PATH' >> /etc/environment

mkdir -p /etc/systemd/system/jenkins.service.d
echo '[Service]' > /etc/systemd/system/jenkins.service.d/override.conf
echo 'TimeoutStartSec=300' >> /etc/systemd/system/jenkins.service.d/override.conf
echo 'Environment="JAVA_OPTS=-Djava.awt.headless=true"' >> /etc/systemd/system/jenkins.service.d/override.conf

systemctl daemon-reload
systemctl enable --now jenkins

chmod 666 /var/run/docker.sock