# Configuration DNS et Coolify pour le TP03

## �️ Installation de Coolify

### Prérequis serveur

- **OS** : Linux (Ubuntu 20.04+, Debian 10+, etc.) ou Docker Desktop
- **CPU** : Au moins 1 core (2+ recommandé)
- **RAM** : Au moins 1GB (2GB+ recommandé)
- **Disque** : 10GB minimum
- **Ports** : 80, 443 ouverts (pour HTTP/HTTPS)
- **Docker** : Installé et en cours d'exécution

### Option 1 : Installation sur un serveur Linux (recommandé pour production)

#### Étape 1 : Installer Docker

```bash
# Sur Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Ajouter l'utilisateur actuel au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

#### Étape 2 : Installer Coolify

```bash
# Télécharger et exécuter le script d'installation
curl -fsSL https://get.cooli.dev | bash

# Ou en une seule commande
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /root:/root \
  -v /opt/coolify:/opt/coolify \
  ghcr.io/coollabsio/coolify:latest \
  /bin/sh -c "curl -fsSL https://get.cooli.dev | bash"
```

**Le script va** :
- Créer les volumes Docker
- Configurer Coolify
- Démarrer les services

#### Étape 3 : Accéder à Coolify

Après l'installation (2-3 minutes) :

```
https://your-server-ip:3000
```

**Identifiants par défaut** :
- Email : `admin@coolify.io`
- Password : `password` (à changer immédiatement !)

### Option 2 : Installation Docker Desktop (pour développement local)

Si vous avez Docker Desktop sur votre machine :

```bash
# Créer les répertoires
mkdir -p $HOME/coolify/data
mkdir -p $HOME/coolify/logs

# Lancer Coolify avec docker run
docker run -d \
  --name coolify \
  -p 3000:3000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/coolify/data:/data \
  -v $HOME/coolify/logs:/logs \
  -e COOLIFY_DATABASE_URL="postgresql://coolify:coolify@postgres:5432/coolify" \
  ghcr.io/coollabsio/coolify:latest
```

Ou avec Docker Compose :

```bash
# Créer docker-compose.yml pour Coolify
cat > docker-compose-coolify.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: coolify
      POSTGRES_USER: coolify
      POSTGRES_PASSWORD: coolify
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  coolify:
    image: ghcr.io/coollabsio/coolify:latest
    ports:
      - "3000:3000"
    environment:
      COOLIFY_DATABASE_URL: postgresql://coolify:coolify@postgres:5432/coolify
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - coolify_data:/data
      - coolify_logs:/logs
    depends_on:
      - postgres
    restart: unless-stopped

volumes:
  postgres_data:
  coolify_data:
  coolify_logs:
EOF

docker-compose -f docker-compose-coolify.yml up -d
```

Accès : `http://localhost:3000`

---

## ⚙️ Configuration initiale de Coolify

### Étape 1 : Connexion et sécurité

1. Accédez à `https://your-coolify-instance:3000`
2. Connectez-vous avec les identifiants par défaut
3. **Allez à Settings** → **Change Password**
4. Changez le mot de passe immédiatement ⚠️

### Étape 2 : Configurer le serveur Docker

1. **Settings** → **Servers**
2. Vérifier que votre serveur Docker est connecté (devrait être automatique)
3. Si pas de serveur, cliquer **Add Server** et configurer

### Étape 3 : Ajouter le registre Docker (GitHub Container Registry)

1. **Settings** → **Registries**
2. **Add Registry** :
   - **Type** : Docker Registry
   - **Name** : `GitHub Container Registry`
   - **URL** : `ghcr.io`
   - **Username** : Votre username GitHub
   - **Password** : Token GitHub (Classic)
   - **Is Public** : Non

Pour créer un token GitHub :
- GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
- **Generate new token**
- Permissions : `write:packages, read:packages, delete:packages`
- Copier le token et le coller dans Coolify

### Étape 4 : Configurer Let's Encrypt (SSL/TLS)

1. **Settings** → **Let's Encrypt**
2. **Email** : Votre email
3. **Enable** : Cocher "Use Let's Encrypt"
4. Coolify générera automatiquement les certificats SSL

---

## �📋 Configuration DNS

Pour déployer votre application à `site.tpdevopslabXX.store`, vous devez configurer le DNS comme suit :

Pour déployer votre application à `site.tpdevopslabXX.store`, vous devez configurer le DNS comme suit :

### Option 1 : Configuration DNS (recommandée)

1. **Accédez à votre fournisseur DNS** (GoDaddy, OVH, Cloudflare, etc.)
2. **Créez un enregistrement DNS** :
   - **Type** : CNAME ou A
   - **Nom (subdomain)** : `site.tpdevopslabXX` (remplacer XX par votre numéro)
   - **Valeur** : L'adresse IP publique ou CNAME de votre serveur Coolify

**Exemple :**
```
Type    | Nom                  | Valeur
--------|----------------------|------------------------
CNAME   | site.tpdevopslab01   | coolify.example.com
ou
A       | site.tpdevopslab01   | 192.168.1.100
```

### Option 2 : Wildcard DNS

Si vous voulez utiliser plusieurs subdomaines :
```
Type    | Nom              | Valeur
--------|------------------|------------------------
CNAME   | *.tpdevopslab    | coolify.example.com
```

---

## 🚀 Configuration Coolify

### Étape 1 : Créer une application dans Coolify

#### 1.1 Créer un projet

1. Dans Coolify, cliquer sur **Projects**
2. **New Project** → Remplir les informations :
   - **Name** : `TP03-MemeForge`
   - **Description** : `Meme Generator for TP03 DevOps`
3. **Create**

#### 1.2 Ajouter une application

1. Dans le projet, cliquer **New Application**
2. Remplir les informations :

**Basic Settings :**
- **Name** : `memeforge`
- **Repository** : `https://github.com/Toskine/tp3Valinxime.git`
- **Branch** : `main`
- **Build Method** : `Docker`
- **Dockerfile Path** : `./Dockerfile`

**Port Configuration :**
- **Port mapping** : `5000:5000` (exposer le port 5000)
- **Expose as** : `http` (ou https si certificat SSL)

**Environment Variables** :
- Cliquer sur **Environment Variables**
- Ajouter les variables :

```
SECRET_KEY=your-very-secure-secret-key-here-min-32-chars
FLASK_ENV=production
FLASK_DEBUG=False
HOST=0.0.0.0
PORT=5000
```

**GitHub Configuration** (si disponible) :
- **GitHub App Integration** : Cocher pour connexion automatique
- **Auto Deploy** : Cocher pour déploiement automatique sur push

3. **Create**

### Étape 1b : Configuration manuelle pour les webhooks

Si vous n'avez pas l'intégration GitHub App, configurez manuellement :

1. Dans l'application Coolify, cliquer **Webhooks**
2. **Generate Webhook** :
   - Coolify génère une URL unique
   - Copier cette URL (elle ressemble à : `https://coolify.example.com/api/v1/webhooks/deploy/xxxxx`)

3. Dans GitHub :
   - **Repository** → **Settings** → **Webhooks** → **Add webhook**
   - **Payload URL** : Coller l'URL du webhook Coolify
   - **Content type** : `application/json`
   - **Events** : Cocher `Push events`
   - **Secret** : Si demandé, générer un secret et l'ajouter aussi dans Coolify
   - **Active** : Cocher
   - **Add webhook**

### Étape 2 : Configurer le domaine

1. Dans l'application Coolify, cliquer **Domains**
2. **Add Domain** :
   - **Domain** : `site.tpdevopslab01.store` (remplacer 01 par votre numéro)
   - **Path** : `/` (root)
   - **Port** : `5000`
   - **Auto Generate SSL** : Cocher (pour Let's Encrypt)

3. **Add**

4. **Sauvegarder** et attendre quelques secondes pour que le certificat soit généré

### Étape 3 : Configurer le DNS auprès de votre fournisseur

Voir la section [Configuration DNS](#-configuration-dns) ci-dessous.

### Étape 4 : Tester le déploiement

1. **Dans Coolify** :
   - Cliquer sur l'application
   - Cliquer **Deploy** (ou attendre le webhook)
   - Voir les logs en temps réel

2. **Vérifier le déploiement** :
```bash
# Vérifier que le conteneur est actif
curl https://site.tpdevopslab01.store/health

# Devrait retourner :
# {"status": "healthy", "service": "memeforge"}
```

---

## 📋 Configuration DNS

## 🔑 Variables d'environnement GitHub Secrets

Pour que votre workflow CI/CD fonctionne, configurez ces secrets dans GitHub :

1. **Repository** → **Settings** → **Secrets and variables** → **Actions**
2. **Ajouter les secrets** :

```
COOLIFY_WEBHOOK_URL = https://your-coolify-instance/api/webhooks/deploy
COOLIFY_APP_URL = https://site.tpdevopslab01.store
SECRET_KEY = your-secure-secret-key
```

---

## 📊 Flux de déploiement

```
┌─────────────────────────────────────────────────────────────┐
│                    Push vers GitHub (main)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────────┐
         │    1️⃣ Bandit Analysis        │
         │   (SAST Security Scan)      │
         └──────────┬──────────────────┘
                    │
                    ▼
      ┌──────────────────────────────┐
      │  2️⃣ Docker Build & Push       │
      │  (to ghcr.io)                │
      └──────────┬───────────────────┘
                 │
                 ▼
    ┌────────────────────────────────┐
    │ 3️⃣ Deploy to Coolify Webhook   │
    │    (via webhook trigger)       │
    └────────────┬───────────────────┘
                 │
                 ▼
        ┌──────────────────────┐
        │ Coolify Re-pull      │
        │ Image & Redeploy     │
        └──────────┬───────────┘
                   │
                   ▼
    ✅ App running at site.tpdevopslab01.store
```

---

## 🧪 Tests locaux avant le déploiement

### Tester le Dockerfile localement

```bash
# Construire l'image
docker build -t memeforge:local .

# Lancer le conteneur
docker run -p 5000:5000 \
  -e SECRET_KEY="test-key" \
  memeforge:local

# Tester l'application
curl http://localhost:5000/health
```

### Utiliser docker-compose

```bash
# Lancer l'application
docker-compose up

# Voir les logs
docker-compose logs -f

# Arrêter l'application
docker-compose down
```

---

## 🐛 Dépannage

### Le webhook ne se déclenche pas
- ✅ Vérifier que le secret du webhook est correct
- ✅ Vérifier que l'URL du webhook est accessible
- ✅ Vérifier les logs dans Coolify

### L'image Docker ne se construit pas
- ✅ Vérifier les logs GitHub Actions
- ✅ Tester localement : `docker build .`
- ✅ Vérifier les erreurs Bandit

### L'application ne redémarre pas après déploiement
- ✅ Vérifier que le HEALTHCHECK dans le Dockerfile fonctionne
- ✅ Vérifier que le port 5000 est exposé
- ✅ Vérifier les environnements variables dans Coolify

---

## 📝 Checklist avant la livraison

- [ ] Dockerfile créé et testé localement
- [ ] `.dockerignore` créé
- [ ] GitHub Actions workflow créé
- [ ] Bandit job fonctionnel
- [ ] Docker build et push fonctionnels
- [ ] Container Registry (ghcr.io) accessible
- [ ] Coolify configuré avec webhook
- [ ] DNS configuré pour `site.tpdevopslabXX.store`
- [ ] SSL/TLS certificat généré (Let's Encrypt)
- [ ] Variables d'environnement correctes
- [ ] Tests d'accès à l'URL de production

---

**Note** : Remplacer `XX` par votre numéro de groupe dans tous les exemples !
