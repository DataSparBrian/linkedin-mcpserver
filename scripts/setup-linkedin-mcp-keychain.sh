#!/bin/bash

# LinkedIn MCP Server Keychain Setup Script
# This script stores the DOTENV_PRIVATE_KEY in macOS Keychain for secure storage

set -e  # Exit on error

# Configuration
KEYCHAIN_SERVICE="linkedin-mcp-dotenv-key"
KEYCHAIN_ACCOUNT="linkedin-mcp-server"

echo "======================================"
echo "LinkedIn MCP Server Keychain Setup"
echo "======================================"
echo ""
echo "This script will store your DOTENV_PRIVATE_KEY in macOS Keychain."
echo "The key will be encrypted and accessible only with your macOS user authentication."
echo ""

# Check if key already exists
if security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" &>/dev/null; then
    echo "⚠️  A key already exists in Keychain for this service."
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
    # Delete existing key
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null || true
fi

# Prompt for the DOTENV_PRIVATE_KEY
echo ""
echo "Please enter your DOTENV_PRIVATE_KEY:"
echo "(You can find this in your current MCP config or .env.local file)"
read -s DOTENV_PRIVATE_KEY
echo ""

# Validate that key is not empty
if [ -z "$DOTENV_PRIVATE_KEY" ]; then
    echo "❌ Error: DOTENV_PRIVATE_KEY cannot be empty"
    exit 1
fi

# Store the key in macOS Keychain
security add-generic-password \
    -s "$KEYCHAIN_SERVICE" \
    -a "$KEYCHAIN_ACCOUNT" \
    -w "$DOTENV_PRIVATE_KEY" \
    -U

echo ""
echo "✅ Successfully stored DOTENV_PRIVATE_KEY in macOS Keychain!"
echo ""
echo "Next steps:"
echo "1. Make the startup script executable:"
echo "   chmod +x scripts/start-linkedin-mcp.sh"
echo ""
echo "2. Update your MCP configuration to use the wrapper script:"
echo "   Replace the 'linkedin' server configuration with:"
echo '   "command": "/Users/brianeiler/Git/linkedin-mcpserver/scripts/start-linkedin-mcp.sh"'
echo ""
echo "3. Restart your MCP client (Claude Desktop, etc.)"
echo ""
echo "The DOTENV_PRIVATE_KEY will now be securely retrieved from Keychain at runtime."
echo "======================================"
