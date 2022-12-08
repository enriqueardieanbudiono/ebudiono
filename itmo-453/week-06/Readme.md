# Week 05 (Connecting Riemann Services)

# Restarting the configurations
* **sudo systemctl stop riemann**
* **sudo systemctl start riemann**

# Mailer Notification Configuration
On **riemannmc** run the command:
* **sudo mkdir -p /etc/riemann/examplecom/etc**
* **sudo touch /etc/riemann/examplecom/etc/email.clj**
* **sudo apt-get install mailutils**