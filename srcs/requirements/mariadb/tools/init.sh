#!/bin/bash

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Start MariaDB temporarily
mysqld --user=mysql --skip-networking &

# Wait until MariaDB is ready
until mariadb -u root -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 1
done

# Check if the WordPress database already exists
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    echo "Initializing MariaDB..."

    mariadb -u root <<EOF
CREATE DATABASE ${MYSQL_DATABASE};

CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES
ON ${MYSQL_DATABASE}.*
TO '${MYSQL_USER}'@'%';
EOF

else

    echo "Database already exists."

fi

# Stop temporary MariaDB
mysqladmin -u root shutdown

# Start MariaDB normally
exec mysqld --user=mysql