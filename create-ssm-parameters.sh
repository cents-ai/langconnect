#!/bin/bash

# Script to create AWS SSM parameters from LangConnect API .env.prod file
# Usage: ./create-ssm-parameters.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# AWS region and profile
REGION="us-east-2"
PROFILE="centsai"

echo -e "${YELLOW}This script will create AWS SSM parameters for LangConnect API${NC}"
echo -e "${YELLOW}Make sure you have AWS CLI configured with appropriate permissions${NC}"
echo ""

# Function to create SSM parameter
create_parameter() {
  local name=$1
  local value=$2
  local type=$3
  
  echo -e "Creating parameter: ${GREEN}$name${NC}"
  
  # Check if parameter already exists
  if aws ssm get-parameter --name "$name" --region "$REGION" --profile "$PROFILE" &>/dev/null; then
    echo -e "${YELLOW}Parameter already exists. Overwriting...${NC}"
    aws ssm put-parameter --name "$name" --value "$value" --type "$type" --overwrite --region "$REGION" --profile "$PROFILE"
  else
    aws ssm put-parameter --name "$name" --value "$value" --type "$type" --region "$REGION" --profile "$PROFILE"
  fi
}

# Process LangConnect .env.prod file
echo -e "\n${GREEN}Processing LangConnect API .env.prod file...${NC}"
ENV_FILE="./.env.prod"

if [ ! -f "$ENV_FILE" ]; then
  echo -e "${RED}LangConnect .env.prod file not found at $ENV_FILE${NC}"
  exit 1
fi

# Read .env.prod file and create parameters
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
  
  # Extract key and value
  if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"
    
    # Remove quotes if present
    value="${value%\"}"
    value="${value#\"}"
    value="${value%\'}"
    value="${value#\'}"
    
    # Use empty string for empty values
    # [[ -z "$value" ]] && continue
    
    # Create parameter with appropriate path
    # Convert key to lowercase using tr
    key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')
    
    # Skip PostgreSQL parameters as they will be created as shared parameters
    if [[ "$key" == "POSTGRES_HOST" || "$key" == "POSTGRES_PORT" || "$key" == "POSTGRES_USER" || 
          "$key" == "POSTGRES_PASSWORD" || "$key" == "POSTGRES_DB" ]]; then
      echo -e "${YELLOW}Skipping $key, will be created as shared parameter${NC}"
      continue
    fi
    
    param_name="/centsai/langconnect-api/$key_lower"
    
    # Determine if this should be a SecureString
    param_type="String"
    if [[ "$key" == *"KEY"* || "$key" == *"SECRET"* || "$key" == *"PASSWORD"* || "$key" == *"TOKEN"* ]]; then
      param_type="SecureString"
    fi
    
    create_parameter "$param_name" "$value" "$param_type"
  fi
done < "$ENV_FILE"

# Create shared PostgreSQL parameters
echo -e "\n${GREEN}Creating shared PostgreSQL parameters...${NC}"

# Extract PostgreSQL values
POSTGRES_HOST=$(grep "POSTGRES_HOST" "$ENV_FILE" | cut -d= -f2)
POSTGRES_PORT=$(grep "POSTGRES_PORT" "$ENV_FILE" | cut -d= -f2)
POSTGRES_USER=$(grep "POSTGRES_USER" "$ENV_FILE" | cut -d= -f2)
POSTGRES_PASSWORD=$(grep "POSTGRES_PASSWORD" "$ENV_FILE" | cut -d= -f2)
POSTGRES_DB=$(grep "POSTGRES_DB" "$ENV_FILE" | cut -d= -f2)

# Create shared parameters
if [[ -n "$POSTGRES_HOST" ]]; then
  create_parameter "/centsai/postgres_host" "$POSTGRES_HOST" "String"
else
  echo -e "${YELLOW}Postgres host is empty, skipping parameter creation${NC}"
fi

if [[ -n "$POSTGRES_PORT" ]]; then
  create_parameter "/centsai/postgres_port" "$POSTGRES_PORT" "String"
else
  echo -e "${YELLOW}Postgres port is empty, skipping parameter creation${NC}"
fi

if [[ -n "$POSTGRES_USER" ]]; then
  create_parameter "/centsai/postgres_user" "$POSTGRES_USER" "String"
else
  echo -e "${YELLOW}Postgres user is empty, skipping parameter creation${NC}"
fi

if [[ -n "$POSTGRES_PASSWORD" ]]; then
  create_parameter "/centsai/postgres_password" "$POSTGRES_PASSWORD" "SecureString"
else
  echo -e "${YELLOW}Postgres password is empty, skipping parameter creation${NC}"
fi

if [[ -n "$POSTGRES_DB" ]]; then
  create_parameter "/centsai/postgres_db" "$POSTGRES_DB" "String"
else
  echo -e "${YELLOW}Postgres DB is empty, skipping parameter creation${NC}"
fi

echo -e "\n${GREEN}All LangConnect API parameters created successfully!${NC}"
echo -e "${YELLOW}To verify, run: aws ssm get-parameters-by-path --path \"/centsai/langconnect-api\" --recursive --region $REGION --profile $PROFILE${NC}"
echo -e "${YELLOW}To verify shared parameters, run: aws ssm get-parameters-by-path --path \"/centsai\" --recursive --region $REGION --profile $PROFILE${NC}"
