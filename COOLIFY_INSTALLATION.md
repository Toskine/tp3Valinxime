# 🚀 Guide d'installation Coolify - Démarrage rapide

Ce guide vous montre comment créer une instance Coolify pour votre TP03.

---

## ⚡ Installation rapide (2-3 minutes)

### Sur un serveur Linux (Ubuntu/Debian)

```bash
# 1. SSH sur votre serveur
ssh root@your-server-ip

# 2. Installer Docker (si pas déjà installé)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Installer Coolify
curl -fsSL https://get.cooli.dev | bash

# 4. Attendre ~2 minutes que ça démarre
# L'accès sera sur : https://your-server-ip:3000
```

---

## 🖥️ Configuration après installation

### 1️⃣ Première connexion

1. Ouvrir : `https://your-server-ip:3000`
2. Identifiants par défaut :
   - Email : `admin@coolify.io`
   - Password : `password`

**⚠️ IMPORTANT** : Changer le mot de passe immédiatement !

### 2️⃣ Créer un projet

1. Cliquer **Projects** → **New Project**
2. Nommer : `TP03-MemeForge`
3. Cliquer **Create**

### 3️⃣ Ajouter une application

1. Dans le projet, cliquer **New Application**
2. Remplir :
   - **Name** : `memeforge`
   - **Repository** : `https://github.com/Toskine/tp3Valinxime.git`
   - **Branch** : `main`
   - **Build Method** : `Docker`
   - **Dockerfile Path** : `./Dockerfile`

3. Cliquer **Create**

### 4️⃣ Configurer les variables d'environnement

1. Dans l'app, cliquer **Environment Variables**
2. Ajouter :
```
SECRET_KEY=your-super-secret-key-min-32-chars
FLASK_ENV=production
FLASK_DEBUG=False
```

3. **Save**

### 5️⃣ Exposer le port

1. Cliquer **Port Mappings** ou **Ports**
2. **Add Port** :
   - **Interne** : `5000`
   - **Externe** : `5000`

3. **Save**

### 6️⃣ Ajouter le domaine

1. Cliquer **Domains**
2. **Add Domain** :
   - **Domaine** : `site.tpdevopslab01.store`
   - **Path** : `/`
   - **Port** : `5000`
   - **Auto SSL** : Cocher

3. **Add**

### 7️⃣ Configurer le webhook GitHub

1. Cliquer **Webhooks**
2. **Generate Webhook** - Copier l'URL

3. Dans GitHub :
   - **Settings** → **Webhooks** → **Add webhook**
   - **Payload URL** : Coller l'URL
   - **Content type** : `application/json`
   - **Events** : `Push events`
   - **Active** : Cocher
   - **Add webhook**

### 8️⃣ Configurer DNS

Contact votre instructeur ou fournisseur DNS pour :
- Créer un enregistrement A ou CNAME
- Pointant vers l'IP publique du serveur Coolify

Example :
```
site.tpdevopslab01.store  →  192.168.1.100  (IP du serveur)
```

---

## 🧪 Tester

### Premier déploiement manuel

1. Dans Coolify, cliquer **Deploy** (bouton bleu)
2. Suivre les logs en temps réel
3. Attendre que le déploiement se termine

### Tester l'application

```bash
# Via curl
curl https://site.tpdevopslab01.store/health

# Devrait retourner :
# {"status": "healthy", "service": "memeforge"}

# Ou ouvrir dans le navigateur :
# https://site.tpdevopslab01.store
```

---

## 🔑 Variables d'environnement essentielles

```env
# Sécurité
SECRET_KEY=your-secret-key-at-least-32-chars

# Configuration Flask
FLASK_ENV=production
FLASK_DEBUG=False

# Réseau
HOST=0.0.0.0
PORT=5000
```

---

## 🐛 Dépannage rapide

### Coolify n'accède pas à GitHub

**Solution** :
1. Vérifier que le repo est public OU
2. Ajouter un Personal Access Token GitHub dans Coolify Settings

### Le webhook ne se déclenche pas

**Solution** :
1. Vérifier l'URL du webhook dans GitHub Settings
2. Vérifier que Coolify est accessible depuis GitHub
3. Voir les logs du webhook dans GitHub Settings

### Certificat SSL ne se génère pas

**Solution** :
1. Vérifier que le DNS pointe vers Coolify
2. Vérifier que le port 80/443 est ouvert
3. Attendre quelques minutes (Let's Encrypt peut être lent)

### L'application ne démarre pas

**Solution** :
1. Vérifier les logs dans Coolify (onglet **Logs**)
2. Vérifier les variables d'environnement
3. Vérifier que le Dockerfile se compile : `docker build .` localement

---

## 📚 Ressources

- **Coolify Docs** : https://docs.cooli.dev
- **Docker Docs** : https://docs.docker.com
- **Let's Encrypt** : https://letsencrypt.org

---

## ✅ Checklist rapide

- [ ] Coolify installé et en cours d'exécution
- [ ] Mot de passe changé
- [ ] Projet créé
- [ ] Application créée
- [ ] Variables d'environnement configurées
- [ ] Domaine ajouté
- [ ] Webhook GitHub configuré
- [ ] DNS configuré
- [ ] Premier déploiement réussi
- [ ] URL accessible et fonctionnelle

---

**Besoin d'aide ?** Contactez votre instructeur ou consultez les logs dans Coolify ! 🚀
