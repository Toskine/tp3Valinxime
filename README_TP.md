# MemeForge - Meme Generator Application

Une application web simple pour générer des memes avec du texte personnalisé. Tout le traitement se fait côté client avec HTML5 Canvas.

## 📋 Table des matières

- [Architecture](#-architecture)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Docker](#-docker)
- [CI/CD](#-cicd)
- [Déploiement](#-déploiement)

---

## 🏗️ Architecture

```
MemeForge/
├── app.py                 # Application Flask
├── requirements.txt       # Dépendances Python
├── Dockerfile             # Configuration Docker multi-stage
├── docker-compose.yml     # Orchestration locale
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # Pipeline GitHub Actions
├── templates/
│   └── index.html         # Page principale
├── static/
│   └── js/
│       └── meme.js        # Logique client-side
└── COOLIFY_SETUP.md       # Guide de configuration Coolify
```

### Stack technique

- **Backend** : Flask 3.0+
- **Frontend** : HTML5, CSS3, JavaScript (Canvas API)
- **Runtime** : Python 3.11
- **Conteneurisation** : Docker + Docker Compose
- **CI/CD** : GitHub Actions
- **Déploiement** : Coolify
- **Sécurité** : Bandit (SAST), Safety (dependency scanning)

---

## 🚀 Installation

### Prérequis locaux

- Python 3.11+
- Docker et Docker Compose (optionnel)
- Git

### Setup local

1. **Cloner le repository**
```bash
git clone https://github.com/Toskine/tp3Valinxime.git
cd tp3Valinxime
```

2. **Créer un environnement virtuel**
```bash
python -m venv venv

# Sur Windows
venv\Scripts\activate

# Sur Linux/Mac
source venv/bin/activate
```

3. **Installer les dépendances**
```bash
pip install -r requirements.txt
```

4. **Configurer les variables d'environnement**
```bash
# Copier et éditer le fichier exemple
cp .env.example .env
# Éditer .env avec vos paramètres
```

5. **Lancer l'application**
```bash
python app.py
```

L'application sera disponible sur `http://localhost:5000`

---

## 💻 Utilisation

### Interface Web

1. **Charger une image** : Cliquez sur "Select Image" et choisissez une image
2. **Ajouter du texte** : Entrez le texte pour le haut et le bas
3. **Générer le meme** : Cliquez sur "Generate Meme"
4. **Télécharger** : Cliquez sur "Download Meme" pour obtenir le PNG

### API Endpoints

#### GET `/`
Retourne la page HTML principale.

#### GET `/health`
Health check pour monitoring/Kubernetes.

**Response:**
```json
{
  "status": "healthy",
  "service": "memeforge"
}
```

#### POST `/upload` (en développement)
Endpoint pour upload de fichiers (sans validation - vulnérabilité intentionnelle à fins pédagogiques).

---

## 🐳 Docker

### Build local

```bash
# Construire l'image
docker build -t memeforge:latest .

# Lancer le conteneur
docker run -p 5000:5000 \
  -e SECRET_KEY="your-secret-key" \
  memeforge:latest

# Accéder à http://localhost:5000
```

### Avec Docker Compose

```bash
# Lancer l'application
docker-compose up

# Lancer en background
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down
```

### Variables d'environnement

```env
SECRET_KEY=your-secret-key-here
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=5000
```

---

## 🔄 CI/CD

### Pipeline GitHub Actions

Le pipeline se déclenche sur :
- **Tous les branches** : Bandit security scan
- **Branch `main`** : Bandit + Docker build + Push to ghcr.io + Coolify deploy

### Jobs

#### 1️⃣ Bandit (SAST Analysis)
- Exécute un scan de sécurité statique
- Produit un rapport JSON
- Commente les PRs avec les résultats
- **Branches** : Toutes

#### 2️⃣ Docker Build & Push
- Construit l'image Docker multi-stage
- Push vers GitHub Container Registry (ghcr.io)
- Tags : `branch-name`, `latest` (pour main), `sha`
- **Branches** : main, develop

#### 3️⃣ Deploy to Coolify
- Déclenche un webhook Coolify
- Coolify re-pull l'image et redéploie
- **Branch** : main seulement

#### 4️⃣ Test Image
- Construit et teste l'image localement
- Vérifie le health check
- **Branches** : Toutes (après docker-build)

### Secrets requis

Ajouter dans **Repository Settings** → **Secrets and variables** → **Actions** :

```
COOLIFY_WEBHOOK_URL = https://your-coolify-instance/api/webhooks/deploy
COOLIFY_APP_URL = https://site.tpdevopslab01.store
SECRET_KEY = your-secret-key-change-this
```

---

## 🌐 Déploiement

### Sur Coolify

Voir le fichier [COOLIFY_SETUP.md](./COOLIFY_SETUP.md) pour les instructions détaillées.

**Résumé rapide** :

1. Configurer l'application dans Coolify
2. Ajouter le domaine `site.tpdevopslabXX.store`
3. Configurer le webhook GitHub
4. Pusher sur `main` → pipeline s'exécute → déploiement automatique

### URL de production

```
https://site.tpdevopslab01.store  (remplacer 01 par votre numéro)
```

---

## 🔒 Sécurité

### Vulnérabilités intentionnelles (à titre pédagogique)

1. **SECRET_KEY hardcodée** : À remplacer par une variable d'environnement
2. **File upload sans validation** : Ajouter la validation MIME/extension
3. **Debug mode** : Désactiver en production
4. **Pas de rate limiting** : À implémenter

### Bonnes pratiques mises en place

✅ Utilisateur non-root dans le conteneur  
✅ Image de base slim  
✅ Multi-stage Docker build  
✅ HEALTHCHECK intégré  
✅ SAST scanning avec Bandit  
✅ Dépendances à jour avec plages de versions  
✅ Variables d'environnement pour la configuration  

---

## 🛠️ Dépannage

### L'application ne démarre pas localement
```bash
# Vérifier les dépendances
pip list | grep -i flask

# Réinstaller
pip install --upgrade -r requirements.txt

# Vérifier les erreurs
python app.py --verbose
```

### Le Dockerfile ne se construit pas
```bash
# Voir les erreurs
docker build --no-cache -t memeforge:latest .

# Vérifier l'image de base
docker pull python:3.11-slim
```

### Le workflow GitHub Actions échoue
- Vérifier les logs dans **Actions** → Sélectionner le workflow
- Vérifier que les secrets sont configurés
- Vérifier les permissions du token GITHUB_TOKEN

---

## 📚 Références

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Bandit](https://bandit.readthedocs.io/)
- [Coolify Documentation](https://coolify.io/docs/)

---

## 📝 Licence

MIT

## 👥 Auteurs

Toskine - TP03 DevOps Lab

---

**Dernière mise à jour** : 12 novembre 2025
