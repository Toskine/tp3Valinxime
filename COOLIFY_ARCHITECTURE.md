# 📊 Architecture et flux Coolify - Guide visuel

## 🏗️ Architecture globale du TP03

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        VOTRE INFRASTRUCTURE                              │
└─────────────────────────────────────────────────────────────────────────┘

        ┌──────────────────────────┐
        │   Your Development PC    │
        │                          │
        │  • Git Repository        │
        │  • Docker Local Tests     │
        │  • Code Editor           │
        └────────────┬─────────────┘
                     │
                     │ git push main
                     ▼
        ┌──────────────────────────┐
        │   GitHub Repository      │
        │   (Toskine/tp3Valinxime) │
        └────────────┬─────────────┘
                     │
                     │ Webhook trigger
                     ▼
        ┌──────────────────────────┐
        │   GitHub Actions         │
        │                          │
        │  1. Bandit SAST scan     │
        │  2. Docker build & push  │
        │     → ghcr.io            │
        │  3. Trigger Coolify      │
        └────────────┬─────────────┘
                     │
                     │ Webhook
                     ▼
        ┌──────────────────────────┐
        │   Your Coolify Server    │
        │   (Production)           │
        │                          │
        │  • Docker daemon         │
        │  • Registry config       │
        │  • SSL/TLS               │
        │  • Domain management     │
        └────────────┬─────────────┘
                     │
                     │ Pulls image & deploys
                     ▼
        ┌──────────────────────────┐
        │   Docker Container       │
        │   (MemeForge app)        │
        │   Port 5000              │
        └──────────────────────────┘
                     │
                     │ HTTP/HTTPS reverse proxy
                     ▼
        ┌──────────────────────────┐
        │   Your Domain            │
        │   site.tpdevopslab01     │
        │   .store (HTTPS)         │
        └──────────────────────────┘
```

---

## 🔄 Flux de déploiement détaillé

```
EVENT: Developer pushes to main branch
│
├─ TRIGGERED: GitHub Actions
│  │
│  ├─ Job 1: Bandit Security Scan
│  │  ├─ Install Python & dependencies
│  │  ├─ Run: bandit -r .
│  │  └─ Output: Security report (JSON + Comments PR)
│  │
│  ├─ WAITS for: Bandit to complete successfully
│  │
│  ├─ Job 2: Docker Build & Push
│  │  ├─ Checkout code
│  │  ├─ Setup Docker Buildx
│  │  ├─ Build Docker image (multi-stage)
│  │  ├─ Push to: ghcr.io/toskine/tp3valinxime:main
│  │  └─ Tags: branch-name, latest (for main), sha
│  │
│  └─ Job 3: Deploy to Coolify (main branch only)
│     ├─ Checkout code
│     ├─ Send POST to COOLIFY_WEBHOOK_URL
│     └─ Payload: {"source":"github","branch":"main"}
│
└─ WEBHOOK RECEIVED by Coolify
   │
   ├─ Step 1: Verify webhook signature
   │
   ├─ Step 2: Check if image available in registry
   │  └─ ghcr.io/toskine/tp3valinxime:main
   │
   ├─ Step 3: Pull latest image
   │
   ├─ Step 4: Stop old container
   │
   ├─ Step 5: Run new container with:
   │  ├─ Image: ghcr.io/toskine/tp3valinxime:main
   │  ├─ Port mapping: 5000:5000
   │  ├─ Environment variables (from Coolify config)
   │  ├─ Health check every 30s
   │  └─ Restart policy: unless-stopped
   │
   ├─ Step 6: Wait for health check to pass
   │
   └─ Step 7: Application live at https://site.tpdevopslab01.store
```

---

## 🖥️ Infrastructure serveur Coolify

```
┌───────────────────────────────────────────────────────────────────┐
│                    Your Linux Server                              │
│              (Ubuntu 20.04+, Debian 10+, etc.)                    │
│                     IP: 1.2.3.4                                   │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │           Docker Engine (daemon)                         │    │
│  │                                                          │    │
│  │  ┌─────────────────────────┐  ┌──────────────────────┐  │    │
│  │  │   Coolify Container     │  │ PostgreSQL Container │  │    │
│  │  │                         │  │                      │  │    │
│  │  │ Port 3000: Admin UI     │  │ Port 5432            │  │    │
│  │  │ Port 80:   HTTP         │  │ Database: coolify    │  │    │
│  │  │ Port 443:  HTTPS        │  └──────────────────────┘  │    │
│  │  │                         │                           │    │
│  │  │ Volumes:                │  Volumes:                 │    │
│  │  │ • /data (config)        │  • PostgreSQL data        │    │
│  │  │ • /logs (logs)          │                           │    │
│  │  │ • /etc/letsencrypt      │                           │    │
│  │  │   (SSL certs)           │                           │    │
│  │  └─────────────────────────┘                           │    │
│  │                                                          │    │
│  │  ┌──────────────────────────────────────────────────┐   │    │
│  │  │      Deployed Applications (MemeForge, etc)      │   │    │
│  │  │                                                  │   │    │
│  │  │ ┌────────────────────┐ ┌──────────────────────┐ │   │    │
│  │  │ │ MemeForge          │ │ Another App          │ │   │    │
│  │  │ │ Container          │ │ Container            │ │   │    │
│  │  │ │                    │ │                      │ │   │    │
│  │  │ │ Port 5000 (intern) │ │ Port 8000 (intern)   │ │   │    │
│  │  │ │ Python Flask app   │ │ Node.js app          │ │   │    │
│  │  │ │                    │ │                      │ │   │    │
│  │  │ │ URL:               │ │ URL:                 │ │   │    │
│  │  │ │ memeforge          │ │ otherapp             │ │   │    │
│  │  │ │ .local             │ │ .local               │ │   │    │
│  │  │ └────────────────────┘ └──────────────────────┘ │   │    │
│  │  │                                                  │   │    │
│  │  └──────────────────────────────────────────────────┘   │    │
│  │                                                          │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
│  Network Bridge: coolify-network                                 │
│  - Coolify manage le routing entre les containers                │
│  - Let's Encrypt gère les certificats SSL                        │
│                                                                   │
└───────────────────────────────────────────────────────────────────┘
        │
        │ Ports ouverts
        ├─ 80 (HTTP)
        ├─ 443 (HTTPS)
        ├─ 3000 (Admin interface - optionnel, fermé en prod)
        └─ 22 (SSH - pour administration)
        
┌───────────────────────────────────────┐
│      User Access                      │
│                                       │
│ https://site.tpdevopslab01.store     │
│         ↓                             │
│  [Reverse Proxy - Coolify]            │
│         ↓                             │
│ [MemeForge Container :5000]           │
│         ↓                             │
│ [Flask Application]                   │
│         ↓                             │
│ [HTML/CSS/JS - Canvas rendering]      │
└───────────────────────────────────────┘
```

---

## 🔐 Flux d'authentification et webhooks

```
┌─────────────────────────────────────────────────────────────────┐
│                  GitHub to Coolify Security                      │
└─────────────────────────────────────────────────────────────────┘

GitHub (HTTPS)
    │
    ├─ Step 1: Generate webhook secret
    │  └─ Example: "your-webhook-secret-12345"
    │
    ├─ Step 2: Coolify generates unique webhook URL
    │  └─ Format: https://coolify.example.com/api/webhooks/deploy/unique-id
    │
    ├─ Step 3: GitHub sends POST request
    │  ├─ Headers: X-Hub-Signature-256: sha256=xxxxx
    │  ├─ Body: JSON payload with commit info
    │  └─ Event: push to main branch
    │
    └─ Step 4: Coolify validates signature
       ├─ Compute: HMAC-SHA256(secret, body)
       ├─ Compare with: X-Hub-Signature-256
       ├─ If valid: Process deployment
       └─ If invalid: Reject (security)
```

---

## 📋 Configuration DNS

```
┌──────────────────────────────────────────────────┐
│         Your DNS Provider                        │
│    (GoDaddy, OVH, Cloudflare, etc.)              │
└──────────────────────────────────────────────────┘
         │
         │ DNS Record Configuration
         │
         ├─ Type: A Record
         │  ├─ Name: site.tpdevopslab01
         │  ├─ TTL: 3600 (1 hour)
         │  └─ Value: 1.2.3.4 (Your server IP)
         │
         └─ OR Type: CNAME Record
            ├─ Name: site.tpdevopslab01
            ├─ TTL: 3600 (1 hour)
            └─ Value: coolify.example.com

USER BROWSER REQUEST
         │
         ├─ https://site.tpdevopslab01.store
         ├─ DNS lookup: site.tpdevopslab01.store
         ├─ Returns: 1.2.3.4
         │
         └─ HTTP/HTTPS request to 1.2.3.4:443
            │
            ├─ Server receives request
            ├─ Coolify reverse proxy handles it
            ├─ Routes to correct container (port 5000)
            ├─ Flask processes request
            └─ HTML response sent back
```

---

## 🧩 Image Docker multi-stage

```
Build Stage 1: Builder
┌─────────────────────────────────────────────────────┐
│ FROM python:3.11-slim (AS builder)                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│ WORKDIR /build                                      │
│                                                     │
│ RUN apt-get install build-tools                     │
│ COPY requirements.txt                               │
│ RUN pip install --user -r requirements.txt          │
│                                                     │
│ Result: /root/.local/lib/python3.11/site-packages   │
│         (All dependencies compiled here)            │
│                                                     │
└─────────────────────────────────────────────────────┘
         │
         │ COPY --from=builder
         ▼
Build Stage 2: Runtime (Final Image)
┌─────────────────────────────────────────────────────┐
│ FROM python:3.11-slim (FINAL)                       │
├─────────────────────────────────────────────────────┤
│                                                     │
│ WORKDIR /app                                        │
│                                                     │
│ RUN useradd -m appuser (non-root user)              │
│                                                     │
│ COPY --from=builder /root/.local /home/appuser/.local
│ COPY app.py, templates/, static/                    │
│                                                     │
│ ENV PATH=/home/appuser/.local/bin:$PATH             │
│ USER appuser (Run as non-root)                      │
│                                                     │
│ EXPOSE 5000                                         │
│ HEALTHCHECK (curl /health every 30s)                │
│ CMD ["python", "-m", "flask", "run"]                │
│                                                     │
│ Final Image Size: ~150-200MB (vs 600MB+ with stage 1)
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 📈 Performance et monitoring

```
┌─────────────────────────────────────────────────────┐
│         Monitoring Dashboard (Coolify)              │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Application Status: ✅ Running                      │
│ Uptime: 99.8% (last 30 days)                        │
│                                                     │
│ ┌─ CPU Usage ────────────────────────┐              │
│ │ ████░░░░░░░░░░░░ 25% (0.5 cores)   │              │
│ └────────────────────────────────────┘              │
│                                                     │
│ ┌─ Memory Usage ─────────────────────┐              │
│ │ ████░░░░░░░░░░░░ 30% (300MB/1GB)   │              │
│ └────────────────────────────────────┘              │
│                                                     │
│ ┌─ Disk Usage ───────────────────────┐              │
│ │ ██░░░░░░░░░░░░░░ 8% (8GB/100GB)    │              │
│ └────────────────────────────────────┘              │
│                                                     │
│ Health Checks: ✅ Passing                           │
│ Last check: 30 seconds ago                          │
│ Success rate: 100%                                  │
│                                                     │
│ Deployments: 12                                     │
│ Last deployment: 2 hours ago                        │
│ Next scheduled: Never (manual + webhook only)       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🚨 Common Issues & Solutions

```
ISSUE 1: "Cannot connect to Coolify"
└─ Check: Is server running? (docker ps)
   Check: Is port 3000 open? (sudo ufw allow 3000)
   Solution: docker-compose -f docker-compose-coolify.yml logs coolify

ISSUE 2: "Webhook not triggering deployment"
└─ Check: URL is accessible from GitHub
   Check: Secret matches in GitHub and Coolify
   Check: Event type is 'Push' not 'Pull Request'
   Solution: Test webhook manually in GitHub settings

ISSUE 3: "Container crashes on start"
└─ Check: Environment variables set in Coolify
   Check: Port 5000 not already in use
   Check: Dockerfile builds locally
   Solution: View logs in Coolify or docker logs memeforge

ISSUE 4: "SSL certificate not generating"
└─ Check: DNS points to server IP
   Check: Port 80 and 443 are open
   Check: Domain is reachable from internet
   Solution: Wait 5-10 minutes, check logs again

ISSUE 5: "Application is slow"
└─ Check: CPU/Memory usage in Coolify dashboard
   Check: Network connectivity to server
   Check: GitHub Container Registry rate limits
   Solution: Upgrade server specs or optimize app
```

---

**Last Update**: 12 novembre 2025
**Created for**: TP03 - Design a CI/CD Github & Coolify
