#!/bin/bash

source ./Docker/scripts/env_functions.sh

if [ "$DOCKER_ENV" != "true" ]; then
    export_env_vars
fi

# Ajustar pool do Prisma para evitar P2024 no Render (timeout/limite de conexões)
# Reduz connection_limit e aumenta pool_timeout para DB com poucas conexões (ex.: PostgreSQL free)
if [ -n "$DATABASE_CONNECTION_URI" ] && [[ "$DATABASE_CONNECTION_URI" != *"connection_limit"* ]]; then
  if [[ "$DATABASE_CONNECTION_URI" == *"?"* ]]; then
    export DATABASE_CONNECTION_URI="${DATABASE_CONNECTION_URI}&connection_limit=5&pool_timeout=30"
  else
    export DATABASE_CONNECTION_URI="${DATABASE_CONNECTION_URI}?connection_limit=5&pool_timeout=30"
  fi
fi

if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    export DATABASE_URL
    echo "Deploying migrations for $DATABASE_PROVIDER"
    echo "Database URL: $DATABASE_URL"
    # rm -rf ./prisma/migrations
    # cp -r ./prisma/$DATABASE_PROVIDER-migrations ./prisma/migrations
    npm run db:deploy
    if [ $? -ne 0 ]; then
        echo "Migration failed"
        exit 1
    else
        echo "Migration succeeded"
    fi
    npm run db:generate
    if [ $? -ne 0 ]; then
        echo "Prisma generate failed"
        exit 1
    else
        echo "Prisma generate succeeded"
    fi
else
    echo "Error: Database provider $DATABASE_PROVIDER invalid."
    exit 1
fi
