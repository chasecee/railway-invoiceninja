FROM invoiceninja/invoiceninja-debian:5

USER root
RUN apt-get update && apt-get install -y --no-install-recommends nginx && rm -rf /var/lib/apt/lists/*

# Nginx config for Laravel public dir and php-fpm on 127.0.0.1:9000
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
