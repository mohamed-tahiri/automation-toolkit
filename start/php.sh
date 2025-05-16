#!/bin/bash

# ========== HELP ==========
show_help() {
  echo ""
  echo "  php <framework> <project-name> [options]         → Initialise un projet PHP"
  echo "                                                Frameworks disponibles :"
  echo "                                                  - prestashop"
  echo "                                                  - drupal"
  echo "                                                  - sylius"
  echo "                                                  - symfony"
  echo "                                                  - laravel"
  echo "                                                Options :"
  echo "                                                  --version <x.x>          : Spécifie la version PHP"
  echo "                                                  --with-docker            : Ajoute une configuration Docker"
  echo "                                                  --with-db <mongodb|mysql|postgres>  : Ajoute la config base de données"
  echo ""
}

# ========== PARSING ==========
FRAMEWORK=$1
PROJECT_NAME=$2
shift 2

PHP_VERSION="8.1"
WITH_DOCKER=false
DB_TYPE=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --version)
      PHP_VERSION="$2"
      shift
      ;;
    --with-docker)
      WITH_DOCKER=true
      ;;
    --with-db)
      DB_TYPE="$2"
      shift
      ;;
    *)
      echo "❌ Option inconnue : $1"
      show_help
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$FRAMEWORK" || -z "$PROJECT_NAME" ]]; then
  echo "❌ Veuillez spécifier le framework et le nom du projet."
  show_help
  exit 1
fi

# ========== INSTALL PHP + EXTENSIONS ==========
echo "📦 Installation de PHP $PHP_VERSION pour $FRAMEWORK ($PROJECT_NAME)"

sudo apt update
sudo apt install -y php$PHP_VERSION php$PHP_VERSION-cli php$PHP_VERSION-common

EXTENSIONS=(dom gd mbstring pdo curl xml zip)
for ext in "${EXTENSIONS[@]}"; do
  sudo apt install -y php$PHP_VERSION-$ext
done

# ========== CREATE PROJECT DIRECTORY ==========
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# ========== INIT COMPOSER PROJECT ==========
echo "🎯 Initialisation du projet $FRAMEWORK..."

case $FRAMEWORK in
  laravel)
    composer create-project laravel/laravel .
    ;;
  symfony)
    composer create-project symfony/skeleton .
    ;;
  drupal)
    composer create-project drupal/recommended-project .
    ;;
  prestashop)
    git clone https://github.com/PrestaShop/PrestaShop.git .
    composer install
    ;;
  sylius)
    composer create-project sylius/sylius-standard .
    ;;
  *)
    echo "❌ Framework non reconnu : $FRAMEWORK"
    exit 1
    ;;
esac

# ========== .ENV ==========
if [ ! -f .env ]; then
  echo "📝 Création d'un fichier .env"
  echo -e "APP_ENV=dev\nAPP_DEBUG=true" > .env
fi

# ========== DOCKER ==========
if $WITH_DOCKER; then
  echo "🐳 Ajout d’une configuration Docker"

  cat <<EOF > docker-compose.yml
version: '3.8'

services:
  php:
    image: php:$PHP_VERSION-apache
    volumes:
      - .:/var/www/html
    ports:
      - "8080:80"
EOF

  if [[ $DB_TYPE == "mysql" ]]; then
    cat <<EOF >> docker-compose.yml

  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: app
      MYSQL_USER: user
      MYSQL_PASSWORD: pass
    ports:
      - "3306:3306"
EOF
  elif [[ $DB_TYPE == "postgres" ]]; then
    cat <<EOF >> docker-compose.yml

  db:
    image: postgres:14
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: app
    ports:
      - "5432:5432"
EOF
  elif [[ $DB_TYPE == "mongodb" ]]; then
    cat <<EOF >> docker-compose.yml

  db:
    image: mongo:latest
    ports:
      - "27017:27017"
EOF
  fi

  echo "🛠️ Docker prêt. Lance avec : docker compose up -d"
fi

# ========== MAKEFILE ==========
echo "🛠️ Création du Makefile"
cat <<EOF > Makefile
PHP_VERSION=$PHP_VERSION

install:
\tbash ../setup/install.sh

up:
\tdocker compose up -d

down:
\tdocker compose down

composer:
\tdocker compose exec php composer install
EOF

echo "✅ Projet PHP '$PROJECT_NAME' initialisé avec succès."

