FROM debian:Bookworm

RUN apt update && apt install -y ngnix

COPY config/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]
