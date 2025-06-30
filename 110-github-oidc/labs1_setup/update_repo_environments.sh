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

# Create a temporary file for the repository configuration
TEMP_CONFIG=$(mktemp)

# Get the current repository configuration
echo "Fetching current repository configuration..."
if ! jf rt curl -XGET "/api/repositories/$REPO_NAME" --server-id="$SERVER_ID" > "$TEMP_CONFIG" 2>/dev/null; then
    echo "Error: Failed to fetch repository configuration for '$REPO_NAME'"
    rm -f "$TEMP_CONFIG"
    exit 1
fi

# Check if the repository exists and we got valid JSON
if [ ! -s "$TEMP_CONFIG" ]; then
    echo "Error: Repository '$REPO_NAME' not found or empty response"
    rm -f "$TEMP_CONFIG"
    exit 1
fi

# Convert comma-separated environments to JSON array format
# Remove spaces and split by comma
ENV_ARRAY=$(echo "$ENVIRONMENTS" | tr -d ' ' | tr ',' '\n' | jq -R . | jq -s .)

# Update the JSON configuration to include the environments
echo "Updating configuration with environments: $ENV_ARRAY"
if ! jq --argjson envs "$ENV_ARRAY" '.environments = $envs' "$TEMP_CONFIG" > "${TEMP_CONFIG}.updated"; then
    echo "Error: Failed to update JSON configuration"
    rm -f "$TEMP_CONFIG" "${TEMP_CONFIG}.updated"
    exit 1
fi

# Update the repository with the modified configuration
echo "Updating repository configuration..."
if jf rt curl -XPOST "/api/repositories/$REPO_NAME" --server-id="$SERVER_ID" -H "Content-Type: application/json" -d @"${TEMP_CONFIG}.updated"; then
    echo "Successfully updated repository '$REPO_NAME' with environments: $ENVIRONMENTS"
else
    echo "Error: Failed to update repository configuration"
    rm -f "$TEMP_CONFIG" "${TEMP_CONFIG}.updated"
    exit 1
fi

# Clean up temporary files
rm -f "$TEMP_CONFIG" "${TEMP_CONFIG}.updated"

echo "Repository update completed successfully!" 