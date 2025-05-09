#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/version.config"

NODE_VERSION_IN="${1:-${NODE_VERSION}}"

echo "Starting Node.js installation..."
echo "Installing Node.js version: $NODE_VERSION_IN"

# Install the specified Node.js version
curl -sL https://deb.nodesource.com/setup_$NODE_VERSION_IN.x | sudo -E bash -
sudo apt-get install -y nodejs

# Check installation
node -v
npm -v

echo "Node.js $NODE_VERSION_IN installed successfully."

