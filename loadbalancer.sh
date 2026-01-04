#!/bin/bash

# --- CONFIGURATION ---
export URL_MAP="myshop"
export HTTP_PROXY="myshop-http-proxy"
export IP_NAME="myshop-anycast-ip"
export FORWARDING_RULE="myshop-frontend"



echo "Creating Global URL Map..."
gcloud compute url-maps create $URL_MAP \
    --default-service="honeypot-backend-service"

echo "Creating Global Frontend..."
gcloud compute target-http-proxies create $HTTP_PROXY \
    --url-map=$URL_MAP

gcloud compute addresses create $IP_NAME \
    --global \
    --ip-version=IPV4

gcloud compute forwarding-rules create $FORWARDING_RULE \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --network-tier=PREMIUM \
    --address=$IP_NAME \
    --global \
    --target-http-proxy=$HTTP_PROXY \
    --ports=80

echo "Done"
