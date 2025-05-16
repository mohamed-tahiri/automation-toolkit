#!/bin/bash

FRAMEWORK=$1
PROJECT_NAME=$2
shift 2

VERSION="latest"
DOCKER=false
DB=""

# ✅ Check required project name
if [[ -z "$PROJECT_NAME" ]]; then
  echo "❌ Nom du projet requis après le framework."
  echo "👉 Exemple : ./toolkit.sh start node reactjs my-app"
  exit 1
fi

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --with-docker)
      DOCKER=true
      shift
      ;;
    --with-db)
      DB="$2"
      shift 2
      ;;
    *)
      echo "❌ Option inconnue : $1"
      exit 1
      ;;
  esac
done

# ✅ Check supported frameworks
VALID_FRAMEWORKS=("mern" "mean" "nestjs" "reactjs" "angular" "expressjs")
if [[ ! " ${VALID_FRAMEWORKS[@]} " =~ " ${FRAMEWORK} " ]]; then
  echo "❌ Framework Node.js non supporté : $FRAMEWORK"
  echo "Frameworks disponibles :"
  for fw in "${VALID_FRAMEWORKS[@]}"; do
    echo "  - $fw"
  done
  exit 1
fi

# Show the data
echo "Framework     : $FRAMEWORK"
echo "Project Name  : $PROJECT_NAME"
echo "Node Version  : $VERSION"
echo "Docker        : $([[ $DOCKER == true ]] && echo 'true' || echo 'false')"
echo "Database      : ${DB:-Aucune}"

# ✅ Framework-specific setup
case "$FRAMEWORK" in
  reactjs)
    echo "➡️ Création d'un projet ReactJS..."
    npx create-react-app "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit
    ;;
    
  expressjs)
    echo "➡️ Création d'un projet ExpressJS..."
    mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit
    npm init -y
    npm install express
    ;;
    
  nestjs)
    echo "➡️ Création d'un projet NestJS..."
    npm install -g @nestjs/cli
    nest new "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit
    ;;
    
  angular)
    echo "➡️ Création d'un projet Angular..."
    npm install -g @angular/cli
    ng new "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit
    ;;
    
  mern)
    echo "➡️ Création d'un projet MERN (Mongo, Express, React, Node)..."
    mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit
    npx create-react-app client
    mkdir server
    cd server || exit
    npm init -y
    npm install express mongoose
    ;;
    
  mean)
    echo "➡️ Création d'un projet MEAN (Mongo, Express, Angular, Node)..."
    mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME" || exit
    mkdir server client
    # Setup Angular client
    cd client || exit
    npm install -g @angular/cli
    ng new frontend
    cd ..
    # Setup Express server
    cd server || exit
    npm init -y
    npm install express mongoose
    ;;
    
  *)
    echo "❌ Framework inconnu : '$FRAMEWORK'"
    echo "✅ Frameworks valides : mern, mean, nestjs, reactjs, angular, expressjs"
    exit 1
    ;;
esac

# ✅ Génération Docker (si demandé)
if [[ $DOCKER == true ]]; then
  echo "🛠️ Génération des fichiers Docker..."
  cat > Dockerfile <<EOF
FROM node:$VERSION

WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
EOF
fi

# ✅ Génération docker-compose.yml (si Docker et base de données)
if [[ $DOCKER == true ]]; then
  echo "🛠️ Génération de docker-compose.yml..."
  DB_SERVICE=""

  case "$DB" in
    mongodb)
      DB_SERVICE="
  mongodb:
    image: mongo
    container_name: mongodb
    ports:
      - '27017:27017'
    volumes:
      - mongo-data:/data/db"
      ;;
    mysql)
      DB_SERVICE="
  mysql:
    image: mysql:8
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: appdb
    ports:
      - '3306:3306'
    volumes:
      - mysql-data:/var/lib/mysql"
      ;;
    postgres)
      DB_SERVICE="
  postgres:
    image: postgres
    container_name: postgres
    environment:
      POSTGRES_PASSWORD: root
      POSTGRES_DB: appdb
    ports:
      - '5432:5432'
    volumes:
      - pg-data:/var/lib/postgresql/data"
      ;;
    "")
      ;;
    *)
      echo "⚠️ Base de données non supportée : $DB"
      echo "👉 Bases supportées : mongodb, mysql, postgres"
      exit 1
      ;;
  esac

  cat > docker-compose.yml <<EOF
version: '3.8'

services:
  app:
    build: .
    container_name: ${PROJECT_NAME}_app
    ports:
      - "3000:3000"
    volumes:
      - .:/app
    depends_on:
      - ${DB:-mongodb}
$DB_SERVICE

volumes:
  mongo-data:
  mysql-data:
  pg-data:
EOF
fi

echo "✅ Projet '$PROJECT_NAME' généré avec succès."
