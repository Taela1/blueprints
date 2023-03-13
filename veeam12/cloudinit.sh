#!/bin/bash

key=<API_KEY>
secret=<API_SECRET>
zone=<EXOSCALE_ZONE>
bucket=<BUCKET_NAME>

apt install s3cmd -y

s3cmd --add-header=x-amz-bucket-object-lock-enabled:true mb s3://$bucket --access_key=$key --secret_key=$secret --host=sos-$zone.exo.io --region=$zone --host-bucket=$bucket.sos-$zone.exo.io
