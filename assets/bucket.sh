#!/bin/bash

# --- CONFIGURATION ---
export MULTI_REGION="EU" 
export BUCKET_NAME="assets-bucket-xcrtzuia"
export BACKEND_BUCKET="assets-backend-bucket"

echo "Creating Multi-Region GCS Bucket"
gcloud storage buckets create gs://$BUCKET_NAME \
    --location=$MULTI_REGION \
    --uniform-bucket-level-access

echo "Setting Public Permissions"
gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
    --member="allUsers" \
    --role="roles/storage.objectViewer"

echo "Creating Backend Bucket"
gcloud compute backend-buckets create $BACKEND_BUCKET \
    --gcs-bucket-name=$BUCKET_NAME \

echo "Done !"
