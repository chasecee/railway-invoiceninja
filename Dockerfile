FROM invoiceninja/invoiceninja-debian:5

USER root

# Nginx config for Laravel public dir and php-fpm on 127.0.0.1:9000
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
