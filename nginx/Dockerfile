FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

# Linking our access.log to $STDOUT
RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log
RUN rm /var/log/nginx/error.log && ln -s /dev/stderr /var/log/nginx/error.log

COPY ./html/ /var/www/html/

CMD ["nginx","-g", "daemon off;"]
