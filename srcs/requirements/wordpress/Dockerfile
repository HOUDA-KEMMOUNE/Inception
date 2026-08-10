FROM debian:12

RUN apt update

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
RUN chown -R www-data:www-data /var/www/html

COPY config/wordpress.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

CMD ["/init.sh"]
