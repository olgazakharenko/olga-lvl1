#!/bin/bash

project_id="roi-takeoff-user94"
if [ $GOOGLE_CLOUD_PROJECT == "" ]; then
	export GOOGLE_CLOUD_PROJECT=$project_id
fi
gcloud auth login
gcloud builds submit --tag=gcr.io/$GOOGLE_CLOUD_PROJECT/go-pets:latest .
cd infra
terraform init && terraform apply -auto-approve

#gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/image10

