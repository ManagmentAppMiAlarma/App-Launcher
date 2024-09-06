# /bin/bash

echo "Stop Docker Compose"
docker compose -f docker-compose.prod.yml down

echo "Remove Docker Images"
docker rmi aguekdjian/client-api-gateway-prod
docker rmi aguekdjian/clients-ms-prod
docker rmi aguekdjian/auth-ms-prod
docker rmi aguekdjian/orders-ms-prod
docker rmi aguekdjian/frontend

echo "Building images and pushing to Docker Hub"
docker build -f client-api-gateway/Dockerfile.prod -t aguekdjian/client-api-gateway-prod ./client-api-gateway
docker build -f clients-ms/Dockerfile.prod -t aguekdjian/clients-ms-prod ./clients-ms
docker build -f auth-ms/Dockerfile.prod -t aguekdjian/auth-ms-prod ./auth-ms
docker build -f orders-ms/Dockerfile.prod -t aguekdjian/orders-ms-prod ./orders-ms
docker build -f Frontend-App/Dockerfile.prod -t aguekdjian/frontend ./Frontend-App

docker push aguekdjian/client-api-gateway-prod
docker push aguekdjian/clients-ms-prod
docker push aguekdjian/auth-ms-prod
docker push aguekdjian/orders-ms-prod
docker push aguekdjian/frontend

./Application-UP-Prod.sh