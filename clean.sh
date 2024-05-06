#!/bin/bash
# set -e

export PROJECT_ID=speedy-victory-336109
export REGION=asia-southeast1

if [ ! $PROJECT_ID ]; then
    echo "please set PROJECT_ID"
    exit 1
fi

if [ ! $REGION ]; then
    echo "please set REGION"
    exit 1
fi

gcloud run services delete clientdata-001 --project=${PROJECT_ID} --region=${REGION} --quiet

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:clientdatasa@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/datastore.user' \
    --condition=None > /dev/null

gcloud iam service-accounts delete clientdatasa@${PROJECT_ID}.iam.gserviceaccount.com \
    --project=${PROJECT_ID} --quiet > /dev/null