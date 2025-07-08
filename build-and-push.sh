#!/bin/bash

# Script to build and push LangConnect API Docker image to ECR
# Usage: ./build-and-push.sh [tag]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# AWS region and profile
REGION="us-east-2"
PROFILE="centsai"
AWS_ACCOUNT_ID="{{AWS_ACCOUNT_ID}}"

# ECR repository
ECR_REPO="$AWS_ACCOUNT_ID.dkr.ecr.us-east-2.amazonaws.com/langconnect-api"

# Image tag (default to latest if not provided)
TAG=${1:-"latest"}

echo -e "${YELLOW}Building and pushing LangConnect API Docker image to ECR...${NC}"
echo -e "Repository: ${GREEN}$ECR_REPO${NC}"
echo -e "Tag: ${GREEN}$TAG${NC}"

# Get ECR login token
echo -e "\n${YELLOW}Logging in to ECR...${NC}"
aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $ECR_REPO

# Build the Docker image
echo -e "\n${YELLOW}Building Docker image for x86_64/amd64 architecture...${NC}"

# Use buildx with platform flag to build for amd64
docker buildx build --platform=linux/amd64 --load -t langconnect-api:$TAG .

# Verify the architecture
echo -e "${YELLOW}Verifying image architecture...${NC}"
ARCH=$(docker inspect langconnect-api:$TAG --format '{{.Os}}/{{.Architecture}}')
echo -e "Image architecture: ${GREEN}$ARCH${NC}"

# Tag the image for ECR
echo -e "\n${YELLOW}Tagging Docker image for ECR...${NC}"
docker tag langconnect-api:$TAG $ECR_REPO:$TAG

# Push to ECR
echo -e "\n${YELLOW}Pushing Docker image to ECR...${NC}"
docker push $ECR_REPO:$TAG

echo -e "\n${GREEN}Successfully built and pushed LangConnect API image to ECR!${NC}"
echo -e "Image: ${YELLOW}$ECR_REPO:$TAG${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "1. Run ./register-task-definition.sh to register a new task definition"
echo -e "2. Run ./deploy-ecs-service.sh update to update the service with the new task definition"
