#!/bin/bash
# Usage: ./install-php.sh 8.2
source "$(dirname "${BASH_SOURCE[0]}")/version.config"

PHP_VERSION_IN="${1:-$PHP_VERSION}"

if [ -z "$PHP_VERSION_IN" ]; then
  echo "Usage: $0 <php-version>"
  exit 1
fi

echo "Installing PHP $PHP_VERSION_IN..."

# Debian/Ubuntu-based systems
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php${PHP_VERSION_IN} php${PHP_VERSION_IN}-cli php${PHP_VERSION_IN}-common

if command -v php &> /dev/null; then
	echo "✅ PHP version installed: $(php -v | head -n 1)"
else
	echo "L'installation de PHP a echoue."
	exit 1
fi

# Set PHP VERSION as the default version
echo "Setting PHP ${PHP_VERSION_IN} as the default version..."
sudo update-alternatives --set php /usr/bin/php${PHP_VERSION_IN}
sudo update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION_IN}
sudo update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION_IN}

# Verify the default PHP version
echo "✅ PHP default version is now set to: $(php -v | head -n 1)"
