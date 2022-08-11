# How to deploy urbackup on Exoscale to use as backup for Windows and Linux

Urbackup is an open source, easy to deploy and maintain backup software. It provides an easy web interface to manage your backups.

## Prerequisites
As prerequisites you'll have to:
* deploy an small instance based on Ubuntu 20.04
* Create a security group that opens the following ports for the security group only for all systems that need to be backed up:
  * tcp/55413
  * tcp/55414
  * tcp/55415
* Create a second security group for the urbackup instance only with the following ports open to the internet:
  * tcp/80
  * tcp/443 
* A DNS for the urbackup server is recommended. The DNS should point to the urbackup server instances public IP. In this guide we use "urb.cldsvc.io" and www.urb.cldsvc.io" pointing to the public IP of the instance."

## Installing urbackup server
SSH into the Ubuntu system
``` 
sudo add-apt-repository ppa:uroni/urbackup  
sudo apt update  
sudo apt install urbackup-server
```

Define your local directory where you want urbackup to store the backup files
screenshot1

Set a password so the web interface won't be open:
`urbackupsrv reset-admin-pw -p <yourpassword>`

## Enabling the Webinterface
The webinterface will allow easier management and overview over your backups. SSL is highly recommended so it is included into this guide.
  
#### Installing and configure apache2 webserver
```
apt install apache2
ln -s /usr/share/urbackup/www /var/www/html/urbackup
a2enmod proxy_fcgi
a2enmod ssl
```
Create a copy of the default SSL copnfiguration matching your DNS (urb.cldsvc.io in this guide):
`cp -a /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/urb.cldsvc.io.conf`

Edit the new config and add ServerName and ServerAlias matching your DNS entry at the beginning right after "ServerAdmin":
```
vi /etc/apache2/sites-available/urb.cldsvc.io.conf
code
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost
		ServerName urb.cldsvc.io
		ServerAlias www.ur.cldsvc.io

		DocumentRoot /var/www/html
```
Add the line `ProxyPass "/urbackup/x" "fcgi://127.0.0.1:55413` at the end of the file within the VirtualHost section:
```
		#		nokeepalive ssl-unclean-shutdown \
		#		downgrade-1.0 force-response-1.0
        	ProxyPass "/urbackup/x" "fcgi://127.0.0.1:55413"
	</VirtualHost>
</IfModule>
```
Enable the site configuration and restart the apache2 webserver
```
a2ensite urb.cldsvc.io.conf
systemctl restart apache2
```
The urbackup instance should now be available on your DNS entry on HTTPS with a self signed certificate. If this is not the case please review logs and check the configuration before proceeding.

#### Install SSL certificate
We use LetsEncrypt to provide a working SSL certificate for your instance
```
apt install certbot python3-certbot-apache
certbot --apache
* provide a valid e-mail
* Agree to T&Cs
* Decide if you want to participate on sharing your e-mail
* leave blank so enable certificate for all sites. If you have multiple VirtualHosts select the urbackup ones seperated by commas
* Select 2 to redirect all traffic to HTTPS
```
 
Access your urbackup server on the webinterface
`https://urb.cldsvc.io/urbackup"`

Navigate to the "Settings" page to set the Server URL to your URL including the Server port. In this case it is "https://urb.clsvc.io"

  Screenshot2
  



