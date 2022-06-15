# How to deploy urbackup on Exoscale to use as backup for Windows and Linux

Urbackup is an open source, easy to deploy and maintain backup software. It provides an easy web interface to manage your backups.

## Prerequisites
As prerequisites you'll have to:
"* deploy an small instance based on Ubuntu 20.04
* Create a security group that opens the following ports for all systems that need to be backed up:
* tcp/80
* tcp/443
* tcp/55413
* tcp/55414
* tcp/55415
* A DNS for the urbackup server is recommended. The DNS should point to the urbackup server instances public IP. In this guide we use "urb.cldsvc.io" and "www.urb.cldsvc.io" pointing to the public IP of the instance."

## Installing urbackup server
SSH into the Ubuntu system
code 
sudo add-apt-repository ppa:uroni/urbackup  
sudo apt update  
sudo apt install urbackup-server
code

Define your local directory where you want urbackup to store the backup files
screenshot1

Set a password so the web interface won't be open:
code
urbackupsrv reset-admin-pw -p <yourpassword>

## Enabling the Webinterface
The webinterface will allow easier management and overview over your backups. SSL is highly recommended so it is included into this guide.
  
#### Installing and configure apache2 webserver
code
apt install apache2
ln -s /usr/share/urbackup/www /var/www/html/urbackup
a2enmod proxy_fcgi
a2enmod ssl
code
Create a copy of the default SSL copnfiguration matching your DNS (urb.cldsvc.io in this guide):
code
cp -a /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/urb.cldsvc.io.conf
code
Edit the new config and add ServerName and ServerAlias matching your DNS entry at the beginning right after "ServerAdmin":
vi /etc/apache2/sites-available/urb.cldsvc.io.conf
code
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost
		ServerName urb.cldsvc.io
		ServerAlias www.ur.cldsvc.io

		DocumentRoot /var/www/html
code
Add the line ProxyPass "/urbackup/x" "fcgi://127.0.0.1:55413 at the end of the file within the VirtualHost section:
code
		#		nokeepalive ssl-unclean-shutdown \
		#		downgrade-1.0 force-response-1.0
        	ProxyPass "/urbackup/x" "fcgi://127.0.0.1:55413"
	</VirtualHost>
</IfModule>
code
Enable the site configuration and restart the apache2 webserver
code
a2ensite urb.cldsvc.io.conf
systemctl restart apache2
code
The urbackup instance should now be available on your DNS entry on HTTPS with a self signed certificate. If this is not the case please review logs and check the configuration before proceeding.

#### Install SSL certificate
We use LetsEncrypt to provide a working SSL certificate for your instance
code
apt install certbot python3-certbot-apache
certbot --apache
* provide a valid e-mail
* Agree to T&Cs
* Decide if you want to participate on sharing your e-mail
* leave blank so enable certificate for all sites. If you have multiple VirtualHosts select the urbackup ones seperated by commas
* Select 2 to redirect all traffic to HTTPS
code
 
Access your urbackup server on the webinterface
code
https://urb.cldsvc.io/urbackup"
code
Navigate to the "Settings" page to set the Server URL to your URL including the Server port. In this case it is "https://urb.clsvc.io"

  Screenshot2
  

## Install agents & restore
  
## Linux
Open the web portal and navigate to "Status" and click on the blue "Add new client" in the lower right corner
Leave "Add new Internet client/client behind NAT" and give the client a name
After adding the client you see a page with options how to add your cient. Easiest way is to use the script given in "Install it directly via the terminal"
code
ssh into the linux system
TF=`mktemp` && wget "https://urb.cldsvc.io/urbackup/x?a=download_client&lang=en&clientid=2&authkey=p7PpiYXrP1&os=linux" -O $TF && sudo sh $TF; rm -f $TF
code
Answer the snapshot questions with "4" as we do not use snapdhots on linux
To configure a path to be backed up use: 
code
urbackupclientctl add-backupdir -d <path>
Example: urbackupclientctl add-backupdir -d /
code
Kick off the initial backup:
code
urbackupclientctl start -f
code
Navigate to the "Activities" page on your urbackup webinterface to view the status:
  
screenshot3
  
After the backup you will also see the system as backed up on the "Status" page:
  
screenshot 4
  
#### Initiate a restore
Create a directory to restore to
code
mkdir /heom/restore
code
Use the CLI or webgiu to browse backups and select a proper one:
code
urbackupclientctl browse -d <pathtofileyouwanttorestore>
code
Example: 
code
root@pm-urbackup-02:~# urbackupclientctl browse -d root/etc/apache2/sites-available/urb.cldsvc.io.conf
[{
"access": 1655283170,
"backupid": 2,
"backuptime": 1655284110,
"creat": 0,
"dir": false,
"mod": 1655283170,
"name": "urb.cldsvc.io.conf",
"shahash": "mugInYwjwafQ+xpt/ympjrhKM5MELMJdAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAA==",
"size": 6532
}
,{
"access": 1655283170,
"backupid": 1,
"backuptime": 1655283775,
"creat": 0,
"dir": false,
"mod": 1655283170,
"name": "urb.cldsvc.io.conf",
"shahash": "mugInYwjwafQ+xpt/ympjrhKM5MELMJdAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAA==",
"size": 6532
}
]
code

#### Initiate the restore:
code
urbackupclientctl restore-start -d root/etc/apache2/sites-available/urb.cldsvc.io.conf -b last -m /etc/apache2/sites-available/urb.cldsvc.io.conf -t /home/restore/urb.cldsvc.io.conf
code
The apache config will be restored into the directory /home/restore/


## Windows



