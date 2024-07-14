#!/bin/bash

# Navigate to the deployment directory
cd /home/ec2-user/deployment

# Stop any running Docker containers
echo "Stopping any running Docker containers..."
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)

# Pull the latest Docker image
echo "Pulling the latest Docker image..."
sudo docker pull <your-dockerhub-username>/my-kong:latest

# Run the Kong API Gateway container
echo "Running the Kong API Gateway container..."
sudo docker run -d --name kong-database \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  postgres:9.6

sudo docker run --rm \
  --link kong-database:kong-database \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  kong:latest kong migrations bootstrap

sudo docker run -d --name kong \
  --link kong-database:kong-database \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  -p 8444:8444 \
  <your-dockerhub-username>/my-kong:latest

# Ensure Kong is running
echo "Checking Kong API status..."
curl -i http://localhost:8001/

# Start the Bitcoin node
echo "Starting the Bitcoin node..."
bitcoind -daemon
