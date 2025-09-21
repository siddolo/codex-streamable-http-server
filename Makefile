.PHONY: build
build:
	@echo "Building Docker images with docker compose"
	docker compose build

IMAGE_NAME ?= codex-streamable-http-server

.PHONY: clean
clean:
	@echo "Removing containers, images, and volumes created by docker compose"
	docker compose down --volumes --remove-orphans
	@leftover_containers=$$(docker ps -aq --filter ancestor=$(IMAGE_NAME):latest); \
		if [ -n "$$leftover_containers" ]; then \
			echo "Removing containers still using $(IMAGE_NAME):latest"; \
			docker rm -f $$leftover_containers; \
		fi
	@if docker image inspect $(IMAGE_NAME):latest >/dev/null 2>&1; then \
		echo "Removing image $(IMAGE_NAME):latest"; \
		docker rmi $(IMAGE_NAME):latest >/dev/null 2>&1 || true; \
	fi

.PHONY: all
all: build

.PHONY: run
run:
	@echo "Starting services with docker compose"
	docker compose up

.PHONY: login
login:
	@echo "Starting temporary privileged container for 'codex login'"
	docker compose -f docker-compose-login.yml up

.PHONY: logout
logout:
	@echo "Running 'codex logout' inside $(IMAGE_NAME) container"
	docker compose run --rm $(IMAGE_NAME) codex logout
