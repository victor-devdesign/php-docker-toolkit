#!/bin/bash
version=$1

./stop-database.sh

# Caminho do arquivo .env
arquivo="/dockers/.env"

# Verifica se o arquivo existe
if [ -f "$arquivo" ]; then
    # Substitui a linha que começa com DATABASE_SERVICE=
    sed -i "s/^DATABASE_SERVICE=.*/DATABASE_SERVICE=$version/g" "$arquivo"
fi

# Inicializa conforme tipo de banco de dados

case "$version" in
    mysql*)
        docker start "$version"
        docker compose -f /dockers/docker-compose-pma.yml up -d
    ;;
    mariadb*)
        docker start "$version"
        docker compose -f /dockers/docker-compose-pma.yml up -d
    ;;
    sqlserver*)
        docker start mssql-tools
        docker start "$version"
    ;;
    postgresql*)
        docker start "$version"
    ;;
    *)
        echo "Tipo de banco de dados desconhecido: $version"
        exit 1
    ;;
esac
