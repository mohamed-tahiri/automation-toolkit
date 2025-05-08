#!/bin/bash
# Usage: ./install-git.sh [version]

VERSION=$1

echo "🔧 Installation de Git..."

# Détection du système
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  echo "✅ macOS détecté"
  
  if [ -z "$VERSION" ]; then
    echo "📦 Installation de la dernière version de Git via Homebrew..."
    brew update
    brew install git
  else
    echo "⚠️ Brew ne prend pas en charge les versions spécifiques de Git directement."
    echo "👉 La version $VERSION ne peut être installée que manuellement sur macOS."
    exit 1
  fi

elif [ -f /etc/debian_version ]; then
  echo "✅ Debian/Ubuntu détecté"

  sudo apt update

  if [ -z "$VERSION" ]; then
    echo "📦 Installation de la version disponible dans les dépôts..."
    sudo apt install -y git
  else
    echo "📦 Installation de Git version $VERSION à partir des sources..."

    sudo apt install -y build-essential libssl-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip

    cd /tmp
    curl -LO https://github.com/git/git/archive/refs/tags/v${VERSION}.zip
    unzip v${VERSION}.zip
    cd git-${VERSION}
    make prefix=/usr/local all
    sudo make prefix=/usr/local install
  fi

else
  echo "❌ Système non supporté automatiquement. Installation manuelle recommandée."
  exit 1
fi

echo "✅ Git installé :"
git --version

