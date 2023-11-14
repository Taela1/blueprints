# Infscape Backup Appliance Blueprint

This blueprint can be used to deploy a Infscape Backup appliance on Exoscale and configure SOS as S3 backup endpoint.

A full documentation can be found here: https://www.urbackup.org/admin_guide_app.pdf

##Prerequisites
As prerequisites you have:

* access to Exoscale environment
* an Exoscale API key with an IAM role attached that allows SOS access to 'list-buckets' and all operations on the bucket created to store the backups. More details can be found in our documentation at https://community.exoscale.com/documentation/iam/iam-api-key-roles-policies/
* A SOS bucket that matches the name allowed within the IAM role

##  Installation
The installation guide is available at: https://www.infscape.com/urbackup-appliance-download/
Please follow the guide for Install to Cloud Instance

#### Prepare Exoscale security-group
The Inscape instance requires the following ports to be open in the security-group:
* tcp/22 for SSH access (only required during installation, can be removed later)
* tcp/80 for http
* tcp/443 for https

#### Prepare Exoscale instance
Create a new instance with the following settings:
* Debian 10 Bullseye as template
* at least 4GB RAM (t-shirt medium or higher)
* at least 50GB disk (required for local caching of backup data chunks before uploading to SOS)

### Install infscape
* ssh on the created Debian system
* Initiate the installation process:
```
wget https://dl3.infscape.com/images/urbackup-app-10-13.sh && bash urbackup-app-10-13.sh
```
* Agree to the installation. A password will be shown in the terminal, note this password as it will be used to access the web management interface

![alt text](https://github.com/taela1/blueprints/blob/main/infscape_install.png?raw=true)

* After a while the appliance will reboot itself. Due to a small bug we need to reboot it again: Navigate to the instance in the Exoscale portal and click on the reboot button. The console looks like this uniil the appliance is rebooted

![alt text](https://github.com/taela1/blueprints/blob/main/infscape_nonetwork.png?raw=true)

* You can use the Exoscale console to validate the appliance has the public IP configured

![alt text](https://github.com/taela1/blueprints/blob/main/infscape_network.png?raw=true)

### Configure Infscape and license
* Open a browser and navigate to the public IP of the infscape appliance using http: http://<public-ip>/
* Provide the password generated during installation process
 
![alt text](https://github.com/taela1/blueprints/blob/main/infscape_firstlogin.png?raw=true)
 
* If you do not yet own a license key login at: https://www.infscape.com/. If you just want to start get a free Community Edition license key.
* If you do not have a UrBackup account register a new one with a valid e-mail address and a password of your choice. This account will be used to access this instance web interface from now on and the e-mail adress will receive event based e-mails (for example if your Infscape appliance is offline)
* Provide appliance name and license key.
* Use the public IP or a DNS pointing to the public IP for clients to connect
 
![alt text](https://github.com/taela1/blueprints/blob/main/infscape_register.png?raw=true)
 
### Configure HTTPS (optional but highly recommended)
* You require a DNS entry to enable HTTPS.
* Login with the new password to the appliance
* navigate to "Settings" -> "System" and click on "Setup SSL/HTTPS"
 
 ![alt text](https://github.com/taela1/blueprints/blob/main/infscape_setupssl.png?raw=true)
 
* Provide the DNS name of the appliance, enable the redirect and accept the Let's Encrypt Subscriber Agreement
* Click on "Save" to enable HTTPS. The web interface will be unresponsive for about 30 seconds while HTTPS is configured
 
 ![alt text](https://github.com/taela1/blueprints/blob/main/infscape_sslsettings.png?raw=true)
  
### Configure Infscape server settings to use SSL for backups (optional but highly recommended)
* This step is highly recommended but requires SSL so be enabled
* Navigate to "Settings" -> "Internet"
* Set "Internet Server name/IP" to "127.0.0.1"
* Let "Internet Server port" on the preconfigured value of "55415"
* Set "Connect via HTTP(S) proxy to "<your DNS entry>
 
 ![alt text](https://github.com/taela1/blueprints/blob/main/infscape_serversettings.png?raw=true)
 
### Configure Cloud Storage
* Navigate to the "Status" page
* Click on the blue "Use system disk as cache and setup cloud storage"
 
 ![alt text](https://github.com/taela1/blueprints/blob/main/infscape_setupsos.png?raw=true)
 
* Agree and provide cloud storage information
 
![alt text](https://github.com/taela1/blueprints/blob/main/infscape_detailsos.png?raw=true) 

* IMPORTANT: Note down the Cloud storage encryption key and store it safely ! This key is mandatory to decrypt your backups if the appliance is lost
* Finish by clicking on "Select/Confirm cloud storage"
* Navigate to "Settings" -> "Storage" to validate the Cloud Storage is used
  
 ![alt text](https://github.com/taela1/blueprints/blob/main/infscape_verifysos.png?raw=true)

