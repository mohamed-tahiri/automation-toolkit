#!/bin/bash
# Usage: ./install-php.sh 8.2
# Or: ./toolkit install php --version 8.2

source "$(dirname "${BASH_SOURCE[0]}")/version.config"

PHP_VERSION_IN="${1:-$PHP_VERSION}"

if [ -z "$PHP_VERSION_IN" ]; then
  echo "Usage: $0 <php-version>"
  exit 1
fi

echo "📦 Installing PHP $PHP_VERSION_IN and common extensions..."

# Add PHP PPA if needed
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Install PHP + common extensions
sudo apt install -y \
  php${PHP_VERSION_IN} php${PHP_VERSION_IN}-cli php${PHP_VERSION_IN}-common \
  php${PHP_VERSION_IN}-fpm php${PHP_VERSION_IN}-intl php${PHP_VERSION_IN}-curl \
  php${PHP_VERSION_IN}-mbstring php${PHP_VERSION_IN}-xml php${PHP_VERSION_IN}-zip \
  php${PHP_VERSION_IN}-mysql php${PHP_VERSION_IN}-pgsql php${PHP_VERSION_IN}-sqlite3

# Set PHP version as default
echo "🔧 Setting PHP ${PHP_VERSION_IN} as the default version..."
sudo update-alternatives --set php /usr/bin/php${PHP_VERSION_IN}
sudo update-alternatives --set phpize /usr/bin/phpize${PHP_VERSION_IN}
sudo update-alternatives --set php-config /usr/bin/php-config${PHP_VERSION_IN}

echo "✅ PHP default version is now: $(php -v | head -n 1)"

