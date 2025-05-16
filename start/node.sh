#!/bin/bash

echo "Test $1"
echo "Tes $2"

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
    	cd .. && mkdir server && cd server || exit

