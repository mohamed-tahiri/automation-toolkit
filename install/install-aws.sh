#!/bin/bash

set -euo pipefail

echo "Installing AWS CLI..."

# Install unzip if it's not already installed
sudo apt update
sudo apt install -y unzip

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version

echo "AWS CLI installed successfully."

