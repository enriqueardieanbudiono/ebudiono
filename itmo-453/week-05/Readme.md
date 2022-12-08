# Week 05
# Managing Events and MEtric with Riemann

**==== NOTES ====**

Add the installation of the package for vim on Centos8
Change of the hostname (centos: sudo hostnamectl set-hostname riemannb)
* **riemanna (ubuntu)**
* **riemannb (centos8)**
* **riemannmc (ubuntu)**

Adding entries to /etc/hosts file
* **192.168.33.100  riemanna riemanna.example.com**
* **192.168.33.101  riemannb riemannb.example.com**
* **192.168.33.102  riemannmc riemannmc.example.com**

# Nodes
* 192.168.33.100  riemanna riemanna.example.com
* 192.168.33.101  riemannb riemannb.example.com
* 192.168.33.102  riemannmc riemannmc.example.com

# Install software
1 we will need openjdk-8-jre (java runtime) and ruby runtimes
Examples:
* **sudo apt-get update -y**
* **sudo apt-get install -y openjdk-8-jre ruby ruby-dev**
* **sudo yum install -y java-1.8.0-openjdk ruby ruby-devel**

2 we will need the rpm deb packages from riemann.io
Examples

Ubuntu
* **wget https://github.com/riemann/riemann/releases/download/0.3.6/riemann_0.3.6_all.deb**
* **sudo dpkg -i riemann_0.3.6_all.deb**

CentOS
* **wget https://github.com/riemann/riemann/releases/download/0.3.6/riemann-0.3.6-1.noarch-EL8.rpm**
* **sudo rpm -Uvh riemann-0.3.6-1.noarch-EL8.rpm**

3 we will need some ruby gems 
* **sudo gem install riemann-client riemann-tools riemann-dash (run on all systems)**

4 We need to ensure the services are enabled and start succesfully
* **sudo systemctl enable riemann**
* **sudo systemctl start riemann**

How to look at the logs?
* **tail /var/log/riemann/riemann.log**

Code:
* riemann-health --host riemannb.example.com
* tail –f /var/log/riemann/riemann.log

Installation:
# Ubuntu
* sudo apt-get install firewalld
* sudo systemctl enable firewalld
* sudo systemctl start firewalld
* sudo systemctl status firewalld
* sudo firewall-cmd --list-all

# CentOS
* sudo yum install firewalld
* sudo systemctl enable firewalld
* sudo systemctl start firewalld
* sudo systemctl status firewalld
* sudo firewall-cmd --list-all

# Firewall Exceptions
* sudo firewall-cmd --zone=public --add-port=5555/tcp --permanent
* sudo firewall-cmd --zone=public --add-port=5556/udp --permanent
* sudo firewall-cmd --zone=public --add-port=5557/tcp --permanent
* sudo firewall-cmd --reload
* sudo firewall-cmd –-list-all
