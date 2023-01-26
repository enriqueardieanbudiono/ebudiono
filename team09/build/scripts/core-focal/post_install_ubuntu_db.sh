#!/bin/bash
set -e
set -v

# If IP third digit is 172, then we are in Proxmox Cloud Environment
# Otherwise, we are in a VM
echo "192.168.56.101     team-$NUMBER-lb-vm0   team-$NUMBER-lb-vm0.service.consul"   | sudo tee -a /etc/hosts
echo "192.168.56.102     team-$NUMBER-ws-vm0   team-$NUMBER-ws-vm0.service.consul"   | sudo tee -a /etc/hosts
echo "192.168.56.103     team-$NUMBER-ws-vm1   team-$NUMBER-ws-vm1.service.consul"   | sudo tee -a /etc/hosts
echo "192.168.56.104     team-$NUMBER-ws-vm2   team-$NUMBER-ws-vm2.service.consul"   | sudo tee -a /etc/hosts
echo "192.168.56.105     team-$NUMBER-db-vm0   team-$NUMBER-db-vm0.service.consul"   | sudo tee -a /etc/hosts

##################################################
# Add User customizations below here
##################################################

sudo hostnamectl set-hostname team-09-db-vm0

#################################################################################
# Install additional packages and dependencies here
# Make sure to leave the -y flag on the apt-get to auto accept the install
# Firewalld is required
#################################################################################

sudo apt-get install -y mariadb-server firewalld

#################################################################################
# Change the value of XX to be your team GitHub Repo
# Otherwise your clone operation will fail
# The command: su - vagrant -c switches from root to the user vagrant to execute 
# the git clone command
##################################################################################

su - vagrant -c "git clone git@github.com:illinoistech-itm/2022-team09w.git"
cd ./2022-team09w/code/

#################################################################################
# Enable http in the firewall
# We will be using the systemd-firewalld firewall by default
# https://firewalld.org/
# https://firewalld.org/documentation/
#################################################################################
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent

sudo firewall-cmd --zone=public --add-source=192.168.56.0/24 --permanent

# Reload changes to firewall
sudo firewall-cmd --reload

#################################################################################
# Setting up the MariaDB server
#################################################################################
sudo sed -i "s/.*bind-address.*/bind-address = $(cat /etc/hosts | grep team-$NUMBER-db-vm0 | awk '{ print $1 }')/" /etc/mysql/mariadb.conf.d/50-server.cnf

sed -i "s/\$ACCESSFROMIP/$ACCESSFROMIP/g" ./database/*.sql
sed -i "s/\$USERPASS/$USERPASS/g" ./database/*.sql
sed -i "s/\$USERNAME/$USERNAME/g" ./database/*.sql

sudo mysql < /home/vagrant/2022-team09w/code/database/create-database.sql
sudo mysql < /home/vagrant/2022-team09w/code/database/create-table.sql
sudo mysql < /home/vagrant/2022-team09w/code/database/create-user-with-permissions.sql