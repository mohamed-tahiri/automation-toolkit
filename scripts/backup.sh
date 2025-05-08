#!/bin/bash
# Usage: ./backup.sh /chemin/du/dossier

SOURCE_DIR=$1
BACKUP_DIR=~/backups
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

if [ -z "$SOURCE_DIR" ]; then
  echo "❌ Chemin source manquant. Utilisation : $0 /chemin/source"
  exit 1
fi

mkdir -p "$BACKUP_DIR"
ARCHIVE_NAME=$(basename "$SOURCE_DIR")-$TIMESTAMP.tar.gz

echo "🔄 Sauvegarde de $SOURCE_DIR vers $BACKUP_DIR/$ARCHIVE_NAME..."
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" "$SOURCE_DIR"

echo "✅ Sauvegarde terminée : $BACKUP_DIR/$ARCHIVE_NAME"

