# Utiliser une image de base Ubuntu
FROM ubuntu:20.04

# Définir des variables d'environnement pour éviter les interactions pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Mettre à jour le système et installer les dépendances nécessaires
RUN apt-get update && \
    apt-get install -y \
    curl \
    unzip \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    gettext \
    && rm -rf /var/lib/apt/lists/*

# Installer kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Installer AWS CLI via le script d'installation
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && \
    rm -rf ./aws

# Installer Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Vérifier les installations
RUN kubectl version --client && \
    aws --version && \
    helm version

# Définir le point d'entrée par défaut.
# ENTRYPOINT ["bash"]
