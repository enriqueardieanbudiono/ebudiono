#!/bin/bash 
set -e
set -v


# http://unix.stackexchange.com/questions/1416/redirecting-stdout-to-a-file-you-dont-have-write-permission-on
# This line assumes the user you created in the preseed directory is vagrant
# http://chrisbalmer.io/vagrant/2015/07/02/build-rhel-centos-7-vagrant-box.html
# Read this bug track to see why this line below was the source of a lot of trouble.... 
# https://github.com/mitchellh/vagrant/issues/1482
#echo "Defaults requiretty" | sudo tee -a /etc/sudoers.d/init-users
# Need to add this first as wget not part of the base package...
sudo yum install -y wget git
#################################################################################################################
# code needed to allow for vagrant to function seamlessly
#################################################################################################################
echo "%admin  ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/init-users
sudo groupadd admin
sudo usermod -a -G admin vagrant

# Installing Vagrant keys
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
sudo mkdir -p /home/vagrant/.ssh
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
cat ./vagrant.pub >> /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 600 /home/vagrant/.ssh/authorized_keys
echo "All Done!"

#########################
# Add customization here
#########################

sudo yum install -y kernel-devel-`uname -r` gcc binutils make perl bzip2 epel-release

echo "All Done!"

cat << EOT >> /etc/hosts
# Nodes
192.168.33.100  riemanna riemanna.example.com
192.168.33.101  riemannb riemannb.example.com
192.168.33.102  riemannmc riemannmc.example.com
192.168.33.200  graphitea graphitea.example.com
192.168.33.201  graphiteb graphiteb.example.com
192.168.33.202  graphitemc graphitemc.example.com
192.168.33.10   host1 host1.example.com
192.168.33.11   host2 host2.example.com
EOT

## Command to change hostname
sudo hostnamectl set-hostname riemannb

# Install vim for editing file
sudo yum -y install vim

# Install software
# 1 we will need openjdk-8-jre (java runtime) and ruby runtimes
# Examples:
sudo yum install -y java-1.8.0-openjdk ruby ruby-devel

# 2 we will need the rpm deb packages from riemann.io
# Examples
wget https://github.com/riemann/riemann/releases/download/0.3.6/riemann-0.3.6-1.noarch-EL8.rpm
sudo rpm -i riemann-0.3.6-1.noarch-EL8.rpm
# 3 we will need some ruby gems 
sudo gem install riemann-client riemann-tools riemann-dash 
# 4 We need to ensure the services are enabled and start succesfully
sudo systemctl enable riemann
sudo systemctl start riemann

git clone git@github.com:illinoistech-itm/ebudiono.git
cp -v ebudiono/itmo-453/week-11/riemann/riemannb/riemann.config /etc/riemann/riemann.config

sudo mkdir /etc/riemann/examplecom
sudo mkdir /etc/riemann/examplecom/etc

cp -v ebudiono/itmo-453/week-11/etc/riemannmc/* /etc/riemann/examplecom/etc/

sudo systemctl stop riemann
sudo systemctl start riemann

# Changing firewalld
sudo yum install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo systemctl status firewalld
sudo firewall-cmd --list-all

sudo firewall-cmd --zone=public --add-port=5555/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5556/udp --permanent
sudo firewall-cmd --zone=public --add-port=5557/tcp --permanent
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent

sudo firewall-cmd --reload
sudo firewall-cmd --list-all

##################################################
# Installation and cofiguration of collectd
##################################################
sudo yum install -y collectd collectd-write_riemann

sudo systemctl stop collectd

#####################################################
# Copy the collectd configuration files from week-13
#####################################################
sudo mkdir -p /etc/collectd.conf.d/
cp -v ebudiono/itmo-453/week-13/hosts/riemannb/collectd.conf.d/* /etc/collectd.conf.d/

cp -v ebudiono/itmo-453/week-13/collectd.conf /etc/

sudo systemctl daemon-reload
sudo service collectd start
sudo systemctl start collectd