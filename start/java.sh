#!/bin/bash

# ========== HELP ==========
show_help() {
  echo ""
  echo "  java <framework> <project-name> [options]         → Initialise un projet Java"
  echo "                                                  Frameworks disponibles :"
  echo "                                                    - spring"
  echo "                                                    - spring-angular"
  echo "                                                  Options :"
  echo "                                                    --jdk <version>          : Spécifie la version du JDK"
  echo "                                                    --with-docker            : Ajoute une configuration Docker"
  echo "                                                    --with-db <mongodb|mysql|postgres>  : Ajoute la config base de données"
  echo ""
}

# ========== PARSING ==========
FRAMEWORK=$1
PROJECT_NAME=$2
shift 2

JDK_VERSION="17"
WITH_DOCKER=false
DB_TYPE=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --jdk)
      JDK_VERSION="$2"
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

# ========== INSTALL JDK ==========
echo "📦 Installation du JDK $JDK_VERSION"

sudo apt update
sudo apt install -y openjdk-$JDK_VERSION-jdk

export JAVA_HOME=/usr/lib/jvm/java-$JDK_VERSION-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "JDK installé :"
java -version

# ========== CREATE PROJECT DIRECTORY ==========
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# ========== INIT MAVEN/GRADLE PROJECT ==========
echo "🎯 Initialisation du projet $FRAMEWORK..."

case $FRAMEWORK in
  spring)
    # Exemple : créer un projet Spring Boot via Spring Initializr CLI (si installé)
    curl https://start.spring.io/starter.tgz -d dependencies=web,data-jpa -d javaVersion=$JDK_VERSION | tar -xzvf -
    ;;
  spring-angular)
    # Crée le backend Spring Boot
    mkdir backend
    cd backend || exit
    curl https://start.spring.io/starter.tgz -d dependencies=web,data-jpa -d javaVersion=$JDK_VERSION | tar -xzvf -
    cd ..
    # Crée le frontend Angular (si Angular CLI installé)
    echo "Création du frontend Angular..."
    if command -v ng &> /dev/null; then
      ng new frontend --routing --style=scss --skip-install
    else
      echo "⚠️ Angular CLI non trouvé, pensez à l'installer pour générer le frontend."
    fi
    ;;
  *)
    echo "❌ Framework non reconnu : $FRAMEWORK"
    exit 1
    ;;
esac

# ========== DOCKER ==========
if $WITH_DOCKER; then
  echo "🐳 Ajout d’une configuration Docker"

  cat <<EOF > docker-compose.yml
version: '3.8'

services:
  app:
    image: openjdk:$JDK_VERSION-jdk
    volumes:
      - .:/app
    working_dir: /app
    command: ./mvnw spring-boot:run
    ports:
      - "8080:8080"
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
JDK_VERSION=$JDK_VERSION

install:
\tsudo apt update && sudo apt install -y openjdk-\$(JDK_VERSION)-jdk

build:
\t./mvnw clean package

run:
\t./mvnw spring-boot:run

up:
\tdocker compose up -d

down:
\tdocker compose down
EOF

echo "✅ Projet Java '$PROJECT_NAME' initialisé avec succès."

