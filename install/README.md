
# 📦 Scripts d'installation

Ce dossier contient des scripts d'automatisation pour installer différents langages de programmation avec une version spécifique, principalement sur des systèmes basés sur **Debian/Ubuntu**.

---

## ✅ Langages supportés

- [x] PHP
- [x] Java (OpenJDK)
- [x] Python

---

## 📘 Utilisation

### 🔹 Installer PHP

```bash
./install-php.sh 8.2
````
> Installe PHP 8.2 à l'aide du dépôt `ppa:ondrej/php`.

### 🔹 Installer Java

```bash
./install-java.sh 17
````
> Installe OpenJDK 17 (par exemple : 8, 11, 17, 21...).
 
### 🔹 Installer Python

```bash
./install-python.sh 3.10
````
> Installe Python 3.10 avec les paquets `venv` et `dev`.

## ⚙️ Prérequis
-   Système **Debian/Ubuntu**
    
-   Accès `sudo`
    
-   Paquet `software-properties-common` installé
    
-   Accès à internet

----------

## 🔐 Droits d'exécution

Si vous obtenez une erreur `Permission denied`, donnez les droits d'exécution aux scripts :

bash

CopyEdit

`chmod +x *.sh` 

----------

## 🧪 Support futur

-   Support MacOS (via Homebrew)
    
-   Support Red Hat/CentOS
    
-   Détection automatique des versions installées
    
-   Mode interactif CLI (via `dialog` ou `whiptail`)
   
