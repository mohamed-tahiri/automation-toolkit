#!/bin/bash
# Usage: ./cleanup.sh /chemin/du/dossier [jours]

TARGET_DIR=$1
DAYS=${2:-7}

if [ -z "$TARGET_DIR" ]; then
  echo "❌ Chemin cible manquant. Utilisation : $0 /chemin/cible [jours]"
  exit 1
fi

echo "🧹 Suppression des fichiers de plus de $DAYS jours dans $TARGET_DIR..."
find "$TARGET_DIR" -type f -mtime +$DAYS -exec rm -v {} \;

echo "✅ Nettoyage terminé."

