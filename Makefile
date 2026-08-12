NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml

all: build up

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean: down

fclean: down
	$(COMPOSE) down --rmi all --volumes
	docker system prune -af

re: fclean all

.PHONY: all build up down clean fclean re