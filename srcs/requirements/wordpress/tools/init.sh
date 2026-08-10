#!/bin/bash

set -e

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating WordPress configuration..."

    cat > /var/www/html/wp-config.php <<EOF
<?php

define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'mariadb:3306');

EOF

    chown www-data:www-data /var/www/html/wp-config.php
fi

exec php-fpm8.2 -F
