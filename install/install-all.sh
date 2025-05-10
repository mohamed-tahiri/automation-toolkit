#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_IF_INSTALLED=false

# Traitement des arguments
for arg in "$@"; do
  if [[ "$arg" == "--skip-if-installed" ]]; then
    SKIP_IF_INSTALLED=true
  fi
done

TOOLS=("php" "java" "python" "node" "aws" "git" "docker" "kubernetes")
TOTAL=${#TOOLS[@]}
CURRENT=1

# Timer début
start_time=$(date +%s)

echo "🚀 Début de l'installation de tous les outils..."
for tool in "${TOOLS[@]}"; do
  echo ""
  echo "📦 [$CURRENT/$TOTAL] Installation de $tool..."

  if [[ "$SKIP_IF_INSTALLED" == true ]]; then
    if command -v "$tool" &>/dev/null; then
      echo "✅ $tool est déjà installé, on ignore."
      ((CURRENT++))
      continue
    fi
  fi

  bash "$SCRIPT_DIR/install-$tool.sh" || {
    echo "❌ Échec de l'installation de $tool"
  }

  ((CURRENT++))
done

# Timer fin
end_time=$(date +%s)
elapsed=$((end_time - start_time))
minutes=$((elapsed / 60))
seconds=$((elapsed % 60))

echo ""
echo "✅ Tous les outils ont été installés."
echo "⏱️ Temps total : ${minutes}m ${seconds}s"

