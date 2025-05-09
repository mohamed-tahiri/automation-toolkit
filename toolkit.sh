#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Importation du logger
source "$SCRIPT_DIR/scripts/lib/log.sh"

print_usage() {
  cat <<EOF

╭──────────────────────────────────────────────────────╮
│              🛠  AUTOMATION TOOLKIT CLI              │
╰──────────────────────────────────────────────────────╯
Usage:
  ./toolkit.sh <section> <action> [options]

Sections & Actions disponibles :

  install     php <version>         → Installe PHP
      	      java <version>        → Installe Java
              python <verion>       → Installe Python
              git                   → Installe Git

  configure   nginx-php             → Configure Nginx + PHP

  scripts     backup <src> [dest]   → Sauvegarde un dossier
              cleanup               → Nettoyage système
              deploy                → Déploie une app

  utils       version-check         → Vérifie les versions des outils

Exemples :
  ./toolkit.sh install php 8.2
  ./toolkit.sh scripts backup /var/www ~/backups
  ./toolkit.sh configure nginx-php

EOF
}

# Vérification des arguments
if [[ $# -lt 2 ]]; then
  print_usage
  exit 1
fi

SECTION="$1"
ACTION="$2"
shift 2

case "$SECTION" in
  install)
    case "$ACTION" in
      php)     bash "$SCRIPT_DIR/install/install-php.sh" "$@" ;;
      java)    bash "$SCRIPT_DIR/install/install-java.sh" "$@" ;;
      python)  bash "$SCRIPT_DIR/install/install-python.sh" "$@" ;;
      git)     bash "$SCRIPT_DIR/install/install-git.sh" ;;
      *)       ERROR "Action inconnue pour 'install': $ACTION"; exit 1 ;;
    esac
    ;;
  configure)
    case "$ACTION" in
      nginx-php) bash "$SCRIPT_DIR/configure/setup-nginx-php.sh" ;;
      *)         ERROR "Action inconnue pour 'configure': $ACTION"; exit 1 ;;
    esac
    ;;
  scripts)
    case "$ACTION" in
      backup)  bash "$SCRIPT_DIR/scripts/backup.sh" "$@" ;;
      cleanup) bash "$SCRIPT_DIR/scripts/cleanup.sh" ;;
      deploy)  bash "$SCRIPT_DIR/scripts/deploy-app.sh" ;;
      *)       ERROR "Action inconnue pour 'scripts': $ACTION"; exit 1 ;;
    esac
    ;;
  utils)
    case "$ACTION" in
      version-check) bash "$SCRIPT_DIR/utils/version-check.sh" ;;
      *)             ERROR "Action inconnue pour 'utils': $ACTION"; exit 1 ;;
    esac
    ;;
  *)
    ERROR "Section inconnue: $SECTION"
    print_usage
    exit 1
    ;;
esac

