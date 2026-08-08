FROM debian:13

RUN apt update

RUN apt install -y mariadb-server

COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

CMD ["/init.sh"]
