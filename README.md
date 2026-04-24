# php-docker-toolkit

Conjunto de scripts para gerenciar ambientes PHP em Docker — sobe, para e configura containers de PHP e banco de dados, além de automatizar o clone e a preparação de projetos.

---

## Estrutura

```
php-docker-toolkit/
├── git-clone.sh        # Clona um repositório PHP e configura o ambiente completo
├── stop-all.sh         # Para todos os containers Docker em execução
├── php/
│   ├── start.sh        # Inicia o container PHP da versão especificada
│   └── stop.sh         # Para todos os containers PHP
└── database/
    ├── start.sh        # Inicia o container de banco de dados especificado
    └── stop.sh         # Para todos os containers de banco de dados
```

---

## Pré-requisitos

- Docker instalado e em execução
- Containers Docker já criados (o toolkit apenas os inicia/para), nomeados conforme o padrão:
  - PHP: `php5`, `php7`, `php8`, etc.
  - Banco de dados: `mysql8.0`, `mariadb10.6`, `sqlserver2019`, `postgresql15`, etc.
- Diretório `~/www` existente (destino dos projetos clonados)
- Arquivo `/dockers/.env` com a variável `DATABASE_SERVICE` (usado pelo `database/start.sh`)
- Arquivo `/dockers/docker-compose-pma.yml` para subir o phpMyAdmin junto ao MySQL/MariaDB

---

## Guia de uso

### Iniciar container PHP

```bash
~/php-docker-toolkit/php/start.sh <versao>
```

**Exemplos:**

```bash
# Iniciar PHP 8
~/php-docker-toolkit/php/start.sh 8

# Iniciar PHP 7
~/php-docker-toolkit/php/start.sh 7
```

---

### Parar containers PHP

```bash
~/php-docker-toolkit/php/stop.sh
```

---

### Iniciar container de banco de dados

```bash
~/php-docker-toolkit/database/start.sh <banco><versao>
```

**Exemplos:**

```bash
# MySQL 8.0
~/php-docker-toolkit/database/start.sh mysql8.0

# MariaDB 10.6
~/php-docker-toolkit/database/start.sh mariadb10.6

# SQL Server 2019
~/php-docker-toolkit/database/start.sh sqlserver2019

# PostgreSQL 15
~/php-docker-toolkit/database/start.sh postgresql15
```

> Para MySQL e MariaDB, o phpMyAdmin é iniciado automaticamente via `docker-compose-pma.yml`.

---

### Parar containers de banco de dados

```bash
~/php-docker-toolkit/database/stop.sh
```

---

### Parar todos os containers

```bash
~/php-docker-toolkit/stop-all.sh
```

---

### Clonar e configurar um projeto PHP

O script `git-clone.sh` automatiza todo o fluxo de onboarding de um projeto:

1. Clona o repositório em `~/www`
2. Ajusta permissões
3. Configura o `.env` do projeto (URL, banco de dados)
4. Reinicia o Docker e sobe os containers necessários
5. Executa `composer install` dentro do container PHP
6. Cria os bancos de dados no container

```bash
~/php-docker-toolkit/git-clone.sh <url-do-repositorio> [nome-do-diretorio]
```

**Exemplos:**

```bash
# Clonar pelo nome padrão do repositório
~/php-docker-toolkit/git-clone.sh git@github.com:empresa/meu-projeto.git

# Clonar com nome de diretório customizado
~/php-docker-toolkit/git-clone.sh https://github.com/empresa/meu-projeto.git projeto-local
```

Durante a execução, o script fará as seguintes perguntas interativas:

| Pergunta                              | Exemplo de resposta               |
| ------------------------------------- | --------------------------------- |
| Proprietário/agrupador do repositório | `empresa`                         |
| Versão do PHP                         | `8`                               |
| PHP roda em porta customizada?        | `yes` / `no`                      |
| Porta customizada (se aplicável)      | `8080`                            |
| Sistema de banco de dados             | `mysql` / `mariadb` / `sqlserver` |
| Versão do banco de dados              | `8.0` / `10.6` / `2019`           |

Ao final, o projeto estará acessível em `http://localhost/<diretorio>/public` (PHP ≥ 8) ou `http://localhost/<diretorio>` (PHP < 8).

---

## Observações

- Não utilize `sudo` para executar o `git-clone.sh`; o script solicitará permissões quando necessário.
- A senha `root` padrão esperada para MySQL/MariaDB é `tiger`.
- O script `git-clone.sh` pressupõe que o projeto usa **CodeIgniter** (detecta estrutura de `.env` com `app.baseURL` e `database.default.*`).

