#!/bin/sh

set -e

export COMPOSE_PROJECT_NAME=printerbox_backend

cd /workdir
echo "Renewing Let's Encrypt Certificates... (`date`)"
docker compose -p "$COMPOSE_PROJECT_NAME" run --rm --no-deps -T --entrypoint certbot certbot renew --no-random-sleep-on-renew
echo "Reloading Nginx configuration"
docker compose -p "$COMPOSE_PROJECT_NAME" exec -T nginx nginx -t
docker compose -p "$COMPOSE_PROJECT_NAME" exec -T nginx nginx -s reload
