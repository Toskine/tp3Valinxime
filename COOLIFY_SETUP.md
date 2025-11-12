# Configuration DNS et Coolify pour le TP03

## 📋 Configuration DNS

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

1. Connectez-vous à votre instance Coolify
2. **Projects** → **Créer un nouveau projet** → `TP03-MemeForge`
3. **Créer une application** :
   - **Name** : `memeforge`
   - **Source** : GitHub
   - **Repository** : `Toskine/tp3Valinxime`
   - **Branch** : `main`
   - **Dockerfile** : `./Dockerfile`
   - **Port** : `5000`
   - **Environment Variables** :
     ```
     SECRET_KEY=your-secure-key-here
     FLASK_ENV=production
     FLASK_DEBUG=False
     ```

### Étape 2 : Configurer le domaine

1. Dans Coolify, aller à **Application** → **Domains**
2. **Ajouter un domaine** : `site.tpdevopslabXX.store`
3. Coolify générera automatiquement un certificat SSL (Let's Encrypt)

### Étape 3 : Configuration du Webhook GitHub

#### Option A : Webhook simple (re-pull l'image du registry)

1. Dans Coolify, aller à **Application** → **Webhooks**
2. **Créer un webhook** :
   - **Copier l'URL du webhook**
   
3. Dans GitHub :
   - **Repository** → **Settings** → **Webhooks** → **Add webhook**
   - **Payload URL** : `https://your-coolify-instance/api/webhooks/deploy`
   - **Content type** : `application/json`
   - **Events** : `Push events` et `Pull request events`
   - **Secret** : `your-webhook-secret` (configuré dans Coolify)

#### Option B : GitHub App integration (déploiement direct après Bandit)

Si votre instance Coolify supporte l'intégration GitHub App :

1. Dans Coolify, aller à **Settings** → **GitHub App**
2. **Installer l'application GitHub**
3. Donner les permissions nécessaires au repo

Cela permettra à Coolify de :
- Déclencher les déploiements directement
- Recevoir les webhooks automatiquement
- Afficher l'état du déploiement sur les PRs

---

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
