# How to use Exoscale Scalable Object Storage (SOS) with object lock with Veeam for immutable backups

Exoscale SOS with object lock can be used with software products from Veeam to create an immutable, secure and safe backup environment. This can be used to substitute WORM off-site backup architectures as well as to actively store backups from clients, mobile devices, O365 and workloads running on Exoscale.

#### Prerequisites
As prerequisites you'll have to:
* access to Exoscale environment
* an Exoscale API key (unrestricted or restricted to storage)
* [s3cmd](https://s3tools.org/s3cmd) installed

Available Exoscale zones can be found here:
``` 
Geneva, Switzerland: ch-gva-2
Zurich, Switzerland: ch-dk-2
Vienna, Austria: at-vie-1
Frankfurt, Germany: de-fra-1
Munich, Germany: de-muc-1
Sofia, Bulgaria: bg-sof-1

```

#### Create SOS bucket with object lock enabled
Use s3cmd to create a bucket with object lock:
``` 
s3cmd --add-header=x-amz-bucket-object-lock-enabled:true mb s3://<BUCKET_NAME> --access_key=<EXOSCALE_API_KEY> --secret_key=<EXOSCALE_API_SECRET> --host=sos-<ZONE>.exo.io --region=<ZONE> --host-bucket=<BUCKET_NAME>.sos-<ZONE>.exo.io
```
An example with Frankfurt as zone and veeam-immutable-backup as bucket name:
``` 
s3cmd --add-header=x-amz-bucket-object-lock-enabled:true mb s3://veeam-immutable-backup --access_key=EXO0123456789XXXX --secret_key=XXXX --host=sos-de-fra-1.exo.io --region=de-fra-1 --host-bucket=veeam-immutable-backup.sos-de-fra-1.exo.io
```
Alternatively you can spawn a default virtual compute (just leave all settings as is) and use the cloud-init to let it create your bucket. Once that bucket is created you can delete the virtual compute and the API key used to create the bucket.
To do so copy and paste the following script into the "User data" field on the virtual compute creation page:
``` 
#!/bin/bash

key=<API_KEY>
secret=<API_SECRET>
zone=<EXOSCALE_ZONE>
bucket=<BUCKET_NAME>

apt install s3cmd -y

s3cmd --add-header=x-amz-bucket-object-lock-enabled:true mb s3://$bucket --access_key=$key --secret_key=$secret --host=sos-$zone.exo.io --region=$zone --host-bucket=$bucket.sos-$zone.exo.io
```
Check in the UI that the bucket is created and visible. If you used a virtual compute to create the bucket you can now delete the virtual compute and the API key used to create the bucket if it was a dedicated key

# Use cases with Exoscale SOS and Veeam

using Exoscale SOS and Veeam for different use cases

## Veeam 12 SOS backup repository

creating Veeam 12 backup repository on Exoscale SOS to provide a valid endpoint for different use cases with Veeam

#### Prerequisites
* access to Veeam 12 Backup&Replication server
* Exoscale SOS bucket with object lock enabled
* API key for bucket to use (can be restricted to storage and the bucket to use)

#### Configure exoscale SOS repository in Veeam
* Open the Veeam backup and Replication console
* Navigate to "Backup Infrastructure"
* Navigate to "Backup Respositories"
* Click on "Add Repository"
* Select the last option "Object storage"
* Select the first option "S3 Compatible
* Give the repository a name
* Enter "Service point", "Region" and use the API Key to create credentials for this bucket

![alt_text](https://github.com/Taela1/blueprints/blob/main/veeam12/veeam-12-1.png)

* click on Browse and select the bucket
* click on Browse and create a new folder for this process
* check the "Make recent backups immutable for:" box and configure days backups should be immutable

![alt_text](https://github.com/Taela1/blueprints/blob/main/veeam12/veeam-12-2.png)

* configure as you need and finish the process
* The respository is visible in "Backup Repositories" and can now be used in Veeam 12

![alt_text](https://github.com/Taela1/blueprints/blob/main/veeam12/veeam-12-3.png)

## Using Exoscale SOS repository as immutable Scale-out for existing performance tier

#### Prerequisites
* access to Veeam 12 Backup&Replication server
* Configured backup repository with object lock enabled on Exoscale SOS

#### Configuration
* Open the Veeam backup and Replication console
* Navigate to "Backup Infrastructure"
* Navigate to "Scale-out Repositories"
* Click on "Add Scale-out Repository"
* Give the repository a name
* Add the Performance Tier the backups are initialy written to
* Choose either "Data locality" or "Performance" mode
* Check the "Extend scale-out backup repository capacity with object storage"
* Click on "Choose..." and select the Exoscale SOS based repository
* Configure when backups should be scaled out from the configured Performance Tier to the Scale-out repository
* We highly recommend enabling encryption of the backups
* Finish the process

## Using Exoscale SOS repository as Performance Tier to backup workloads running on Exoscale or mobe clients over the internet

#### Prerequisites
* access to Veeam 12 Backup&Replication server running on Exoscale with a minimum of 200GB disk
* access to potiential systems to be backed up
* Configured backup repository with object lock enabled on Exoscale SOS

#### Configuration
* Open the Veeam backup and Replication console
* Navigate to "Home"
* Click on "Backup Job"
* Select the job you want to create
* Note: For Exoscale this is "Windows computer" or "Linux computer"
* Configure the backup job as documented from Veeam 12
* Run the backups
