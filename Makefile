DATA_DIR = /home/hkemmoun/data
WP_DATA = $(DATA_DIR)/wordpress
DB_DATA = $(DATA_DIR)/mariadb

all: setup
	docker compose -f srcs/docker-compose.yml up -d --build

setup:
	mkdir -p $(WP_DATA) $(DB_DATA)

build:
	docker compose -f srcs/docker-compose.yml build

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down

fclean:
	docker compose -f srcs/docker-compose.yml down -v
	docker rmi -f mariadb:inception nginx:inception wordpress:inception
	sudo rm -rf $(WP_DATA) $(DB_DATA)

re: fclean all

.PHONY: all setup build up down clean fclean re