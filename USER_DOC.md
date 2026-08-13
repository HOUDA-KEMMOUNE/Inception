# Inception - User Documentation

## 1. Introduction

This document explains how to use and administer the Inception infrastructure.

The project provides a WordPress website composed of three main services:

- NGINX
- WordPress with PHP-FPM
- MariaDB

The services run in separate Docker containers and communicate through a dedicated Docker network.

The general architecture is:

    Internet
       |
       | HTTPS :443
       v
    NGINX
       |
       | FastCGI :9000
       v
    WordPress / PHP-FPM
       |
       | MariaDB :3306
       v
    MariaDB

NGINX is the only service exposed to the host.

---

# 2. Services Provided by the Stack

## NGINX

NGINX is the web server and the entry point of the application.

It:

- Accepts HTTPS connections on port 443.
- Uses TLS for encrypted communication.
- Serves the WordPress website.
- Sends PHP requests to WordPress/PHP-FPM.

The website can be accessed through:

    https://hkemmoun.42.fr

---

## WordPress

WordPress is the content management system used by the project.

It provides:

- The website.
- The WordPress administration interface.
- User management.
- Posts and pages.
- Themes and plugins.

WordPress uses PHP-FPM to execute PHP code.

---

## MariaDB

MariaDB is the database server used by WordPress.

It stores WordPress data such as:

- Users.
- Posts.
- Pages.
- Website settings.
- Comments.
- Metadata.

MariaDB is not directly exposed to the host.

It can only be accessed by services connected to the Docker network.

---

# 3. Starting the Project

Go to the root of the repository:

    cd ~/Inception

Start the complete infrastructure with:

    make

Alternatively, Docker Compose can be used directly:

    docker compose -f srcs/docker-compose.yml up -d

After starting the project, check the containers:

    docker compose -f srcs/docker-compose.yml ps

The three services should be running:

    nginx
    wordpress
    mariadb

---

# 4. Stopping the Project

To stop the infrastructure:

    make down

Or:

    docker compose -f srcs/docker-compose.yml down

Stopping the containers does not necessarily remove the persistent WordPress and MariaDB data.

---

# 5. Restarting the Project

The complete stack can be restarted with:

    docker compose -f srcs/docker-compose.yml restart

Alternatively, the project can be stopped and started again:

    make down
    make

---

# 6. Accessing the Website

Open a web browser and go to:

    https://hkemmoun.42.fr

The website is served through HTTPS.

Because the project uses a local/self-signed TLS certificate, the browser may display a security warning.

This is expected in a local development environment.

---

# 7. Accessing the WordPress Administration Panel

The WordPress administration panel is available at:

    https://hkemmoun.42.fr/wp-admin/

Use the WordPress administrator credentials configured for the project.

The administration panel allows you to:

- Create and edit posts.
- Create pages.
- Manage users.
- Change the website settings.
- Install and manage themes.
- Manage plugins.
- Configure the WordPress website.

---

# 8. Credentials

Sensitive credentials are not intended to be hard-coded inside the application source code.

The project uses Docker secrets for sensitive information.

Inside the appropriate containers, secrets are available under:

    /run/secrets/

Examples include:

    /run/secrets/db_passwd
    /run/secrets/db_root_passwd
    /run/secrets/wp_admin_passwd
    /run/secrets/wp_user_passwd

The exact credentials should not be displayed or committed publicly.

The WordPress administrator credentials are the credentials configured when the project is initialized.

---

# 9. Checking That the Services Are Running

Use:

    docker compose -f srcs/docker-compose.yml ps

A healthy stack should show:

    nginx       Up
    wordpress   Up
    mariadb     Up

For more information, check the logs.

### NGINX

    docker compose -f srcs/docker-compose.yml logs nginx

### WordPress

    docker compose -f srcs/docker-compose.yml logs wordpress

### MariaDB

    docker compose -f srcs/docker-compose.yml logs mariadb

---

# 10. Checking NGINX

The NGINX configuration can be tested with:

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

A successful result should contain:

    syntax is ok
    test is successful

---

# 11. Checking WordPress

Check whether WordPress is running:

    docker compose -f srcs/docker-compose.yml ps wordpress

The WordPress logs can be viewed with:

    docker compose -f srcs/docker-compose.yml logs wordpress

PHP-FPM listens on port 9000 inside the Docker network.

It is not directly exposed to the host.

---

# 12. Checking MariaDB

Check the MariaDB container:

    docker compose -f srcs/docker-compose.yml ps mariadb

View its logs:

    docker compose -f srcs/docker-compose.yml logs mariadb

MariaDB listens on port 3306 inside the Docker network.

It is not directly exposed to the host.

---

# 13. Persistent Data

The project uses persistent storage for important data.

WordPress data is stored in:

    /home/hkemmoun/data/wordpress

MariaDB data is stored in:

    /home/hkemmoun/data/mariadb

The container paths are:

    WordPress:
    /var/www/html

    MariaDB:
    /var/lib/mysql

This allows important data to survive container recreation.

For example, removing and recreating the WordPress container should not remove the WordPress database or website files stored in persistent storage.

---

# 14. Troubleshooting

## Containers are not running

Check:

    docker compose -f srcs/docker-compose.yml ps -a

Then check the logs:

    docker compose -f srcs/docker-compose.yml logs

---

## NGINX is not starting

Check:

    docker compose -f srcs/docker-compose.yml logs nginx

Then test the configuration:

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

---

## WordPress cannot connect to MariaDB

Check that MariaDB is running:

    docker compose -f srcs/docker-compose.yml ps mariadb

Then check the MariaDB logs:

    docker compose -f srcs/docker-compose.yml logs mariadb

Also verify that WordPress and MariaDB are connected to the same Docker network.

---

## Website cannot be accessed

Check:

    docker compose -f srcs/docker-compose.yml ps

NGINX must be running and port 443 must be published.

You can also test HTTPS from the command line:

    curl -k -I https://localhost

---

# 15. Important Commands

### Display running containers

    docker ps

### Display all containers

    docker ps -a

### Display Docker Compose services

    docker compose -f srcs/docker-compose.yml ps

### Display logs

    docker compose -f srcs/docker-compose.yml logs

### Stop the project

    make down

### Start the project

    make

### Enter a running container

    docker compose -f srcs/docker-compose.yml exec <service> bash

For example:

    docker compose -f srcs/docker-compose.yml exec wordpress bash

---

# 16. Summary

The Inception stack provides:

    NGINX
       |
       | HTTPS
       v
    WordPress
       |
       | MariaDB
       v
    MariaDB

NGINX is the public entry point.

WordPress provides the website.

MariaDB stores the WordPress database.

Docker isolates the services while allowing them to communicate through a dedicated Docker network.

Persistent storage ensures that important data remains available when containers are recreated.