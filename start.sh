#!/bin/bash

project_id="roi-takeoff-user96"
if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$project_id
fi
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/image10
cd infra
terraform init && terraform apply -auto-approve