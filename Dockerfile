# Dockerfile na raiz para o Render (repositório tem Evolution API em evolution-api/)
# Build: contexto = raiz do repo; copia evolution-api/ e usa o mesmo fluxo da Evolution API.

FROM node:24-alpine AS builder

RUN apk update && \
    apk add --no-cache git ffmpeg wget curl bash openssl dos2unix

WORKDIR /evolution

# Copiar todo o conteúdo da pasta evolution-api (contexto do Render = raiz do repo)
COPY evolution-api/ ./

# .env é exigido pelos scripts; usar .env.example como base (variáveis reais no Render)
RUN cp .env.example .env && \
    sed -i 's/^CACHE_REDIS_ENABLED=true/CACHE_REDIS_ENABLED=false/' .env && \
    sed -i 's/^CACHE_LOCAL_ENABLED=false/CACHE_LOCAL_ENABLED=true/' .env

# Instalar dependências antes dos scripts (db:generate e build precisam de node_modules)
RUN npm ci --silent

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*

RUN ./Docker/scripts/generate_database.sh

RUN npm run build

# --- Estágio final ---
FROM node:24-alpine AS final

RUN apk update && \
    apk add --no-cache tzdata ffmpeg bash openssl

ENV TZ=America/Sao_Paulo
ENV DOCKER_ENV=true

WORKDIR /evolution

COPY --from=builder /evolution/package.json ./package.json
COPY --from=builder /evolution/package-lock.json ./package-lock.json
COPY --from=builder /evolution/node_modules ./node_modules
COPY --from=builder /evolution/dist ./dist
COPY --from=builder /evolution/prisma ./prisma
COPY --from=builder /evolution/manager ./manager
COPY --from=builder /evolution/public ./public
COPY --from=builder /evolution/.env ./.env
COPY --from=builder /evolution/Docker ./Docker
COPY --from=builder /evolution/runWithProvider.js ./runWithProvider.js
COPY --from=builder /evolution/tsup.config.ts ./tsup.config.ts

EXPOSE 8080

# Render (e outros PaaS) definem PORT em runtime; a Evolution API usa SERVER_PORT.
# Garantir que a app escute na porta que o Render espera.
ENTRYPOINT ["/bin/bash", "-c", "export SERVER_PORT=${PORT:-8080} && . ./Docker/scripts/deploy_database.sh && npm run start:prod"]
