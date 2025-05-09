#!/bin/bash
# Usage: ./install-python.sh 3.10
source "$(dirname "${BASH_SOURCE[0]}")/version.config"

PYTHON_VERSION_IN="${1:-${PYTHON_VERSION}}"

if [ -z "$PYTHON_VERSION_IN" ]; then
  echo "Usage: $0 <python-version>"
  exit 1
fi

echo "Installing Python $PYTHON_VERSION_IN..."

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python${PYTHON_VERSION_IN} python${PYTHON_VERSION_IN}-venv python${PYTHON_VERSION_IN}-dev

echo "✅ Python version installed:"
python${PYTHON_VERSION_IN} --version

