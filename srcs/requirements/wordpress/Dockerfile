FROM debian:bookworm-slim

RUN apt update && apt install -y mariadb-client

RUN apt install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip

RUN apt install -y curl tar

RUN curl -O https://wordpress.org/latest.tar.gz
RUN tar -xzf latest.tar.gz
RUN mkdir -p /var/www/html
RUN mv wordpress/* /var/www/html/
RUN rm -rf wordpress
RUN rm -rf latest.tar.gz
RUN chown -R www-data:www-data /var/www/html
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY config/wordpress.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]

# FROM debian:bookworm-slim

# RUN apt-get update && apt-get install -y   php-fpm \
#     php-mysql \
#     mariadb-client \
#     curl \
#     && rm -rf /var/lib/apt/lists/*

# RUN  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
#     && chmod +x wp-cli.phar \
#     && mv wp-cli.phar /usr/local/bin/wp   

# RUN mkdir -p /var/www/html

# COPY config/wordpress.conf /etc/php/8.2/fpm/pool.d/www.conf
# COPY tools/init.sh /init.sh

# RUN chmod +x /init.sh

# EXPOSE 9000

# ENTRYPOINT ["./init.sh"]