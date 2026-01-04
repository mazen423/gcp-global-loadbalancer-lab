#!/bin/bash

# --- CONFIGURATION ---
export VPC_NAME="glb-lab-vpc"
export REGION="europe-west3"
export ZONE_1="europe-west3-a"
export SUBNET_NAME="europe-west3-subnet"
export TEMPLATE_NAME="checkout-template"
export MIG_NAME="checkout-managed-group"
export HEALTH_CHECK="checkout-http-health-check"
export BACKEND_SERVICE="checkout-backend-service"

echo "Creating Instance Template"
gcloud compute instance-templates create $TEMPLATE_NAME \
    --machine-type=e2-micro \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP \
    --network=$VPC_NAME \
    --subnet=$SUBNET_NAME \
    --region=$REGION \
    --no-address \
    --metadata-from-file=startup-script=startup.sh \

echo "Creating Managed Instance Group (MIG)"
gcloud compute instance-groups managed create $MIG_NAME \
    --region=$REGION \
    --template=$TEMPLATE_NAME \
    --size=1 \

# Set named port for the group
gcloud compute instance-groups managed set-named-ports $MIG_NAME \
    --region=$REGION \
    --named-ports=http:3000

echo "Creating Health Check"
gcloud compute health-checks create http $HEALTH_CHECK --port 3000 --request-path="/checkout"


echo " Setting up Backend Service"
gcloud compute backend-services create $BACKEND_SERVICE \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=$HEALTH_CHECK \
    --global


echo " Attaching MIG to Backend Service"
gcloud compute backend-services add-backend $BACKEND_SERVICE \
    --instance-group=$MIG_NAME \
    --instance-group-region=$REGION \
    --global \
    --balancing-mode=UTILIZATION \
    --max-utilization=0.8

echo "Done"