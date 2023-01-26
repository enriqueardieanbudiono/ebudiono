# Sprint 05
#### This sprint focus only on virtualbox and proxmox and not localhost
## How-to:
### Retrieve the boxes from build folder either bash / powershell:
```bash
.\remove-and-retrieve-and-add-vagrant-boxes.ps1 09
```
After retrieving the boxes, you can run the following command to start the server:
```bash
.\up.ps1
```
How to access the linux server from project folder:
```bash
vagrant ssh
mysql -u team-09-db-vm0.service.consul -p
```
the password is contains in our discord channel