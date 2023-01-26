# Build Folder

The Webserver that We Choose:
* Ubuntu Server 2004

# Proxmox Server

### How to access the website:
```bash
192.168.174.88.sslip.io
```

# PROJECT FOLDER

## Loadbalancer

### Make sure your computer / local machine have:
* All Boxes up and running

### How to access the website:

```bash
192.168.56.101.sslip.io
```

# POWERSHELL FOLDER (WINDOWS ONLY)
To retreive all boxes that we already made, open the powershell folder from terminal, and type:
```bash
./remove-and-retrieve-and-add-vagrant-boxes.ps1 09
```
it will takes around 20 minutes - 1 hour depending on how fast is your wifi that you using at right now

**AFTER** you retreieve all boxes, run this command:
```bash
./up.ps1
```
If you see any error, look at the notes that I already provided below

# BASH FOLDER (MAC / LINUX ONLY)
To retreive all boxes that we already made, open the powershell folder from terminal, and type:
```bash
./remove-and-retrieve-and-add-vagrant-boxes.sh 09
```
it will takes around 20 minutes - 1 hour depending on how fast is your wifi that you using at right now

**AFTER** you retreieve all boxes, run this command:
```bash
./up.sh
```
If you see any error after entering command from above, look at the notes that I already provided below. If the notes does not help with the problem, tag my name in the group chat so I could get notified with your problem.

# NOTES
if you got error with a word saying " Unknown configuration section vbguest", run this command:
```bash
vagrant plugin list
```
if you see something like this:

![Vagrant plugin list](https://user-images.githubusercontent.com/60109036/160978306-04d0f411-7f31-4d96-913c-b7d1dac03f65.png)

then you are good to go. <b>BUT</b> if you don't see anything, then you need to install the plugin by running this command:
```bash
vagrant plugin install vagrant-vbguest
```
If it's not working, or giving you error, try to turn off the VPN that connected to school network

It will take no longer than 5 minutes. So, after you install the plugin, you can try the up command to bring everything up.