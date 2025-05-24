#!/bin/bash

# Usage: ./nginx-php.sh <project-name> <project-path> [options]
# Example: ./nginx-php.sh my-site ~/automation-toolkit/my-site 

set -euo pipefail

# Detect PHP version installed
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

# Validate arguments
if [ $# -lt 2 ]; then
  echo "❌ Usage: $0 <project-name> <project-path> [options]"
  echo "Example: $0 my-site ~/automation-toolkit/my-site "
  exit 1
fi

PROJECT_NAME="$1"
PROJECT_ROOT="$(realpath "$2")"
PUBLIC_DIR="$PROJECT_ROOT/public"
PUBLIC_WEB="$PROJECT_ROOT/web"

# Fallback to project root if /public does not exist
if [ ! -d "$PUBLIC_DIR" ]; then
  PUBLIC_DIR="$PROJECT_ROOT"
fi

NGINX_AVAILABLE="/etc/nginx/sites-available/$PROJECT_NAME"
NGINX_ENABLED="/etc/nginx/sites-enabled/$PROJECT_NAME"
SERVER_IP=$(curl -s http://checkip.amazonaws.com)

# Choose a random port between 8000 and 8999 for the PHP server
PHP_PORT=$(( RANDOM % 1000 + 8000 ))

echo "🔍 Checking prerequisites..."

# Install Nginx if missing
if ! command -v nginx &>/dev/null; then
  echo "📦 Installing Nginx..."
  sudo apt update
  sudo apt install -y nginx
  sudo systemctl start nginx
  sudo systemctl enable nginx
fi

# Install Symfony CLI if not found
if ! command -v symfony &>/dev/null; then
  echo "⚠️ Symfony CLI not found. Installing..."
  curl -sS https://get.symfony.com/cli/installer | bash
  sudo mv ~/.symfony/bin/symfony /usr/local/bin/symfony
  if ! command -v symfony &>/dev/null; then
    echo "❌ Failed to install Symfony CLI, please install manually."
    exit 1
  fi
  echo "✅ Symfony CLI installed."
else
  echo "✅ Symfony CLI found."
fi

# Create or update log file with appropriate permissions
LOG_FILE="$PROJECT_ROOT/php-server.log"
if [ ! -e "$LOG_FILE" ]; then
  sudo touch "$LOG_FILE"
fi
sudo chmod 664 "$LOG_FILE"
sudo chown "$(whoami)":"$(whoami)" "$LOG_FILE"

# Detect project type by checking composer.json dependencies
# Detect project type by checking composer.json dependencies
if [ -f "$PROJECT_ROOT/composer.json" ]; then
  if grep -q '"symfony/symfony"' "$PROJECT_ROOT/composer.json"; then
    PROJECT_TYPE="symfony"
  elif grep -q '"prestashop/prestashop"' "$PROJECT_ROOT/composer.json"; then
    PROJECT_TYPE="prestashop"
  elif grep -q '"laravel/framework"' "$PROJECT_ROOT/composer.json"; then
    PROJECT_TYPE="laravel"
  elif grep -q '"drupal/drupal"' "$PROJECT_ROOT/composer.json"; then
    PROJECT_TYPE="drupal"
  else
    PROJECT_TYPE="php"
  fi
else
  PROJECT_TYPE="php"
fi

echo "🛠 Detected project type: $PROJECT_TYPE"

# Kill any process occupying the PHP port to avoid conflicts
echo "🛑 Killing any process using port $PHP_PORT"
sudo fuser -k "${PHP_PORT}/tcp" || true

# Start the appropriate PHP server based on project type
case $PROJECT_TYPE in
  symfony)
    echo "🚀 Starting Symfony local server on port $PHP_PORT..."
    nohup symfony server:start --no-tls --listen-ip=0.0.0.0 --port=$PHP_PORT --dir="$PROJECT_ROOT" > "$LOG_FILE" 2>&1 &
    ;;
  laravel)
    echo "🚀 Starting Laravel artisan serve on port $PHP_PORT..."
    nohup php "$PROJECT_ROOT/artisan" serve --host=127.0.0.1 --port=$PHP_PORT > "$LOG_FILE" 2>&1 &
    ;;
  prestashop)
    echo "🚀 Starting Prestashop project a serve on port $PHP_PORT..."
    nohup php -S 0.0.0.0:$PHP_PORT -t $PROJECT_ROOT > "$LOG_FILE" 2>&1 & 
    ;;
  drupal)
    echo "🚀 Starting Drupal project a serve on port $PHP_PORT..."
    nohup php -S 0.0.0.0:$PHP_PORT -t "$PROJECT_ROOT/web" > "$LOG_FILE" 2>&1 &
    ;;
  php)
    echo "🚀 Starting generic PHP built-in server on port $PHP_PORT..."
    nohup php -S 0.0.0.0:$PHP_PORT > "$LOG_FILE" 2>&1 &
    ;;
  *)
    echo "❌ Unknown project type. Cannot start server automatically."
    exit 1
    ;;
esac

sleep 3  # wait a bit for server to start

echo "⚙️ Creating Nginx config for '$PROJECT_NAME' ..."

sudo tee "$NGINX_AVAILABLE" > /dev/null <<EOF
server {
    listen 80;
    server_name $SERVER_IP;

    location /$PROJECT_NAME/ {
        proxy_pass http://127.0.0.1:$PHP_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

echo "🔗 Enabling site..."
sudo ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"

echo "🔄 Testing Nginx configuration..."
sudo nginx -t

echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

echo "✅ Project '$PROJECT_NAME' deployed!"
echo "🌐 Access it at: http://$SERVER_IP/$PROJECT_NAME"
echo "📝 Logs at: $LOG_FILE"

