# Infscape Backup Appliance Blueprint

This blueprint can be used to deploy a Infscape Backup appliance on Exoscale and configure SOS as S3 backup endpoint.

A full documentation can be found here: https://www.urbackup.org/admin_guide_app.pdf

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

#### Prepare Exoscale SOS bucket and API Key
Create a Bucket in you preferred zone. Note that traffic between Exoscale zones is free and you can choose a different zone for the bucket as for the infscape appliance to gain Geo redundancy with your backups.
* Create a bucket with a unique name
* Create an API key restricted to the service SOS and the created bucket. Note down the API key and secret.

### Install infscape
* ssh on the created Debian system
* Initiate the installation process:
´´´
wget https://dl3.infscape.com/images/urbackup-app-10-13.sh && bash urbackup-app-10-13.sh

* Agree to the installation. A password will be shown in the terminal, note this password as it will be used to access the web management interface
* After a while the appliance will reboot itself. Due to a small bug we need to reboot it again: Navigate to the instance in the Exoscale portal and click on the reboot button

### Configure Infscape and license
* Open a browser and navigate to the public IP of the infscape appliance using http: http://<public-ip>/
* Provide the password generated during installation process
* If you do not yet own a license key login at: https://www.infscape.com/. If you just want to start get a free Community Edition license key.
* If you do not have a UrBackup account register a new one with a valid e-mail address and a password of your choice. This account will be used to access this instance web interface from now on and the e-mail adress will receive event based e-mails (for example if your Infscape appliance is offline)
* Provide appliance name and license key.
* Use the public IP or a DNS pointing to the public IP for clients to connect
 
### Configure HTTPS (optional but highly recommended)
* You require a DNS entry to enable HTTPS.
* Login with the new password to the appliance
* navigate to "Settings" -> "System" and click on "Setup SSL/HTTPS"
* Provide the DNS name of the appliance, enable the redirect and accept the Let's Encrypt Subscriber Agreement
* Click on "Save" to enable HTTPS. The web interface will be unresponsive for about 30 seconds while HTTPS is configured
  
### Configure Cloud Storage
* Navigate to the "Status" page
* Click on the blue "Use system disk as cache and setup cloud storage"
* Agree and provide cloud storage information
* IMPORTANT: Note down the Cloud storage encryption key and store it safely ! This key is mandatory to decrypt your backups if the appliance is lost
* Finish by clicking on "Select/Confirm cloud storage"
* Navigate to "Settings" -> "Storage" to validate the Cloud Storage is used
  
  

