# MyFinance Robot API

Repositório do projeto **MyFinance Robot**, contendo a API baseada na Evolution API para integração WhatsApp.

## Estrutura

- **evolution-api/** – API REST (Evolution API) para WhatsApp (Baileys, Meta Business, etc.)
- **Dockerfile** (na raiz) – usado pelo **Render** para build e deploy (contexto = raiz do repo).

## Deploy no Render

1. Conecte o repositório ao Render (Web Service).
2. **Build Command:** deixe em branco (o Render usa o Dockerfile).
3. **Dockerfile path:** `Dockerfile` (na raiz).
4. **Variáveis de ambiente** (obrigatórias no Render):
   - `DATABASE_PROVIDER` = `postgresql` (ou `mysql` se usar MySQL).
   - `DATABASE_CONNECTION_URI` = URL do banco (ex.: use o PostgreSQL do Render ou externo).  
     O script de deploy adiciona automaticamente `connection_limit=5` e `pool_timeout=30` para evitar erro P2024 (timeout do pool) no PostgreSQL com poucas conexões. Se quiser outros valores, inclua na própria URL, ex.: `?connection_limit=3&pool_timeout=60`.
   - **Cache:** por padrão a imagem usa cache local (Redis desligado). Para usar o **Redis do Vercel (Upstash)** na Evolution:
     - No [Upstash Console](https://console.upstash.com/) (Vercel KV usa Upstash), abra o banco e copie a **Redis URL** (formato `rediss://default:...@....upstash.io:6379`). Não use a REST URL do Vercel.
     - No Render: `CACHE_REDIS_ENABLED` = `true`, `CACHE_REDIS_URI` = essa Redis URL.
     - Se não configurar Redis, deixe como está: `CACHE_REDIS_ENABLED` = `false`, `CACHE_LOCAL_ENABLED` = `true`.
   - `AUTHENTICATION_API_KEY` = chave para a API (header `apikey`).
   - `SERVER_URL` = URL pública do serviço (ex.: `https://sua-evolution.onrender.com`).
   - Demais variáveis conforme [evolution-api/.env.example](evolution-api/.env.example) (CORS, etc.).
5. **Porta:** 8080 (já exposta no Dockerfile).

Após o deploy, use a URL do serviço (ex.: `https://sua-evolution.onrender.com`) como `EVOLUTION_API_URL` no app MiFinance na Vercel.

## Como usar localmente

```bash
cd evolution-api
cp .env.example .env
# Configure as variáveis em .env
npm install
npm run dev:server
```

Documentação completa em [evolution-api/README.md](evolution-api/README.md).

## Repositório

- **GitHub:** https://github.com/MuriloCruzzz/myfinancerobotAPI
