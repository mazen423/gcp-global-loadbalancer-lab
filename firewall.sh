export VPC_NAME="glb-lab-vpc"

echo "ceating Firewall for Health Checks"
gcloud compute firewall-rules create allow-health-checks \
    --network=$VPC_NAME \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp:80,tcp:3000,tcp:5000