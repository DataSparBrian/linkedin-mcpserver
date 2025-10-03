#!/bin/bash

# LinkedIn MCP Server Startup Script
# This script retrieves the DOTENV_PRIVATE_KEY from macOS Keychain
# and starts the Docker container with the decryption key

set -e  # Exit on error

# Configuration
KEYCHAIN_SERVICE="linkedin-mcp-dotenv-key"
DOCKER_IMAGE="DataSparBrian/mcp-linkedin-server:latest"

# Retrieve the decryption key from macOS Keychain
DOTENV_PRIVATE_KEY=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -w 2>/dev/null)

# Check if key was retrieved successfully
if [ -z "$DOTENV_PRIVATE_KEY" ]; then
    echo "Error: DOTENV_PRIVATE_KEY not found in Keychain" >&2
    echo "Please run the setup script first: ./scripts/setup-linkedin-mcp-keychain.sh" >&2
    exit 1
fi

# Start the Docker container with the decryption key
exec docker run -i --rm \
    -e "DOTENV_PRIVATE_KEY=$DOTENV_PRIVATE_KEY" \
    "$DOCKER_IMAGE"
