#!/bin/bash

# Script automatizado para clonar, preparar ambiente e sugerir próximos passos para projetos PHP
# - Suporte para clonagem de repositórios do GitHub
# - Suporte para clonagem de repositórios via HTTPS
# - Suporte para clonagem de repositórios via chave SSH
#
# v1.0
# Uso: ./git-clone.sh <git-repo-url> [nome-do-diretorio]
# OBS.: Não utilizar sudo para rodar este script, ele irá solicitar permissões se necessário.

set -e

# 1. Validação de argumentos
if [ -z "$1" ]; then
    echo -e "\nUso: $0 <git-repo-url> [nome-do-diretorio]"
    exit 1
fi

repo_url="$1"
dir_name="$2"

# 1. Recupera o proprietário do repositório
echo ""
echo "Qual o proprietário ou agrupador do repositório?"
read -r owner

# 2. Clonagem do repositório
cd ~/www || { echo "Erro: diretório ~/www não encontrado." >&2; exit 1; }
if [ -z "$dir_name" ]; then
    git clone "${repo_url}" || { echo "Erro ao clonar o repositório: ${repo_url}" >&2; exit 1; }
else
    git clone "${repo_url}" "${dir_name}" || { echo "Erro ao clonar o repositório: ${repo_url}" >&2; exit 1; }
fi

# 3. Determina o diretório do projeto
if [ -z "$dir_name" ]; then
    repo_dir=$(basename "$repo_url" .git)
else
    repo_dir="$dir_name"
fi

echo ""
echo "Acessando o diretório: ${repo_dir}"
cd "${repo_dir}"

# 4. Ajusta permissões e configurações do git
git config core.fileMode false
git config --global core.fileMode false
sudo chmod -R 2777 ./

# 5. Recupera a versão do php
echo ""
echo "Qual versão PHP será utilizada?"
read -r version

# 5.1 Recupera se o php roda em uma porta customizada
echo ""
echo "O PHP roda em uma porta customizada? (yes/no)"
read -r custom_port
if [ "${custom_port}" = "yes" ]; then
    echo "Qual porta?"
    read -r port
fi

# 6. Recupera o sistema de banco de dados
echo ""
echo "Qual sistema de banco de dados será utilizado? (mysql/mariadb/sqlserver)"
read -r db

# 6.1 Recupera a versão do sistema de banco de dados
echo ""
echo "Qual versão do $db será utilizado?"
read -r db_version

# 7. Gera arquivo .env (se necessário)
if [ -f env ]; then
    # Copia exemplo de .env
    cp env .env
    
    # Valida estrutura de url a partir da versão do php
    if [ "$version" -ge 8 ]; then
        domain="${repo_dir}/public"
    else
        domain="${repo_dir}"
    fi
    
    if [ -z "$port" ]; then
        url="http://localhost/${domain}"
    else
        url="http://localhost:${port}/${domain}"
    fi

    # 7.1 Define url
    sed -i "s|^app.baseURL *=.*|app.baseURL = '${url}'|g" .env

    # 7.2 Define configurações de banco de dados
    sed -i "s|^database.default.hostname *=.*|database.default.hostname = ${db}${db_version}|g" .env
    sed -i "s|^database.default.database *=.*|database.default.database = ${owner}_${repo_dir}|g" .env
    sed -i "s|^database.db_logs.hostname *=.*|database.db_logs.hostname = ${db}${db_version}|g" .env
    sed -i "s|^database.db_logs.database *=.*|database.db_logs.database = ${owner}_${repo_dir}_logs|g" .env
fi

# 8. Reinicia o servidor docker
sudo systemctl restart docker || { echo "Erro ao reiniciar o Docker." >&2; exit 1; }

# 8.1 Limpa os containers
~/php-docker-toolkit/stop-all.sh || { echo "Erro ao parar os containers." >&2; exit 1; }

# 8.2 Sobe a versão php solicitada
~/php-docker-toolkit/php/start.sh $version || { echo "Erro ao iniciar o container PHP $version." >&2; exit 1; }

# 8.3 Sobe a versão do banco de dados solicitada
~/php-docker-toolkit/database/start.sh $db$db_version || { echo "Erro ao iniciar o container $db$db_version." >&2; exit 1; }

# Enquanto os containers não estiverem no ar ou não atingir 5 segundos de espera
for i in {1..5}; do
    if [ "$(docker ps -q -f name=php$version)" ] && [ "$(docker ps -q -f name=$db$db_version)" ]; then
        break
    fi
    echo "Aguardando containers PHP e $db$db_version estarem prontos... (+1 segundo)"
    sleep 1
done

echo "";

# 9. Instala as dependências do projeto
docker exec -it php$version bash -c "
    cd /var/www/html/$repo_dir
    git config --global --add safe.directory /var/www/html/$repo_dir
    composer install --no-dev
    exit
" || { echo "Erro ao instalar as dependências com Composer." >&2; exit 1; }

# 10. Cria o banco de dados
if [ "$db" = "mysql" ] || [ "$db" = "mariadb" ]; then
    {
        docker exec -it $db$db_version $db -u root -p"tiger" -e "CREATE DATABASE IF NOT EXISTS ${owner}_${repo_dir};"
        docker exec -it $db$db_version $db -u root -p"tiger" -e "CREATE DATABASE IF NOT EXISTS ${owner}_${repo_dir}_logs;"
    } || { echo "Erro ao criar o(s) banco(s) de dados. Verifique se o container está rodando e se as credenciais estão corretas." >&2; exit 1; }
else
    echo "Não foi possível clonar o repositório pois o script não oferece suporte ao banco de dados ${db}."
    exit 1
fi

sudo chmod -R 2777 ./ || { echo "Erro ao ajustar as permissões do diretório." >&2; exit 1; }

# OBS.: A partir deste ponto, o ambiente já deve estar configurado, mostrar definições gerais e abrir o projeto
echo ""
echo "Projeto clonado e ambiente configurado com sucesso!"
echo "URL do projeto: ${url}"
echo "Banco de dados: ${owner}_${repo_dir}"
echo "Caminho do projeto: ~/www/${repo_dir}"

echo ""
echo "Abrindo repositório no VS Code"
code . || echo "Aviso: Não foi possível abrir o VS Code." >&2

# 11. Abre o projeto no navegador Microsoft Edge
echo "Abrindo projeto no Microsoft Edge..."
explorer.exe "microsoft-edge:$url"

# 12. Abre phpMyAdmin no navegador Microsoft Edge
echo "Abrindo phpMyAdmin no Microsoft Edge..."
explorer.exe "microsoft-edge:http://localhost:8080"