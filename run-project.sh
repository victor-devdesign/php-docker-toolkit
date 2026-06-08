#!/bin/bash

############################################################
# Script: run-project.sh
#
# Descrição:
#   Inicia ambiente PHP + Database, lista containers
#   Docker e abre o projeto no navegador padrão.
#
#   Caso o .env não contenha app.baseURL,
#   será utilizada uma URL padrão localhost.
#
# Uso:
#   ./run-project.sh <project> <php_version> <database>
############################################################

# Interrompe execução caso ocorra algum erro
set -e

# Variáveis recebidas via argumento
PROJECT=$1
PHP_VERSION=$2
DATABASE=$3

# Caminho absoluto do projeto
PROJECT_PATH="$HOME/www/$PROJECT"

# URL padrão do phpMyAdmin
PHPMYADMIN_URL="http://localhost:8080"

# Cores de terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

############################################################
# Funções auxiliares
############################################################

# Exibe títulos formatados
print_title() {
  echo ""
  echo -e "${BLUE}===============================${NC}"
  echo -e "${GREEN}# $1${NC}"
  echo -e "${BLUE}===============================${NC}"
  echo ""
}

# Exibe mensagens de erro
print_error() {
  echo -e "${RED}Erro:${NC} $1"
}

# Exibe mensagens de aviso
print_warning() {
  echo -e "${YELLOW}Aviso:${NC} $1"
}

# Inicializa serviços Docker
start_services() {
  print_title "Iniciando ambiente"
  cd ~/php-docker-toolkit

  ./stop-all.sh
  ./php/start.sh "$PHP_VERSION"
  ./database/start.sh "$DATABASE"
}

# Aguarda containers estabilizarem
wait_services() {
  echo ""
  echo "Aguardando inicialização dos serviços ..."
  sleep 5
}

# Execução de abertura de uma url no navegador
open_url() {
    local url="$1"
    cmd.exe /c start "" "$url" >/dev/null 2>&1
}

# Abre ferramentas relacionadas ao banco
open_database_tool() {
  if [[ "$DATABASE" =~ ^(mysql|mariadb) ]]; then
    echo "Abrindo phpMyAdmin no navegador padrão..."
    open_url "$PHPMYADMIN_URL"

  elif [[ "$DATABASE" =~ ^(pgsql|postgres) ]]; then
    print_warning "PostgreSQL detectado sem ferramenta web configurada."

  elif [[ "$DATABASE" =~ ^sqlserver ]]; then
    print_warning "SQL Server detectado sem ferramenta web configurada."

  else
    print_warning "Banco de dados sem integração web."
  fi
}

############################################################
# Execução
############################################################

if [ -z "$PROJECT" ]; then
  print_error "Projeto não informado."
  exit 1
fi

if [ -z "$PHP_VERSION" ]; then
  print_error "Versão do PHP não informada."
  exit 1
fi

if [ -z "$DATABASE" ]; then
  print_error "Banco de dados não informado."
  exit 1
fi

# Inicializa ambiente Docker
start_services

# Lista containers em execução
print_title "Containers Docker em execução"
docker ps

# Valida diretório do projeto
if [ ! -d "$PROJECT_PATH" ]; then
  print_error "Pasta do projeto não encontrada:"
  echo "$PROJECT_PATH"
  exit 1
fi

# Acessa diretório do projeto
cd "$PROJECT_PATH"

# Lê URL da aplicação via .env
print_title "Lendo configuração .env"
if [ -f ".env" ]; then
  # Captura app.baseURL ignorando espaços
  URL=$(grep -E '^\s*app.baseURL\s*=' .env \
    | cut -d '=' -f2- \
    | sed 's/^[[:space:]"\x27]*//;s/[[:space:]"\x27]*$//')
fi

# Define URL padrão caso não exista no .env
if [ -z "$URL" ]; then
  print_warning "app.baseURL não encontrada no .env"
  case "$PHP_VERSION" in
    *74*)
      URL="http://localhost:8074/$PROJECT"
      ;;
    *)
      URL="http://localhost/$PROJECT"
      ;;
  esac
  echo "Configurações de execução definidas"
fi

# Aguarda serviços Docker
wait_services

# Exibe informações da aplicação
print_title "Executando aplicação"
echo "Projeto: $URL"

# Abre projeto no navegador
echo "Abrindo projeto no navegador padrão..."
open_url "$URL"

# Abre ferramenta do banco de dados
open_database_tool

############################################################
# Finalização
############################################################

echo ""
echo -e "${GREEN}===============================${NC}"
echo -e "${GREEN}# Script finalizado com sucesso.${NC}"
echo -e "${GREEN}===============================${NC}"
echo ""
```