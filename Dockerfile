FROM invoiceninja/invoiceninja-debian:5

USER root
RUN apt-get update && apt-get install -y --no-install-recommends nginx && rm -rf /var/lib/apt/lists/*

# Nginx config for Laravel public dir and php-fpm on 127.0.0.1:9000
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord-nginx.conf /etc/supervisor/conf.d/nginx.conf

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
