#!/bin/bash

# Vérification des privilèges root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script nécessite des privilèges root. Exécutez-le avec sudo." >&2
  exit 1
fi

echo "Début de l'installation de kubectl..."

# Option 1: Installation avec curl pour récupérer le binaire
echo "Téléchargement du binaire kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Vérification du téléchargement
if [ ! -f "kubectl" ]; then
  echo "Échec du téléchargement du binaire kubectl." >&2
  exit 1
fi

echo "Téléchargement terminé."

# Validation du binaire (optionnel)
echo "Téléchargement de la somme de contrôle pour valider le binaire..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "Vérification du binaire kubectl avec la somme de contrôle..."
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

if [ $? -ne 0 ]; then
  echo "La validation du binaire kubectl a échoué." >&2
  exit 1
fi

echo "Validation réussie."

# Installation du binaire
echo "Installation de kubectl dans /usr/local/bin..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Vérification de l'installation
echo "Vérification de la version de kubectl..."
kubectl version --client

if [ $? -ne 0 ]; then
  echo "L'installation de kubectl a échoué." >&2
  exit 1
fi

echo "kubectl installé avec succès."

# Option 2: Installation via gestionnaire de paquets APT (Debian/Ubuntu)
echo "Ajout du dépôt Kubernetes pour APT..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

echo "Installation de kubectl via APT..."
sudo apt-get install -y kubectl

# Vérification de l'installation APT
echo "Vérification de la version de kubectl installé via APT..."
kubectl version --client

# Option 3: Installation via Snap
echo "Installation de kubectl via Snap..."
sudo snap install kubectl --classic

# Vérification de la version Snap
echo "Vérification de la version de kubectl installé via Snap..."
kubectl version --client

echo "Installation de kubectl terminée avec succès."

