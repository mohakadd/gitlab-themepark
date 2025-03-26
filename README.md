# Theme Park sur EKS

Ce projet a pour objectif de déployer l'application Theme Park sur un cluster EKS (Amazon Elastic Kubernetes Service) à l'aide d'un pipeline GitLab CI/CD. Le pipeline inclut désormais une partie dédiée au monitoring avec Prometheus et Grafana. Il intègre également la construction d'une image Docker, des tests automatisés, la gestion de l'infrastructure via Terraform, et le déploiement sur plusieurs environnements (développement, QA, production).

## Table des matières

- [Prérequis](#prérequis)
- [Structure du projet](#structure-du-projet)
- [Configuration du Pipeline GitLab CI/CD](#configuration-du-pipeline-gitlab-cicd)
  - [Workflow et Variables d'Environnement](#workflow-et-variables-denvironnement)
  - [Étapes du Pipeline](#étapes-du-pipeline)
- [Déploiement sur EKS](#déploiement-sur-eks)
  - [Déploiement du Monitoring](#déploiement-du-monitoring)
  - [Déploiement en environnement de développement](#déploiement-en-environnement-de-développement)
  - [Déploiement en environnement QA](#déploiement-en-environnement-de-qa)
  - [Déploiement en environnement de production](#déploiement-en-environnement-de-production)
- [Utilisation et commandes](#utilisation-et-commandes)
- [Contribution](#contribution)

## Prérequis

- **GitLab** pour l'intégration continue.
- **Terraform** pour la gestion de l'infrastructure.
- **AWS CLI** pour interagir avec votre compte AWS et configurer le cluster EKS.
- **kubectl** pour gérer les ressources Kubernetes sur le cluster EKS.
- Accès à un cluster EKS (le nom du cluster utilisé ici est `ThemeEKS`).

**Variables d'environnement requises :**

- **AWS_ACCESS_KEY_ID** et **AWS_SECRET_ACCESS_KEY** : Clés d'accès permettant d'interagir de manière sécurisée avec les ressources AWS.
- **USERNAME** et **TOKEN** : Identifiants GitLab, où USERNAME correspond au nom d'utilisateur et TOKEN sert de clé d'accès pour le repository GitLab.
- **GITLAB_API_TOKEN** : Token utilisé pour exécuter des opérations via l'API GitLab, facilitant l'automatisation et l'intégration continue.

## Structure du projet

La structure du dépôt se présente comme suit :

```
├── app
│   ├── src
│   │   ├── main
│   │   │   ├── java/com/exemple
│   │   │   │   ├── controller
│   │   │   │   ├── model
│   │   │   │   └── repository
│   │   │   └── resources
│   │   └── test
│   │       └── java/com/exemple
│   ├── build
│   └── ... (autres dossiers et fichiers relatifs à l'application)
├── image_cicd
├── terraform
│   ├── modules
│   │   ├── eks
│   │   └── network
│   └── .terraform
└── gitlab-ci.yml
```

## Configuration du Pipeline GitLab CI/CD

Le fichier **gitlab-ci.yml** est organisé en plusieurs étapes permettant d'automatiser :

- La construction, le test et la publication de l'image Docker.
- La gestion de l'infrastructure via Terraform (validation, planification, application et destruction).
- Le déploiement du monitoring (Prometheus et Grafana) sur le cluster EKS.
- Le déploiement de l'application sur le cluster EKS dans différents environnements (dev, QA, prod).

### Workflow et Variables d'Environnement

- **Workflow** : Le pipeline s'exécute automatiquement pour les commits sur la branche `main` ou lors d'une demande de fusion.  
- **Variables d'environnement** :  
  - `CLUSTER_NAME` : Nom du cluster EKS (ici `ThemeEKS`).
  - `AWS_DEFAULT_REGION` : Région AWS utilisée (ici `eu-west-3`).
  - `TF_DIR` : Chemin vers le répertoire contenant les fichiers Terraform.
  - `STATE_NAME` et `ADDRESS` : Pour la gestion de l'état Terraform via l'API GitLab.
  - `DOCKER_IMAGE` : Nom de l'image Docker (ici `themetmp1`).
  - **Variables pour l'accès à AWS et GitLab** :  
    - `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` pour AWS.  
    - `USERNAME` et `TOKEN` pour l'accès au repository GitLab.  
    - `GITLAB_API_TOKEN` pour les opérations via l'API GitLab.

### Étapes du Pipeline

1. **build_image**  
   - Construction de l'image Docker de l'application.
   - Sauvegarde de l'image dans un artefact compressé (`.tar.gz`).
   - Suppression de l'image créer

2. **test_image**  
   - Chargement de l'image Docker sauvegardée.
   - Exécution d'un conteneur pour effectuer un test via une requête HTTP sur le point d'entrée `/ride`.
   - Arrêter le container et suppression de l'image même en cas d'échec

3. **release_image**  
   - Chargement de l'image Docker sauvegardée.
   - Taggage et push de l'image Docker vers le registre GitLab.
   - Mise à jour du tag `latest` en cas de commit tagué.
   - Faire le ménage des images dockers

4. **build_eks**  
   - **1_validate** : Validation de la configuration Terraform.
   - **2_plan** : Génération d'un plan d'exécution Terraform (plan sauvegardé en artefact).

5. **deploy_eks**  
   - **apply** : Application des changements Terraform pour provisionner l'infrastructure EKS.

6. **deploy_monitoring**  
   - **1_Prometheus** : Installation de Prometheus et du metrics server, configuration via Helm et mise à jour de l'environnement GitLab avec l'URL d'accès.
   - **2_Graphana** : Installation de Grafana (issu du package kube-prometheus-stack) et récupération de l'URL d'accès.
   - **stop-monitor** : Arrêt et nettoyage du monitoring sur EKS.

7. **deploy_dev**, **deploy_qa** et **deploy_prod**  
   - Déploiement de l'application dans les environnements respectifs via `kubectl`, avec mise à jour de l'URL d'accès via l'API GitLab.
   - Chaque déploiement dispose d'un job associé pour arrêter l'application (stop-dev, stop-qa, stop-prod).

8. **destroy_eks**  
   - Destruction manuelle de l'infrastructure EKS avec Terraform.

## Déploiement sur EKS

### Déploiement du Monitoring

Le pipeline intègre une phase de déploiement du monitoring, qui se décompose en trois jobs :

- **1_Prometheus**  
  Ce job configure `kubectl` pour se connecter au cluster, installe le metrics server ainsi que Prometheus et Grafana via Helm (avec la création du namespace `monitoring`), et transforme certains services en LoadBalancer pour permettre l'accès depuis Internet. L'URL obtenue pour Prometheus est ensuite envoyée à l'API GitLab pour mettre à jour l'environnement `premetheus_env`.

- **2_Graphana**  
  Ce job récupère et affiche le mot de passe administrateur de Grafana, extrait l'URL du service associé et met à jour l'environnement GitLab `graphana_env` avec l'URL de Grafana.

- **stop-monitor**  
  Ce job permet d'arrêter et de nettoyer le déploiement du monitoring en désinstallant Prometheus via Helm, supprimant le metrics server, et supprimant le namespace `monitoring

### Déploiement en environnement de développement

- **deploy-dev**  
  Configure `kubectl` pour se connecter au cluster EKS, déploie l'application en substituant les variables dans le fichier `deployment.yaml`, et met à jour l'environnement GitLab `dev_env` avec l'URL d'accès à l'application.

- **stop-dev**  
  Permet d'arrêter manuellement l'application dans l'environnement de développement.

### Déploiement en environnement QA

- **deploy-qa**  
  Suivant un processus similaire à `deploy-dev`, ce job déploie l'application dans l'environnement QA, avec mise à jour de l'URL d'accès via l'API GitLab.

- **stop-qa**  
  Arrête l'application dans l'environnement QA de manière manuelle.

### Déploiement en environnement de production

- **deploy-prod**  
  Configure `kubectl` et déploie l'application dans l'environnement de production, puis met à jour l'environnement GitLab `prod_env` avec l'URL d'accès.

- **stop-prod**  
  Permet d'arrêter l'application dans l'environnement de production.

## Utilisation et commandes

- **Exécution du Pipeline** :  
  Le pipeline est déclenché automatiquement selon les règles définies dans le fichier `gitlab-ci.yml`.  
  Pour déclencher manuellement certaines étapes (comme le déploiement ou la destruction de l'infrastructure), utilisez l'interface GitLab.

- **Gestion de l'infrastructure** :  
  Les commandes Terraform sont exécutées dans le dossier `terraform` afin de :
  - Valider la configuration (`terraform validate`).
  - Générer un plan d'exécution (`terraform plan`).
  - Appliquer les modifications (`terraform apply`).
  - Détruire l'infrastructure (`terraform destroy`).

- **Déploiement de l'application** :  
  Les jobs `deploy-dev` et `deploy-prod` utilisent `kubectl` pour appliquer le fichier `deployment.yaml` après substitution des variables d'environnement.

## Contribution

- Alpha LY
- Badri Choulak
- Mohammed Kaddouri
- Raymond Nguyen