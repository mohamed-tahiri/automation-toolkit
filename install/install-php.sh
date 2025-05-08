#!/bin/bash
# Usage: ./install-php.sh 8.2

PHP_VERSION=$1

if [ -z "$PHP_VERSION" ]; then
  echo "Usage: $0 <php-version>"
  exit 1
fi

echo "Installing PHP $PHP_VERSION..."

# Debian/Ubuntu-based systems
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-common

echo "✅ PHP version installed:"
php -v

