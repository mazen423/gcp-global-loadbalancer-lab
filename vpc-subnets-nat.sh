#!/bin/bash

# --- CONFIGURATION ---
export VPC_NAME="glb-lab-vpc"
export REGION_1="europe-west3"
export REGION_2="us-central1"
export SUBNET_1_NAME="europe-west3-subnet"
export SUBNET_1_RANGE="10.0.1.0/24"
export SUBNET_2_NAME="us-central1-subnet"
export SUBNET_2_RANGE="10.0.2.0/24"

# 0. Create VPC
echo "Creating Custom VPC"
gcloud compute networks create $VPC_NAME --subnet-mode=custom

# 1. Create Subnets
echo "Creating Subnet 1 in $REGION_1"
gcloud compute networks subnets create $SUBNET_1_NAME \
    --network=$VPC_NAME \
    --region=$REGION_1 \
    --range=$SUBNET_1_RANGE

echo "Creating Subnet 2 in $REGION_2"
gcloud compute networks subnets create $SUBNET_2_NAME \
    --network=$VPC_NAME \
    --region=$REGION_2 \
    --range=$SUBNET_2_RANGE

# 2. Setup NAT for Region 1
echo "Setting up NAT for $REGION_1"
gcloud compute routers create router-$REGION_1 \
    --network=$VPC_NAME \
    --region=$REGION_1

gcloud compute routers nats create nat-$REGION_1 \
    --router=router-$REGION_1 \
    --region=$REGION_1 \
    --auto-allocate-nat-external-ips \
    --nat-all-subnet-ip-ranges

# 3. Setup NAT for Region 2
#echo "☁️ Setting up NAT for $REGION_2..."
#gcloud compute routers create router-$REGION_2 \
#    --network=$VPC_NAME \
#    --region=$REGION_2

#gcloud compute routers nats create nat-$REGION_2 \
#    --router=router-$REGION_2 \
#    --region=$REGION_2 \
#    --auto-allocate-nat-external-ips \
#    --nat-all-subnet-ip-ranges

echo "Done!"