#!/bin/bash

# Script to register LangConnect API ECS task definition
# Usage: ./register-task-definition.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# AWS region and profile
REGION="us-east-2"
PROFILE="centsai"

# Task definition file
TASK_DEF_FILE="./langconnect-api-task-definition.json"

if [ ! -f "$TASK_DEF_FILE" ]; then
  echo -e "${RED}Task definition file not found at $TASK_DEF_FILE${NC}"
  exit 1
fi

echo -e "${YELLOW}Registering LangConnect API task definition...${NC}"
RESULT=$(aws ecs register-task-definition \
  --cli-input-json file://$TASK_DEF_FILE \
  --region $REGION \
  --profile $PROFILE)

# Extract the revision number
REVISION=$(echo $RESULT | grep -o '"revision": [0-9]*' | awk '{print $2}')
TASK_DEF_ARN=$(echo $RESULT | grep -o '"taskDefinitionArn": "[^"]*"' | cut -d'"' -f4)

echo -e "${GREEN}Task definition registered successfully!${NC}"
echo -e "Task definition ARN: ${YELLOW}$TASK_DEF_ARN${NC}"
echo -e "Revision: ${YELLOW}$REVISION${NC}"
echo ""
echo -e "${YELLOW}To update your service with this new task definition, run:${NC}"
echo -e "aws ecs update-service --cluster centsai-cluster --service langconnect-api-service --task-definition langconnect-api-task:$REVISION --region $REGION --profile $PROFILE"
