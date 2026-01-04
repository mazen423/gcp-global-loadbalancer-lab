#!/bin/bash

# --- CONFIGURATION ---
export REGION="europe-west3"
export SERVICE_NAME="frontend-backend-service"
export NEG_NAME="frontend-neg"
export BACKEND_SERVICE_NAME="frontend-backend-service"
export IMAGE="REPLACE-ME"

# 1. Deploy Cloud Run Service For Frontend 
echo "Deploying Cloud Run service."
gcloud run deploy $SERVICE_NAME \
    --image=$IMAGE \
    --region=$REGION \
    --ingress=internal-and-cloud-load-balancing \
    --port=8080 \
    --allow-unauthenticated \
    --quiet

# 2. Create the Serverless Network Endpoint Group (NEG)
echo "Creating Serverless NEG"
gcloud compute network-endpoint-groups create $NEG_NAME \
    --region=$REGION \
    --network-endpoint-type=serverless \
    --cloud-run-service=$SERVICE_NAME \
    --quiet

# 3. Create the Global Backend Service
# EXTERNAL_MANAGED for the newest External Load Balancer(Not Classic)
echo "Creating Backend Service"
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global \
    --quiet

# 4. Attach the NEG to the Backend Service
echo "Attaching NEG to Backend Service"
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --global \
    --network-endpoint-group=$NEG_NAME \
    --network-endpoint-group-region=$REGION \
    --quiet

echo "Done!"
