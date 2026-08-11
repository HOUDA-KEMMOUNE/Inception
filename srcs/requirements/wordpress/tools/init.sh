#!/bin/bash

set -e

echo "Creating WordPress configuration..."

DB_PASSWORD=$(cat /run/secrets/db_passwd)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_passwd)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_passwd)

AUTH_KEY=$(php -r 'echo bin2hex(random_bytes(32));')
SECURE_AUTH_KEY=$(php -r 'echo bin2hex(random_bytes(32));')
LOGGED_IN_KEY=$(php -r 'echo bin2hex(random_bytes(32));')
NONCE_KEY=$(php -r 'echo bin2hex(random_bytes(32));')

AUTH_SALT=$(php -r 'echo bin2hex(random_bytes(32));')
SECURE_AUTH_SALT=$(php -r 'echo bin2hex(random_bytes(32));')
LOGGED_IN_SALT=$(php -r 'echo bin2hex(random_bytes(32));')
NONCE_SALT=$(php -r 'echo bin2hex(random_bytes(32));')

cat > /var/www/html/wp-config.php <<EOF
<?php

define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', 'mariadb:3306');

define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

define('AUTH_KEY',         '${AUTH_KEY}');
define('SECURE_AUTH_KEY',  '${SECURE_AUTH_KEY}');
define('LOGGED_IN_KEY',    '${LOGGED_IN_KEY}');
define('NONCE_KEY',        '${NONCE_KEY}');
define('AUTH_SALT',        '${AUTH_SALT}');
define('SECURE_AUTH_SALT', '${SECURE_AUTH_SALT}');
define('LOGGED_IN_SALT',   '${LOGGED_IN_SALT}');
define('NONCE_SALT',       '${NONCE_SALT}');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF

chown www-data:www-data /var/www/html/wp-config.php

echo "Waiting for MariaDB..."

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
    sleep 2
done

echo "MariaDB is ready."

if ! wp core is-installed --path=/var/www/html --allow-root; then

    echo "Installing WordPress..."

    wp core install \
        --path=/var/www/html \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating regular WordPress user..."

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=subscriber \
        --allow-root \
        --path=/var/www/html

    echo "WordPress installation completed."

else

    echo "WordPress is already installed."

fi

chown -R www-data:www-data /var/www/html

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
