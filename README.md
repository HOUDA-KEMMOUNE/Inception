*This project has been created as part of the 42 curriculum by hkemmoun.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum.

The goal of this project is to build a small infrastructure using Docker and Docker Compose. The infrastructure is composed of several services running in separate Docker containers and communicating through a dedicated Docker network.

The mandatory infrastructure contains three services:

- **NGINX**: acts as the web server and the only public entry point. It handles HTTPS connections using TLS.
- **WordPress**: provides the website and runs through PHP-FPM.
- **MariaDB**: provides the database used by WordPress.

The architecture follows the principle of separating each service into its own container.

The final communication flow is:

    Client
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

The containers communicate through a dedicated Docker network.

Only NGINX exposes a port to the host:

    443:443

MariaDB and WordPress are not directly exposed to the host.

The project also uses persistent storage for WordPress and MariaDB so that data is preserved when containers are stopped, removed and recreated.

---

# Project Description

## Use of Docker

Docker is used to containerize the different services of the infrastructure.

Instead of installing NGINX, WordPress, PHP-FPM and MariaDB directly on the host machine, each service is placed in its own container.

This provides:

- Isolation between services.
- Reproducible environments.
- Independent configuration for each service.
- Easier deployment and management.
- Separation of responsibilities.
- A dedicated network between the services.

Each mandatory service has its own Dockerfile:

    srcs/requirements/nginx/Dockerfile
    srcs/requirements/wordpress/Dockerfile
    srcs/requirements/mariadb/Dockerfile

Docker Compose is then used to create and manage the complete infrastructure.

---

## Main Design Choices

The project follows several important design choices:

### 1. One service per container

Each service has its own container:

    NGINX
    WordPress
    MariaDB

This avoids putting several unrelated services inside the same container.

### 2. NGINX as the only public entry point

Only NGINX exposes a port to the host:

    443:443

NGINX receives HTTPS requests and forwards PHP requests to WordPress/PHP-FPM.

MariaDB and PHP-FPM remain accessible only through the Docker network.

### 3. HTTPS

The website is served through HTTPS using TLS.

The NGINX configuration enables:

    TLSv1.2
    TLSv1.3

A certificate and private key are used by NGINX to establish HTTPS connections.

### 4. Persistent data

WordPress and MariaDB require persistent storage.

The project therefore uses persistent volumes for:

    /var/www/html

and:

    /var/lib/mysql

The data is stored under:

    /home/hkemmoun/data/

This allows the data to survive container recreation and system reboots.

### 5. Dedicated Docker network

The three services communicate through a dedicated Docker network:

    srcs_inception

Docker's internal DNS allows services to communicate using their service names.

For example:

    wordpress -> mariadb:3306

and:

    nginx -> wordpress:9000

---

# Virtual Machines vs Docker

## Virtual Machines

A Virtual Machine emulates a complete computer and runs its own operating system.

For example:

    Host OS
       |
       +-- Virtual Machine
              |
              +-- Guest OS
                    |
                    +-- Applications

Each virtual machine contains its own operating system, libraries and applications.

This provides strong isolation but requires more resources such as RAM, CPU and disk space.

## Docker

Docker containers share the host operating system kernel while isolating applications and their dependencies.

For this project:

    Host OS
       |
       +-- Docker Engine
              |
              +-- NGINX container
              |
              +-- WordPress container
              |
              +-- MariaDB container

Containers are generally lighter than virtual machines because they do not need a complete guest operating system.

## Comparison

| Virtual Machines | Docker |
|---|---|
| Runs a complete guest OS | Shares the host kernel |
| Usually heavier | Usually lightweight |
| Requires more resources | Uses fewer resources |
| Slower startup | Fast startup |
| Strong OS-level isolation | Application/process isolation |
| Each VM has its own OS | Containers share the host kernel |

For Inception, Docker is more appropriate because we need several isolated services without running a complete operating system for each one.

---

# Secrets vs Environment Variables

## Environment Variables

Environment variables are useful for configuration values that services need.

Examples include:

    DOMAIN_NAME
    MYSQL_DATABASE
    MYSQL_USER
    WP_TITLE
    WP_ADMIN_USER

They are convenient because Docker Compose can read them from the `.env` file.

For example:

    MYSQL_DATABASE=wordpress

can be used in `docker-compose.yml` as:

    MYSQL_DATABASE: ${MYSQL_DATABASE}

However, environment variables are not the ideal mechanism for sensitive information such as passwords.

## Docker Secrets

Docker secrets are intended for sensitive information such as:

- Database passwords.
- MariaDB root passwords.
- WordPress administrator passwords.
- WordPress user passwords.

Inside the container, a Docker secret can be exposed as a file under:

    /run/secrets/

For example:

    /run/secrets/db_passwd

The password can then be read by the initialization script when required.

## Comparison

| Environment Variables | Docker Secrets |
|---|---|
| Mainly used for configuration | Designed for sensitive information |
| Easy to use | Better suited for credentials |
| Values are provided as environment data | Secrets are exposed as files |
| Suitable for non-sensitive settings | Suitable for passwords and credentials |

In this project, environment variables are used for general configuration while secrets are used for sensitive credentials.

---

# Docker Network vs Host Network

## Docker Network

The project uses a dedicated Docker network:

    srcs_inception

The containers communicate through this network.

For example:

    nginx
      |
      | wordpress:9000
      v
    wordpress

and:

    wordpress
      |
      | mariadb:3306
      v
    mariadb

Docker provides internal DNS, so containers can communicate using service names instead of manually configured IP addresses.

## Host Network

With host networking, a container directly uses the host's network stack.

The container does not get the same network isolation provided by a normal Docker bridge network.

This can also create port conflicts with services already running on the host.

## Comparison

| Docker Network | Host Network |
|---|---|
| Provides network isolation | Uses the host network stack |
| Containers communicate through service names | Containers use host networking |
| Services can communicate privately | Less network isolation |
| Ports can be explicitly published | Containers share host network interfaces |
| Used in this project | Not used in this project |

The project deliberately uses a dedicated Docker network rather than host networking.

---

# Docker Volumes vs Bind Mounts

## Docker Volumes

A Docker volume is managed by Docker and is used to persist data independently from a container.

For example:

    mariadb_data
    wordpress_data

The data can remain available when a container is removed and recreated.

## Bind Mounts

A bind mount directly maps a directory from the host filesystem into a container.

In this project, persistent storage is mapped to host directories under:

    /home/hkemmoun/data/

For example:

    /home/hkemmoun/data/mariadb
            |
            v
    /var/lib/mysql

and:

    /home/hkemmoun/data/wordpress
            |
            v
    /var/www/html

## Comparison

| Docker Volumes | Bind Mounts |
|---|---|
| Managed by Docker | Managed directly by the host |
| Docker manages the storage location | User specifies the host path |
| Provides a Docker-managed storage abstraction | Direct access to host filesystem |
| Useful for persistent application data | Useful when a specific host directory is required |

For this project, persistent data is stored in host directories under `/home/hkemmoun/data/` through the configured Docker volume mechanism.

---

# Instructions

## Requirements

To run this project, the following are required:

- Docker
- Docker Compose
- Linux environment
- Permission to use Docker
- A configured `.env` file
- The required Docker secrets

The project is designed to run with the following domain:

    hkemmoun.42.fr

The domain must resolve to the machine running the NGINX container.

---

## Configuration

The `.env` file contains the general configuration used by Docker Compose.

Example:

    DOMAIN_NAME=hkemmoun.42.fr

    MYSQL_DATABASE=wordpress
    MYSQL_USER=Spinoza

    WP_TITLE=My WordPress
    WP_ADMIN_USER=Houda
    WP_ADMIN_EMAIL=houda@gmail.com

    WP_USER=user
    WP_USER_EMAIL=user@gmail.com

Sensitive passwords should be handled using Docker secrets and should not be hard-coded inside Dockerfiles or initialization scripts.

---

## Build the Project

From the root of the repository:

    make build

This builds the Docker images for:

    mariadb
    wordpress
    nginx

The equivalent Docker Compose command is:

    docker compose -f srcs/docker-compose.yml build

---

## Start the Infrastructure

To build and start the infrastructure:

    make

Or:

    docker compose -f srcs/docker-compose.yml up -d

The three services should be running:

    mariadb
    wordpress
    nginx

---

## Check the Containers

Use:

    docker compose -f srcs/docker-compose.yml ps

To display all containers, including stopped ones:

    docker compose -f srcs/docker-compose.yml ps -a

---

## Check Logs

To display all logs:

    docker compose -f srcs/docker-compose.yml logs

To display the logs of a specific service:

    docker compose -f srcs/docker-compose.yml logs nginx

or:

    docker compose -f srcs/docker-compose.yml logs wordpress

or:

    docker compose -f srcs/docker-compose.yml logs mariadb

---

## Test NGINX

The NGINX configuration can be tested with:

    docker compose -f srcs/docker-compose.yml exec nginx nginx -t

A successful test should report:

    syntax is ok
    test is successful

---

## Access WordPress

Once the infrastructure is running, access:

    https://hkemmoun.42.fr

The website is served through HTTPS on port 443.

Because the project uses a self-signed certificate for the local environment, the browser may display a certificate warning.

---

## Stop the Infrastructure

To stop and remove the containers and Docker network:

    make down

or:

    docker compose -f srcs/docker-compose.yml down

The persistent WordPress and MariaDB data should remain available.

---

## Rebuild the Infrastructure

To rebuild the images:

    make build

To rebuild and restart the complete project:

    make re

Commands that remove Docker volumes should be used carefully because the volumes contain persistent WordPress and MariaDB data.

---

# Resources

The following resources were used to learn and implement the project.

## Docker

Docker Documentation:

https://docs.docker.com/

Docker Compose Documentation:

https://docs.docker.com/compose/

Docker Networking:

https://docs.docker.com/engine/network/

Docker Volumes:

https://docs.docker.com/engine/storage/volumes/

Docker Secrets:

https://docs.docker.com/engine/swarm/secrets/

## NGINX

NGINX Documentation:

https://nginx.org/en/docs/

## WordPress

WordPress Documentation:

https://wordpress.org/documentation/

WP-CLI Documentation:

https://make.wordpress.org/cli/handbook/

## MariaDB

MariaDB Documentation:

https://mariadb.com/docs/

## PHP

PHP Documentation:

https://www.php.net/docs.php

PHP-FPM Documentation:

https://www.php.net/manual/en/install.fpm.php

## HTTPS / TLS

MDN HTTPS Documentation:

https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/HTTPS

---

# AI Usage

AI tools were used as a learning and development assistant during the project.

AI was used for:

- Understanding Docker and Docker Compose concepts.
- Understanding how Docker networks allow containers to communicate.
- Understanding Docker volumes and persistent storage.
- Understanding Docker secrets and environment variables.
- Understanding HTTPS, TLS certificates, public keys and private keys.
- Understanding NGINX configuration.
- Understanding the communication between NGINX and PHP-FPM.
- Understanding WordPress and WP-CLI.
- Understanding MariaDB users, privileges and database connections.
- Debugging Docker Compose and container errors.
- Explaining Docker commands and their options.
- Reviewing configuration files and initialization scripts.

AI was mainly used to explain concepts, investigate errors and assist during development. The configuration, Dockerfiles and scripts were tested and adapted as part of the project work, and the implementation must be understood and explainable during the project evaluation.