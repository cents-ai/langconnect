#!/bin/bash

# Script to deploy LangConnect API ECS service
# Usage: ./deploy-ecs-service.sh [create|update]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# AWS region and profile
REGION="us-east-2"
PROFILE="centsai"

# Set variables
CLUSTER_NAME="centsai-cluster"
SERVICE_NAME="langconnect-api-service"
TASK_FAMILY="langconnect-api-task"

# Get the latest task definition revision
TASK_DEF_REVISION=$(aws ecs describe-task-definition \
  --task-definition $TASK_FAMILY \
  --region $REGION \
  --profile $PROFILE \
  --query 'taskDefinition.revision' \
  --output text)

TASK_DEFINITION="${TASK_FAMILY}:${TASK_DEF_REVISION}"

# Check if we're creating or updating
ACTION=${1:-"update"}

if [ "$ACTION" == "create" ]; then
  echo -e "${YELLOW}Creating new LangConnect API service...${NC}"
  
  # You'll need to fill in these values for your environment
  SUBNET_1="subnet-XXXXXXXXXXXXXXXXX" # Replace with your subnet ID
  SUBNET_2="subnet-XXXXXXXXXXXXXXXXX" # Replace with your subnet ID
  SECURITY_GROUP="sg-XXXXXXXXXXXXXXXXX" # Replace with your security group ID
  
  aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_DEFINITION \
    --desired-count 1 \
    --launch-type EC2 \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_1,$SUBNET_2],securityGroups=[$SECURITY_GROUP],assignPublicIp=ENABLED}" \
    --region $REGION \
    --profile $PROFILE
    
  echo -e "${GREEN}Service created successfully!${NC}"
  
elif [ "$ACTION" == "update" ]; then
  echo -e "${YELLOW}Updating LangConnect API service to use task definition $TASK_DEFINITION...${NC}"
  
  aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition $TASK_DEFINITION \
    --region $REGION \
    --profile $PROFILE
    
  echo -e "${GREEN}Service update initiated!${NC}"
  
else
  echo -e "${RED}Invalid action. Use 'create' or 'update'${NC}"
  exit 1
fi

echo -e "\n${YELLOW}To check service status, run:${NC}"
echo -e "aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $REGION --profile $PROFILE"

echo -e "\n${YELLOW}To list running tasks, run:${NC}"
echo -e "aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --region $REGION --profile $PROFILE"

echo -e "\n${YELLOW}To view task logs (replace TASK_ID with actual task ID):${NC}"
echo -e "aws logs get-log-events --log-group-name /ecs/langconnect-api-task --log-stream-name ecs/langconnect-api-container/TASK_ID --region $REGION --profile $PROFILE"
