#!/bin/bash

# --- CONFIGURATION ---
export REGION="europe-west3"
export ZONE="europe-west3-c"
export VM_NAME="honeypot-vm"
export SUBNET="europe-west3-subnet"
export UMIG_NAME="honeypot-unmanaged-group"
export BACKEND_SERVICE="honeypot-backend-service"
export HEALTH_CHECK="honeypot-health-check"

echo "Creating Spot VM for honeypot"
gcloud compute instances create $VM_NAME \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --subnet=$SUBNET \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP \
    --metadata-from-file=startup-script=startup.sh \

echo "Creating Unmanaged Instance Group"
gcloud compute instance-groups unmanaged create $UMIG_NAME \
    --zone=$ZONE

echo "Adding  VM to the Group"
gcloud compute instance-groups unmanaged add-instances $UMIG_NAME \
    --zone=$ZONE \
    --instances=$VM_NAME

echo "Setting Named Port (http:80)."
gcloud compute instance-groups unmanaged set-named-ports $UMIG_NAME \
    --zone=$ZONE \
    --named-ports=http:80

echo "Creating HTTP Health Check."
gcloud compute health-checks create http $HEALTH_CHECK --port=80 --request-path="/"

echo "Creating Backend Service"
gcloud compute backend-services create $BACKEND_SERVICE \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=$HEALTH_CHECK \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --global

echo "Attaching Unmanaged Group to Backend Service"
gcloud compute backend-services add-backend $BACKEND_SERVICE \
    --instance-group=$UMIG_NAME \
    --instance-group-zone=$ZONE \
    --balancing-mode=UTILIZATION \
    --global

echo "Done!"