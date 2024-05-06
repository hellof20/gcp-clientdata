#!/bin/bash
# set -e

export PROJECT_ID=speedy-victory-336109
export REGION=asia-southeast1
export IMAGE=hellof20/clientdata:2024050604

if [ ! $PROJECT_ID ]; then
    echo "please set PROJECT_ID"
    exit 1
fi

if [ ! $REGION ]; then
    echo "please set REGION"
    exit 1
fi

echo "Enable firestore and create default database ... "
gcloud services enable firestore.googleapis.com --project $PROJECT_ID
gcloud firestore databases create --database=gcp-client-data-001 --location $REGION  --project $PROJECT_ID

echo "Create service account for clientdata ... "
gcloud iam service-accounts create clientdatasa \
    --description="Service account for clientdata" \
    --display-name="clientdatasa" \
    --project=${PROJECT_ID}


gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:clientdatasa@${PROJECT_ID}.iam.gserviceaccount.com \
    --role='roles/datastore.user'  \
    --condition=None \
    --quiet > /dev/null


echo "Deploy clientdata server on CLoud Run ... "
gcloud run deploy clientdata-01 --image=${IMAGE} \
    --max-instances=8 \
    --min-instances=1 \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --service-account clientdatasa@${PROJECT_ID}.iam.gserviceaccount.com \
    --cpu=2 \
    --memory=2Gi \
    --concurrency=32 \
    --port=8080 \
    --allow-unauthenticated \
    --timeout=30
