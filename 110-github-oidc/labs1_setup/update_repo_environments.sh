#!/bin/bash

# Script to update repository environments using JFrog CLI
# Usage: ./update_repo_environments.sh <server-id> <repository-name> <environment-list>
# Example: ./update_repo_environments.sh psazuse lab110-npm-dev-local "DEV"

# Check if correct number of arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <server-id> <repository-name> <environment-list>"
    echo "Example: $0 psazuse lab110-npm-dev-local \"DEV\""
    echo "Example: $0 psazuse lab110-npm-dev-local \"DEV,PROD\""
    exit 1
fi

SERVER_ID="$1"
REPO_NAME="$2"
ENVIRONMENTS="$3"

echo "Updating repository '$REPO_NAME' on server '$SERVER_ID' with environments: $ENVIRONMENTS"

# Get repository configuration and store in a variable
echo "Fetching current repository configuration..."
REPO_JSON=$(jf rt curl -s -XGET "/api/repositories/$REPO_NAME" --server-id="$SERVER_ID")

# Validate JSON
if ! echo "$REPO_JSON" | jq . > /dev/null; then
  echo "Error: Failed to fetch or parse repository configuration for '$REPO_NAME'"
  exit 1
fi

# Build the environments array
ENV_ARRAY=$(echo "$ENVIRONMENTS" | tr -d ' ' | tr ',' '\n' | jq -R . | jq -s .)
echo "Updating configuration with environments: $ENV_ARRAY"


# Modify JSON with new environments
UPDATED_JSON=$(echo "$REPO_JSON" | jq --argjson envs "$ENV_ARRAY" '.environments = $envs')

# POST updated JSON back to Artifactory
echo "Updating repository configuration..."
echo "$UPDATED_JSON" 
if jf rt curl -s -XPOST "/api/repositories/$REPO_NAME" \
  --server-id="$SERVER_ID" \
  -H "Content-Type: application/json" \
  -d @<(echo "$UPDATED_JSON"); then
  echo "Successfully updated repository '$REPO_NAME' with environments: $ENVIRONMENTS"
else
  echo "Error: Failed to update repository configuration"
  exit 1
fi
