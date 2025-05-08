#!/bin/bash
# Usage: ./deploy-app.sh /chemin/source /chemin/destination

SRC_DIR=$1
DEST_DIR=$2

if [ -z "$SRC_DIR" ] || [ -z "$DEST_DIR" ]; then
  echo "❌ Usage : $0 /chemin/source /chemin/destination"
  exit 1
fi

echo "🚚 Déploiement de l'application..."

# Crée une sauvegarde rapide
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP="$DEST_DIR-backup-$TIMESTAMP"
cp -r "$DEST_DIR" "$BACKUP"
echo "🗄️ Sauvegarde existante à : $BACKUP"

# Copie les fichiers
rsync -av --delete "$SRC_DIR/" "$DEST_DIR/"

echo "✅ Déploiement terminé à $DEST_DIR"

