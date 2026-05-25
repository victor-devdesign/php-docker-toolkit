# php-docker-toolkit

Toolkit de automação para ambientes PHP com Docker.

O objetivo deste projeto é padronizar e acelerar o onboarding de projetos PHP locais, permitindo iniciar rapidamente ambientes contendo:

- PHP
- MySQL / MariaDB
- PostgreSQL
- SQL Server
- phpMyAdmin
- Composer
- Projetos CodeIgniter

---

# Recursos

- Inicialização automática de containers PHP
- Inicialização automática de bancos de dados
- Integração com phpMyAdmin
- Automatização de clone e setup de projetos
- Suporte a múltiplas versões de PHP
- Suporte a múltiplos bancos de dados
- Scripts padronizados para ambiente local
- Fluxo simplificado para onboarding de novos projetos

---

# Estrutura do Projeto

```bash
php-docker-toolkit/
├── git-clone.sh
├── run-project.sh
├── stop-all.sh
├── php/
│   ├── start.sh
│   └── stop.sh
└── database/
    ├── start.sh
    └── stop.sh
```

---

# Pré-requisitos

Antes de utilizar o toolkit, certifique-se de possuir:

- Docker instalado
- Docker Compose instalado
- Containers previamente criados
- Diretório `~/www`
- Microsoft Edge (WSL/Windows)
- Permissões de execução nos scripts

---

# Containers Esperados

## PHP

Exemplos:

```bash
php56
php70
php74
php82
php84
```

## Banco de Dados

Exemplos:

```bash
mysql8
mariadb10.6
postgresql15
sqlserver2019
```

---

# Instalação

Clone o repositório:

```bash
git clone <repo-url> ~/php-docker-toolkit
```

Adicione permissões de execução:

```bash
chmod +x ~/php-docker-toolkit/*.sh
chmod +x ~/php-docker-toolkit/php/*.sh
chmod +x ~/php-docker-toolkit/database/*.sh
```

Opcionalmente, adicione aliases ao `.bashrc`:

```bash
alias run-project="~/php-docker-toolkit/run-project.sh"
alias stop-docker="~/php-docker-toolkit/stop-all.sh"
```

Depois:

```bash
source ~/.bashrc
```

---

# Uso

## Iniciar Projeto

```bash
~/php-docker-toolkit/run-project.sh <project> <php_version> <database>
```

### Exemplo

```bash
~/php-docker-toolkit/run-project.sh crm php82 mysql8
```

O script irá:

1. Parar containers anteriores
2. Iniciar ambiente PHP
3. Inicializar banco de dados
4. Exibir containers ativos
5. Ler `.env`
6. Abrir projeto no navegador
7. Abrir phpMyAdmin quando aplicável

---

## Iniciar PHP Manualmente

```bash
~/php-docker-toolkit/php/start.sh php82
```

---

## Parar Containers PHP

```bash
~/php-docker-toolkit/php/stop.sh
```

---

## Iniciar Banco de Dados

```bash
~/php-docker-toolkit/database/start.sh mysql8
```

---

## Parar Bancos de Dados

```bash
~/php-docker-toolkit/database/stop.sh
```

---

## Parar Todo Ambiente

```bash
~/php-docker-toolkit/stop-all.sh
```

---

# git-clone.sh

O script `git-clone.sh` automatiza o processo de setup de novos projetos.

## Funcionalidades

- Clone automático do repositório
- Configuração inicial do `.env`
- Inicialização do ambiente Docker
- Execução de `composer install`
- Criação de banco de dados
- Ajuste de permissões
- Configuração automática de URL

## Uso

```bash
~/php-docker-toolkit/git-clone.sh <repository-url> [directory]
```

### Exemplos

```bash
~/php-docker-toolkit/git-clone.sh git@github.com:empresa/projeto.git

~/php-docker-toolkit/git-clone.sh https://github.com/empresa/projeto.git crm-local
```

---

# Compatibilidade

Projetado principalmente para:

- WSL2
- Ubuntu
- Docker Desktop
- Microsoft Edge

Pode ser adaptado facilmente para:

- macOS
- Linux nativo
- Firefox
- Google Chrome

---

# Roadmap

- [ ] Detecção automática de containers
- [ ] Healthcheck de containers
- [ ] Integração com pgAdmin
- [ ] Integração com Mongo Express
- [ ] Menu interativo com fzf
- [ ] Configuração centralizada
- [ ] Logs persistentes
- [ ] Compatibilidade multiplataforma

---

# Convenções

## Estrutura esperada do `.env`

```env
app.baseURL=http://localhost/project
```

## Diretório esperado

```bash
~/www
```

---

# Licença

Consulte o arquivo `LICENSE` para mais informações.
