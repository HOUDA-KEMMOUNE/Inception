# Inception - Developer Documentation

## 1. Introduction

This document explains how to set up, build, run and maintain the Inception project from a developer's point of view.

The project is based on Docker and Docker Compose and contains three mandatory services:

- NGINX
- WordPress with PHP-FPM
- MariaDB

Each service is built in its own Docker image and runs in its own container.

The project structure is:

    Inception/
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    └── srcs/
        ├── docker-compose.yml
        └── requirements/
            ├── mariadb/
            │   ├── Dockerfile
            │   ├── config/
            │   │   └── mariadb.cnf
            │   └── tools/
            │       └── init.sh
            │
            ├── nginx/
            │   ├── Dockerfile
            │   ├── config/
            │      └── nginx.conf
            │
            └── wordpress/
                ├── Dockerfile
                ├── config/
                │   └── wordpress.conf
                └── tools/
                    └── init.sh

---

# 2. Prerequisites

The following software is required:

- Linux
- Docker
- Docker Compose
- Make
- Git

Docker must be installed and the current user must have permission to communicate with the Docker daemon.

Check Docker:

    docker --version

Check Docker Compose:

    docker compose version

Check Make:

    make --version

---

# 3. Repository Setup

Clone the repository:

    git clone <repository-url>

Enter the project directory:

    cd Inception

The project should contain:

    Makefile
    README.md
    USER_DOC.md
    DEV_DOC.md
    srcs/

---

# 4. Environment Configuration

Docker Compose uses configuration values from:

    srcs/.env

The `.env` file contains non-secret configuration values required by the project.

Example:

    DOMAIN_NAME=hkemmoun.42.fr

    MYSQL_DATABASE=wordpress
    MYSQL_USER=Spinoza

    WP_TITLE=My WordPress
    WP_ADMIN_USER=admin
    WP_ADMIN_EMAIL=admin@example.com

    WP_USER=user
    WP_USER_EMAIL=user@example.com

Sensitive passwords should not be hard-coded in Dockerfiles or shell scripts.

---

# 5. Secrets

The project uses Docker secrets for sensitive credentials.

Examples include:

    db_passwd
    db_root_passwd
    wp_admin_passwd
    wp_user_passwd

Secrets are made available inside the relevant containers under:

    /run/secrets/

For example:

    /run/secrets/db_passwd

Initialization scripts read the required credentials from these files.

A service should only receive the secrets it actually needs.

For example, NGINX does not need access to MariaDB or WordPress passwords.

---

# 6. Docker Compose

The main orchestration file is:

    srcs/docker-compose.yml

It defines:

- Services.
- Docker images.
- Build contexts.
- Networks.
- Volumes.
- Secrets.
- Port mappings.
- Environment variables.
- Restart policies.
- Service dependencies.

The three main services are:

    nginx
    wordpress
    mariadb

---

# 7. Building the Images

From the project root:

    make build

Or directly:

    docker compose -f srcs/docker-compose.yml build

The build creates separate images for the three services.

For example:

    srcs-nginx
    srcs-wordpress
    srcs-mariadb

To rebuild an image after changing its Dockerfile:

    docker compose -f srcs/docker-compose.yml build nginx

or:

    docker compose -f srcs/docker-compose.yml build wordpress

or:

    docker compose -f srcs/docker-compose.yml build mariadb

---

# 8. Starting the Project

Build and start the complete infrastructure:

    make

Or:

    docker compose -f srcs/docker-compose.yml up -d

The `-d` option runs the containers in detached mode.

Check the result:

    docker compose -f srcs/docker-compose.yml ps

---

# 9. Stopping the Project

Stop and remove the containers and Docker network:

    make down

Or:

    docker compose -f srcs/docker-compose.yml down

Persistent data should remain available through the configured persistent storage.

---

# 10. Rebuilding the Project

After changing Dockerfiles or configuration:

    make re

Alternatively:

    docker compose -f srcs/docker-compose.yml down
    docker compose -f srcs/docker-compose.yml build
    docker compose -f srcs/docker-compose.yml up -d

Be careful when removing volumes because volumes contain persistent application data.

---

# 11. Managing Containers

List running containers:

    docker ps

List all containers:

    docker ps -a

List Compose services:

    docker compose -f srcs/docker-compose.yml ps

Restart a service:

    docker compose -f srcs/docker-compose.yml restart nginx

For example:

    docker compose -f srcs/docker-compose.yml restart wordpress

---

# 12. Accessing Containers

A shell can be opened inside a running service using:

    docker compose -f srcs/docker-compose.yml exec <service> bash

For example:

    docker compose -f srcs/docker-compose.yml exec nginx bash

or:

    docker compose -f srcs/docker-compose.yml exec wordpress bash

or:

    docker compose -f srcs/docker-compose.yml exec mariadb bash

---

# 13. Logs

Display all logs:

    docker compose -f srcs/docker-compose.yml logs

Follow the logs in real time:

    docker compose -f srcs/docker-compose.yml logs -f

Display the logs of one service:

    docker compose -f srcs/docker-compose.yml logs nginx

    docker compose -f srcs/docker-compose.yml logs wordpress

    docker compose -f srcs/docker-compose.yml logs mariadb

---

# 14. Docker Network

The services communicate through a dedicated Docker network.

The network allows containers to communicate using their service names.

For example:

    nginx -> wordpress:9000

and:

    wordpress -> mariadb:3306

Docker provides internal DNS resolution for services connected to the same network.

To inspect the network:

    docker network ls

Then:

    docker network inspect srcs_inception

The exact network name may depend on the Compose project name.

---

# 15. NGINX Configuration

The NGINX configuration is located at:

    srcs/requirements/nginx/config/nginx.conf

NGINX:

- Listens on HTTPS port 443.
- Uses TLS.
- Serves the WordPress files.
- Forwards PHP requests to WordPress/PHP-FPM.

PHP requests are sent to:

    wordpress:9000

The service name `wordpress` is resolved by Docker's internal DNS.

Test the NGINX configuration:

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

---

# 16. WordPress and PHP-FPM

WordPress is installed inside the WordPress image.

PHP-FPM is used to execute PHP scripts.

PHP-FPM listens on:

    9000

inside the WordPress container.

This port is not exposed to the host.

NGINX communicates with it through the Docker network:

    nginx
       |
       | wordpress:9000
       v
    WordPress/PHP-FPM

The WordPress initialization script is located at:

    srcs/requirements/wordpress/tools/init.sh

It is responsible for tasks such as:

- Creating the WordPress configuration.
- Waiting for MariaDB.
- Installing WordPress if necessary.
- Creating the required WordPress user.
- Starting PHP-FPM.

---

# 17. MariaDB

The MariaDB Dockerfile is located at:

    srcs/requirements/mariadb/Dockerfile

The MariaDB configuration is located at:

    srcs/requirements/mariadb/config/mariadb.cnf

The initialization script is:

    srcs/requirements/mariadb/tools/init.sh

MariaDB listens on:

    3306

inside the Docker network.

It is not directly exposed to the host.

WordPress connects to MariaDB using:

    mariadb:3306

---

# 18. Persistent Data

Persistent application data is stored outside the container's temporary filesystem.

The main data locations are:

    /home/hkemmoun/data/wordpress
    /home/hkemmoun/data/mariadb

These correspond to the application data directories:

    WordPress:
    /var/www/html

    MariaDB:
    /var/lib/mysql

The purpose of persistent storage is to prevent data loss when containers are recreated.

For example:

    docker compose down

followed by:

    docker compose up -d

should not remove the WordPress and MariaDB data.

---

# 19. Volumes

To inspect Docker volumes:

    docker volume ls

To inspect a specific volume:

    docker volume inspect <volume-name>

Volumes should not be removed during normal development unless the intention is to delete the stored application data.

---

# 20. Debugging

## Check all services

    docker compose -f srcs/docker-compose.yml ps -a

## Check NGINX logs

    docker compose -f srcs/docker-compose.yml logs nginx

## Check WordPress logs

    docker compose -f srcs/docker-compose.yml logs wordpress

## Check MariaDB logs

    docker compose -f srcs/docker-compose.yml logs mariadb

## Test NGINX configuration

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

## Check the Docker network

    docker network ls

    docker network inspect srcs_inception

## Check DNS resolution from a container

For example:

    docker compose -f srcs/docker-compose.yml exec nginx getent hosts wordpress

A result similar to:

    172.x.x.x wordpress

shows that Docker's internal DNS can resolve the WordPress service.

---

# 21. Rebuilding After Changes

When modifying a Dockerfile:

    make build

When modifying an NGINX configuration copied during the image build:

    make build

When modifying an initialization script copied during the image build:

    make build

Then recreate the relevant service:

    docker compose -f srcs/docker-compose.yml up -d --force-recreate <service>

For example:

    docker compose -f srcs/docker-compose.yml up -d --force-recreate nginx

---

# 22. Important Development Rules

## Do not hard-code passwords

Passwords must not be placed directly inside:

- Dockerfiles.
- Docker Compose configuration.
- Initialization scripts.
- Source code.

Use the configured secrets mechanism.

## Do not expose internal services unnecessarily

Only NGINX should be exposed publicly.

WordPress/PHP-FPM and MariaDB communicate through the Docker network.

## Do not delete persistent storage unnecessarily

Removing the MariaDB or WordPress persistent data can result in loss of application data.

---

# 23. Service Communication

The final communication architecture is:

                  Internet
                     |
                     | HTTPS :443
                     v
                  NGINX
                     |
                     | wordpress:9000
                     v
              WordPress/PHP-FPM
                     |
                     | mariadb:3306
                     v
                  MariaDB

The service names are resolved through Docker's internal DNS.

The services do not need to know each other's dynamically assigned container IP addresses.

---

# 24. Makefile

The Makefile provides shortcuts for common Docker Compose operations.

Typical commands include:

    make
    make build
    make down
    make re

The exact available targets can be displayed by reading:

    Makefile

The Makefile ultimately calls Docker Compose commands to build, start and stop the infrastructure.

---

# 25. Development Workflow

A typical development workflow is:

    1. Modify the source/configuration.
    2. Rebuild the affected image.
    3. Recreate the affected container.
    4. Check the service status.
    5. Check the logs.
    6. Test the service.
    7. Test the complete stack.

For example, after modifying NGINX:

    make build

    docker compose -f srcs/docker-compose.yml up -d --force-recreate nginx

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

    docker compose -f srcs/docker-compose.yml logs nginx

---

# 26. Data Persistence

The project separates application containers from persistent application data.

Containers are considered replaceable.

Persistent data is stored separately so that recreating a container does not automatically destroy:

- WordPress files.
- WordPress configuration.
- MariaDB databases.
- MariaDB tables.

The important persistent locations are:

    /home/hkemmoun/data/wordpress
    /home/hkemmoun/data/mariadb

---

# 27. Summary

The project is composed of three isolated Docker services:

    NGINX
    WordPress
    MariaDB

Docker Compose orchestrates these services.

The services communicate through a dedicated Docker network.

Docker's internal DNS allows:

    wordpress

and:

    mariadb

to be used as service hostnames.

NGINX is the only publicly exposed service.

WordPress and MariaDB communicate internally.

Sensitive credentials are provided through Docker secrets.

Persistent WordPress and MariaDB data is stored outside the temporary container filesystem.

The Makefile provides convenient commands for building, starting, stopping and rebuilding the infrastructure.