#!/bin/bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Importation du logger
source "$SCRIPT_DIR/scripts/lib/log.sh"

print_usage() {
  cat <<EOF

╭──────────────────────────────────────────────────────╮
│            🛠  AUTOMATION TOOLKIT THR. CLI            │
╰──────────────────────────────────────────────────────╯
Usage:
  ./toolkit.sh <section> <action> [options]

Sections & Actions disponibles :

  install     php <version>         	      		      → Installe PHP
      	      java <version>        	      		      → Installe Java
              python <verion>       	      		      → Installe Python
	      node <version>	    	      		      → Installe node
	      aws		              		      → Installe AWS 
              git                   	      		      → Installe Git
	      docker		    	      		      → Installe Docker
	      kubernetes	    	      		      → Installe kubernetes
	      all [options] 		      		      → Installe tous les outils
					       			 Options :
						 		   --skip-if-installed  : ignorer si déjà installé

    start      node <framework>  <project-name> [options]     → Initialise un projet Node.js
                                               			 Frameworks disponibles :
                                                 		   - mern
                                                 		   - mean
                                                 		   - nestjs
                                                 		   - reactjs
                                                 		   - angular
                                                 		   - expressjs
                                               			 Options :
                                                 		   --version <x.x.x>        : Spécifie la version Node.js
                                                 		   --with-docker            : Ajoute une configuration Docker
                                                 		   --with-db <mongo|mysql>  : Ajoute la config base de données

             php <framework> <project-name> [options]         → Initialise un projet PHP
                                                 		 Frameworks disponibles :
                                                 		   - prestashop
                                                 		   - drupal
                                                 		   - sylius
                                                 		   - symfony
                                                 		   - laravel
                                               			 Options :
                                                 		   --version <x.x>          : Spécifie la version PHP
                                                 		   --with-docker            : Ajoute une configuration Docker
                                                 		   --with-db <mysql|pgsql>  : Ajoute la config base de données

             java <framework> <project-name> [options]        → Initialise un projet Java
                                               			 Frameworks disponibles :
                                                 		   - spring
                                                 		   - spring-angular
                                               			 Options :
                                                 		   --jdk <version>          : Spécifie la version du JDK
                                                 		   --with-docker            : Ajoute une configuration Docker
                                                 		   --with-db <mysql|pgsql>  : Ajoute la config base de données
  
  configure   nginx-php             	    		      → Configure Nginx + PHP

  scripts     backup <src> [dest]   	    		      → Sauvegarde un dossier
              cleanup               	    		      → Nettoyage système
              deploy                	    		      → Déploie une app

  utils       version-check         → Vérifie les versions des outils

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
      php)     	 	bash "$SCRIPT_DIR/install/install-php.sh" "$@" ;;
      java)    	 	bash "$SCRIPT_DIR/install/install-java.sh" "$@" ;;
      python)  	 	bash "$SCRIPT_DIR/install/install-python.sh" "$@" ;;
      git)    	 	bash "$SCRIPT_DIR/install/install-git.sh" ;;
      aws)       	bash "$SCRIPT_DIR/install/install-aws.sh" ;;
      kubernetes)	bash "$SCRIPT_DIR/install/install-kubernetes.sh" ;;
      node)		bash "$SCRIPT_DIR/install/install-node.sh" "$@" ;;
      docker)		bash "$SCRIPT_DIR/install/install-docker.sh" ;; 
      all) 		bash "$SCRIPT_DIR/install/install-all.sh" "$@" ;;
      *)       		ERROR "Action inconnue pour 'install': $ACTION"; exit 1 ;;
    esac
    ;;
    start)
    case $ACTION in
      node)		bash "$SCRIPT_DIR/start/node.sh" "$@" ;;
      php)		bash "$SCRIPT_DIR/start/php.sh" "$@" ;;
      java)		bash "$SCRIPT_DIR/start/java.sh" "$@" ;;
      *)		ERROR "Projet inconnu : $ACTION"; exit 1 ;;
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
      backup)  	bash "$SCRIPT_DIR/scripts/backup.sh" "$@" ;;
      cleanup) 	bash "$SCRIPT_DIR/scripts/cleanup.sh" ;;
      deploy)  	bash "$SCRIPT_DIR/scripts/deploy-app.sh" ;;
      *)       	ERROR "Action inconnue pour 'scripts': $ACTION"; exit 1 ;;
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

