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

sudo hostnamectl set-hostname team-09-lb-vm0 

#################################################################################
# Install additional packages and dependencies here
# Make sure to leave the -y flag on the apt-get to auto accept the install
# Firewalld is required
#################################################################################

sudo apt-get install -y nginx firewalld
sudo systemctl enable nginx
sudo systemctl enable firewalld

curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

#################################################################################
# Change the value of XX to be your team GitHub Repo
# Otherwise your clone operation will fail
# The command: su - vagrant -c switches from root to the user vagrant to execute 
# the git clone command
##################################################################################
su - vagrant -c "git clone git@github.com:illinoistech-itm/2022-team09w.git"

#########################################
# Modified the default NGINX
#########################################
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
sudo mv /home/vagrant/2022-team09w/code/nginx/default /etc/nginx/sites-available/default

sudo cp -v /home/vagrant/2022-team09w/code/nginx/nginx.conf /etc/nginx/

#########################################
# Restart NGINX
#########################################
#sudo nginx -t
sudo systemctl daemon-reload

#################################################################################
# Enable http in the firewall
# We will be using the systemd-firewalld firewall by default
# https://firewalld.org/
# https://firewalld.org/documentation/
# Enable http in the firewall
#################################################################################

sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --reload
