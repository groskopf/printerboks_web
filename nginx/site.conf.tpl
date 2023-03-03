upstream api_server {
    # fail_timeout=0 means we always retry an upstream even if it failed
    # to return a good HTTP response

    # for a TCP configuration
    server api:8000 fail_timeout=0;
}

server {
    listen 80;

    server_name ${domain} www.${domain};

    location /.well-known/acme-challenge/ {
        root /var/www/certbot/${domain};
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen       443 ssl;
    server_name  ${domain} www.${domain};

    ssl_certificate /etc/nginx/ssl/dummy/${domain}/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/dummy/${domain}/privkey.pem;

    include /etc/nginx/options-ssl-nginx.conf;

    ssl_dhparam /etc/nginx/ssl/ssl-dhparams.pem;

    include /etc/nginx/hsts.conf;

    underscores_in_headers on; 

    location /api/v1 {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        # we don't want nginx trying to do something clever with
        # redirects, we set the Host: header above already.
	proxy_pass_request_headers on;
        proxy_redirect off;
        rewrite ^/api/v1/(.*)$ /$1 break;
        proxy_pass http://api_server;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade"; 
    }
}
