#### Infscape Backup Appliance Blueprint

This blueprint can be used to deploy a Infscape Backup appliance on Exoscale and configure SOS as S3 backup endpoint.

A full documentation can be found here: https://www.urbackup.org/admin_guide_app.pdf

### Installation
The installation guide is available at: https://www.infscape.com/urbackup-appliance-download/
Please follow the guide for Install to Cloud Instance

## Prepare Exoscale security-group
The Inscape instance requires the following ports to be open in the security-group:
* tcp/22 for SSH access (only required during installation, can be removed later)
* tcp/80 for http
* tcp/443 for https

## Prepare Exoscale instance
Create a new instance with the following settings:
* Debian 10 Bullseye as template
* at least 4GB RAM (t-shirt medium or higher)
* at least 50GB disk (required for local caching of backup data chunks before uploading to SOS)

## Prepare
