#!/bin/bash
# Usage: ./install-python.sh 3.10

PYTHON_VERSION=$1

if [ -z "$PYTHON_VERSION" ]; then
  echo "Usage: $0 <python-version>"
  exit 1
fi

echo "Installing Python $PYTHON_VERSION..."

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev

echo "✅ Python version installed:"
python${PYTHON_VERSION} --version

