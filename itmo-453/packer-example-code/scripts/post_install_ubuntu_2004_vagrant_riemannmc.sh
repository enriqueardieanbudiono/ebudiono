#!/bin/bash 
set -e
set -v

# http://superuser.com/questions/196848/how-do-i-create-an-administrator-user-on-ubuntu
# http://unix.stackexchange.com/questions/1416/redirecting-stdout-to-a-file-you-dont-have-write-permission-on
# This line assumes the user you created in the preseed directory is ubuntu
echo "%admin  ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/init-users
sudo groupadd admin
sudo usermod -a -G admin vagrant

# Installing Vagrant keys
wget --no-check-certificate 'https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub'
sudo mkdir -p /home/vagrant/.ssh
sudo chown -R vagrant:vagrant /home/vagrant/.ssh
cat ./vagrant.pub >> /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant /home/vagrant/.ssh/authorized_keys
echo "All Done!"

##################################################
# Add User customizations below here
##################################################

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
sudo hostnamectl set-hostname riemannmc

# Install software
# 1 we will need openjdk-8-jre (java runtime) and ruby runtimes
# Examples:
sudo apt-get update -y
sudo apt-get install -y openjdk-8-jre ruby ruby-dev

# 2 we will need the rpm deb packages from riemann.io
# Examples
wget https://github.com/riemann/riemann/releases/download/0.3.6/riemann_0.3.6_all.deb
sudo dpkg -i riemann_0.3.6_all.deb
# 3 we will need some ruby gems 
sudo gem install riemann-client riemann-tools riemann-dash 
# 4 We need to ensure the services are enabled and start succesfully
sudo systemctl enable riemann
sudo systemctl start riemann

git clone git@github.com:illinoistech-itm/ebudiono.git
cp -v ebudiono/itmo-453/week-11/riemann/riemannmc/riemann.config /etc/riemann/riemann.config

# Adding examplecom & etc
sudo mkdir /etc/riemann/examplecom
sudo mkdir /etc/riemann/examplecom/etc

# Adding file to etc folder
cp -v ebudiono/itmo-453/week-11/etc/riemannmc/* /etc/riemann/examplecom/etc/

sudo systemctl stop riemann
sudo systemctl start riemann

rm ~/.ssh/id_rsa*

# Installing mailutils
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
echo "postfix postfix/mailname string riemannmc.example.com" | sudo debconf-set-selections
sudo apt-get install -y mailutils

# Changing firewalld
sudo apt-get install -y firewalld
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

# Adding week-12 content
sudo apt-get install -y collectd
sudo rm /etc/collectd/collectd.conf
cp -v ebudiono/itmo-453/week-12/collectd/collectd.conf /etc/collectd/

cp -v ebudiono/itmo-453/week-12/collectd/riemann/riemannmc/collectd.conf.d/* /etc/collectd/collectd.conf.d/

sudo systemctl enable collectd
sudo service collectd start