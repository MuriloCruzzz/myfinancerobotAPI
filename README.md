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
   - Demais variáveis conforme [evolution-api/.env.example](evolution-api/.env.example) (SERVER_URL, CORS, etc.).
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
