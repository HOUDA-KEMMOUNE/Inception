#!/bin/bash

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

DB_PASSWORD=$(cat /run/secrets/db_passwd)

mysqld --user=mysql --skip-networking &

until mariadb -u root -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 1
done

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    echo "Initializing MariaDB..."

    mariadb -u root <<EOF
CREATE DATABASE ${MYSQL_DATABASE};

CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES
ON ${MYSQL_DATABASE}.*
TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

else

    echo "Database already exists."

fi

mysqladmin -u root shutdown

exec mysqld --user=mysql