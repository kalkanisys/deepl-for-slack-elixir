# DeepL for Slack elixir

## Prerequisites

- git
- Docker

To install docker on debian based linux distro.

```bash
# Skip this if docker is already installed
sudo apt-get update &&
  sudo apt-get upgrade -y -qq &&
  curl -fsSL https://get.docker.com -o get-docker.sh &&
  sudo sh get-docker.sh &&
  rm get-docker.sh
```

## Setup

Run following steps on the server.

- Create public network for Traefik proxy

```bash
docker network create public
```

- Clone git repository

```bash
git clone https://github.com/kalkanisys/deepl-for-slack-elixir.git
```

- Create .env file at root of the repository

```
# Sample env

EMAIL=<your-email-address-for-lets-encrypt>

POSTGRES_USER=slackbot
POSTGRES_PASSWORD=<secure_password>
POSTGRES_DB=slackbot

DOMAIN_NAME=<domain_name_where_this_repo_is_deployed>
PHX_HOST=<domain_name_where_this_repo_is_deployed>
HOSTNAME=<domain_name_where_this_repo_is_deployed>
DEEPL_AUTH_KEY=
SECRET_KEY_BASE=<random 64 character hex>
SLACK_BOT_TOKEN=
SLACK_SIGNING_SECRET=
```

## Start application

- Run following command

```bash

# Start application
docker compose up -d

# Run migration
docker compose exec deepl-slack-bot mix ecto.migrate
```
