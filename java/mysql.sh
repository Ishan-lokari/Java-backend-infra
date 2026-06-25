#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y default-mysql-server

systemctl enable mysql
systemctl start mysql

DB_PASS=$(gcloud secrets versions access latest --secret="db-password" --project=ishan-project-493907)

mysql -u root -e "CREATE DATABASE IF NOT EXISTS mydb;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'dbuser'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON mydb.* TO 'dbuser'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl restart mysql