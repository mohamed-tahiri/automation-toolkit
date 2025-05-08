#!/bin/bash
# Configure NGINX to work with a specific PHP version
# Usage: ./setup-nginx-php.sh 8.2

PHP_VERSION=$1

if [ -z "$PHP_VERSION" ]; then
  echo "Usage: $0 <php-version>"
  exit 1
fi

echo "🔧 Configuration de NGINX avec PHP $PHP_VERSION..."

sudo apt update
sudo apt install -y nginx php${PHP_VERSION}-fpm

NGINX_CONF="/etc/nginx/sites-available/default"

sudo sed -i "s/php[0-9.]*-fpm.sock/php${PHP_VERSION}-fpm.sock/g" $NGINX_CONF
sudo systemctl restart nginx

echo "✅ NGINX configuré avec PHP $PHP_VERSION"

