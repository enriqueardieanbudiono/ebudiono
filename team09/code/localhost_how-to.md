# Code Folder

## LOCALHOST ONLY

<u>**NOTES:** Make sure to change password of your mysql workbench to password for testing on your machine!</u>

### Make sure your computer / local machine have:
* Database server / localhost mysql server up and running
* Node.js

### To use the server.js, make sure to install <u>inside the code folder</u>:

```bash
npm install -y
```
### To run the server.js:
```bash
node server.js
```

### How to access to the website from your local machine:
```bash
http://localhost:7000
```

# NOTES
If you got an error in CSS, try to use the following command on windows terminal / powershell:
```bash
cd code
Remove-Item .\node_modules\
npm install -y
```

If you got an error after login that DOES NOT means the program is error, you forgot to turn on the database server / the database (mysql) on your end
* If you want to access the website from the webserver go here => [Build Folder](https://github.com/illinoistech-itm/2022-team09w/blob/main/build/readme.md)