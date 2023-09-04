#!/bin/sh

cd /workdir
echo "Renewing Let's Encrypt Certificates... (`date`)"
docker-compose run --rm --no-deps --no-TTY --entrypoint certbot certbot renew --no-random-sleep-on-renew
echo "Reloading Nginx configuration"
docker-compose exec -T nginx nginx -s reload
