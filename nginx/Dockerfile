FROM debian:9-slim

RUN apt-get update
RUN apt-get install -y nginx

# Linking our access.log to $STDOUT
RUN rm /var/log/nginx/access.log && ln -s /dev/stdout /var/log/nginx/access.log

CMD ["nginx","-g", "daemon off;"]
