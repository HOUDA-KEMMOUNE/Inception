FROM debian:bookworm-slim

RUN apt update
RUN apt install -y mariadb-server

COPY config/mariadb.cnf /etc/mysql/mariadb.conf.d/my.cnf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

CMD ["/init.sh"]
