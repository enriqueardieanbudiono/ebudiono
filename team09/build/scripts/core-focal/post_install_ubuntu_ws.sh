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

#################################################################################
# Install additional packages and dependencies here
# Make sure to leave the -y flag on the apt-get to auto accept the install
# Firewalld is required
#################################################################################
sudo apt-get install -y nginx firewalld

#################################################################################
# Example how to install NodeJS
#################################################################################
# https://nodejs.org/en/download/
# https://github.com/nodesource/distributions/blob/master/README.md
# Using Ubuntu
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

#################################################################################
# Change the value of XX to be your team GitHub Repo
# Otherwise your clone operation will fail
# The command: su - vagrant -c switches from root to the user vagrant to execute 
# the git clone command
##################################################################################
su - vagrant -c "git clone git@github.com:illinoistech-itm/2022-team09w.git"
cd ./2022-team09w/code/
npm install -g npm@8.6.0
sudo npm install -y
sudo npm install pm2 -g

#########################################
# Modified the default NGINX
#########################################
# sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
# sudo mv /home/vagrant/2022-team09w/code/nginx/default /etc/nginx/sites-available/default

# sudo systemctl stop nginx
# sudo systemctl start nginx

# Command to create a service handler and start that javascript app at boot time
pm2 startup
# The pm2 startup command generates this command
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant

pm2 start server.js --watch
pm2 save
# Change ownership of the .pm2 meta-files after we create them
sudo chown vagrant:vagrant /home/vagrant/.pm2/rpc.sock /home/vagrant/.pm2/pub.sock

#################################################################################
# Enable http in the firewall
# We will be using the systemd-firewalld firewall by default
# https://firewalld.org/
# https://firewalld.org/documentation/
#################################################################################
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --zone=public --add-port=7000/tcp --permanent
sudo firewall-cmd --reload