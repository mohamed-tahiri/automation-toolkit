#!/bin/bash
# Usage: ./install-java.sh 17

JAVA_VERSION=$1

if [ -z "$JAVA_VERSION" ]; then
  echo "Usage: $0 <java-version>"
  exit 1
fi

echo "Installing OpenJDK $JAVA_VERSION..."

sudo apt update
sudo apt install -y openjdk-${JAVA_VERSION}-jdk

echo "✅ Java version installed:"
java -version

