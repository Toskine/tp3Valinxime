#!/bin/bash

# 🚀 Script d'installation Coolify - Une ligne pour les impatients !

# ============================================
# OPTION 1 : Installation officielle Coolify
# ============================================
# Copier-coller UNE de ces commandes :

# Sur Linux/Unix (recommandé) :
curl -fsSL https://get.cooli.dev | bash

# Ou avec Docker directement :
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /root:/root \
  -v /opt/coolify:/opt/coolify \
  ghcr.io/coollabsio/coolify:latest

# ============================================
# OPTION 2 : Avec Docker Compose
# ============================================

# Télécharger le fichier docker-compose
curl -O https://raw.githubusercontent.com/Toskine/tp3Valinxime/main/docker-compose-coolify.yml

# Lancer Coolify
docker-compose -f docker-compose-coolify.yml up -d

# Vérifier le statut
docker-compose -f docker-compose-coolify.yml ps

# Voir les logs
docker-compose -f docker-compose-coolify.yml logs -f coolify

# ============================================
# APRÈS INSTALLATION
# ============================================

# Accéder à Coolify :
# https://your-server-ip:3000

# Identifiants par défaut :
# Email: admin@coolify.io
# Password: password

# ⚠️ CHANGER LE MOT DE PASSE IMMÉDIATEMENT !

# ============================================
# COMMANDS UTILES
# ============================================

# Redémarrer Coolify
docker-compose -f docker-compose-coolify.yml restart coolify

# Arrêter Coolify
docker-compose -f docker-compose-coolify.yml down

# Réinitialiser complètement (DANGER - supprime les données !)
docker-compose -f docker-compose-coolify.yml down -v

# Voir les détails du conteneur
docker inspect coolify

# Exécuter une commande dans Coolify
docker exec coolify /bin/sh

# Vérifier les logs d'erreur
docker logs coolify | tail -100

# ============================================
# DÉPANNAGE
# ============================================

# Coolify ne démarre pas ?
docker logs coolify

# Port 3000 déjà utilisé ?
sudo ss -tlnp | grep 3000
sudo lsof -i :3000

# Pas d'accès à Docker ?
sudo usermod -aG docker $USER
newgrp docker

# Certificat SSL non généré ?
docker exec postgres psql -U coolify -d coolify -c "SELECT * FROM services;"

# ============================================
# CONFIGURATION RAPIDE APRÈS CONNEXION
# ============================================

# 1. Connexion
# https://your-server-ip:3000

# 2. Créer un projet
# Projects → New Project → TP03-MemeForge

# 3. Créer une application
# New Application
# - Name: memeforge
# - Repository: https://github.com/Toskine/tp3Valinxime.git
# - Branch: main
# - Dockerfile: ./Dockerfile

# 4. Ajouter variables d'environnement
# Environment Variables:
# SECRET_KEY=votre-clé-secrète
# FLASK_ENV=production
# FLASK_DEBUG=False

# 5. Ajouter domaine
# Domains → Add Domain
# site.tpdevopslab01.store

# 6. Configurer webhook GitHub
# Webhooks → Generate Webhook
# Copier dans GitHub Settings → Webhooks

# 7. Configurer DNS auprès de votre provider
# A / CNAME record pointant vers votre serveur

# ============================================
# VÉRIFICATION FINALE
# ============================================

# Test de santé
curl https://your-server-ip:3000

# Test de l'application
curl https://site.tpdevopslab01.store/health

# Voir les conteneurs déployés
docker ps

# ============================================
# IMPORTANT - À RETENIR
# ============================================

# ✅ Changer le mot de passe par défaut
# ✅ Configurer les certificats SSL
# ✅ Ajouter un token GitHub
# ✅ Configurer les webhooks
# ✅ Tester les déploiements

# 🔗 Resources:
# https://coolify.io
# https://docs.cooli.dev
# https://github.com/coollabsio/coolify
