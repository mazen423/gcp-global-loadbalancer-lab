#!/bin/bash

# --- CONFIGURATION ---
export REGION="europe-west3"
export ZONE="europe-west3-c"
export SUBNET="europe-west3-subnet"
export VM_NAME="user-account-vm"
export NEG_NAME="user-account-neg"
export BACKEND_SERVICE="user-account-backend-service"
export HEALTH_CHECK="user-account-health-check"
export NETWORK="glb-lab-vpc"

echo "Creating VM in $SUBNET..."
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP \
    --subnet=$SUBNET \
    --metadata-from-file=startup-script=startup.sh \
    --no-address


echo "Creating Zonal NEG"
gcloud compute network-endpoint-groups create $NEG_NAME \
    --network-endpoint-type=GCE_VM_IP_PORT \
    --zone=$ZONE \
    --network=$NETWORK \
    --subnet=$SUBNET \
    --default-port=5000

echo "Adding VM Endpoint to NEG"
gcloud compute network-endpoint-groups update $NEG_NAME \
    --zone=$ZONE \
    --add-endpoint="instance=$VM_NAME,port=5000"

echo "Creating Health Check..."
gcloud compute health-checks create http $HEALTH_CHECK --port=5000 --request-path="/account"

echo " Creating Backend Service"
gcloud compute backend-services create $BACKEND_SERVICE \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --protocol=HTTP \
    --health-checks=$HEALTH_CHECK \
    --global

echo "Attaching Zonal NEG to Backend Service"
gcloud compute backend-services add-backend $BACKEND_SERVICE \
    --global \
    --network-endpoint-group=$NEG_NAME \
    --network-endpoint-group-zone=$ZONE \
    --balancing-mode=RATE \
    --max-rate-per-endpoint=100

echo "Done."