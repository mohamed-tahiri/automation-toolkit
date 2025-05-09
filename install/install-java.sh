#!/bin/bash
# Usage: ./install-java.sh 17
source "$(dirname "${BASH_SOURCE[0]}")/version.config"

JAVA_VERSION_IN="${1:-${JAVA_VERSION}}"

if [ -z "$JAVA_VERSION_IN" ]; then
  echo "Usage: $0 <java-version>"
  exit 1
fi

echo "Installing OpenJDK $JAVA_VERSION_IN..."

sudo apt update
sudo apt install -y openjdk-${JAVA_VERSION_IN}-jdk

if command -v java &> /dev/null; then
    echo "✅ Java version installed: $(java -version 2>&1 | head -n 1)"
else
    echo "L'installation de Java a échoué."
    exit 1
fi

# Set the default Java version
echo "Setting OpenJDK $JAVA_VERSION_IN as the default Java version..."

# Update alternatives for java, javac, and javaws
sudo update-alternatives --set java /usr/lib/jvm/java-${JAVA_VERSION_IN}-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-${JAVA_VERSION_IN}-openjdk-amd64/bin/javac
sudo update-alternatives --set javaws /usr/lib/jvm/java-${JAVA_VERSION_IN}-openjdk-amd64/bin/javaws

# Verify the default Java version
echo "✅ Default Java version is now set to:"
java -version

