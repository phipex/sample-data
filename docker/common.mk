# I provide common functionality for docker image builds

all: build ## build the docker image

.PHONY: archive
archive: ## push the image to docker registry
	docker push $(IMAGE)

.PHONY: bash
bash: ## start a bash shell in a percona container
	docker run --rm -it $(IMAGE) bash

.PHONY: build
build: setup ## build the docker image
	docker build -t $(IMAGE) .

clean: stop clean_local ## remove all build artifacts
	@if [ "$(docker ps -aq --filter name=$(IMAGE_NAME) 2> /dev/null)" != "" ]; then \
		echo "==> Removing container $(IMAGE_NAME)"; \
		docker rm -v $(IMAGE_NAME); \
	fi
	@if [[ "$(docker images -q $(IMAGE) 2> /dev/null)" != "" ]]; then \
		echo "==> Removing image $(IMAGE)"; \
		docker rmi -f $(IMAGE); \
	fi

help:
	@echo "Use: make [target]\n\ntarget:"
	@grep -h "##" $(MAKEFILE_LIST) | grep -v "(help\|grep)" | grep -ve '^\t' | sort | sed -e "s/:.*## / - /" -e 's/^/  /'

.PHONY: logs
logs: ## show container logs
	docker logs -f $(IMAGE_NAME)

.PHONY: run
run: ## run the docker image
	docker run -d --name $(IMAGE_NAME) $(DOCKER_RUN_ARGS) $(IMAGE)

.PHONY: stop
stop: ## stop the running container
	@if [ "$(docker inspect --format="{{ .State.Running }}" $(IMAGE_NAME) 2> /dev/null)" == "true" ]; then \
		echo "==> Stopping container $(IMAGE_NAME)"; \
		docker stop $(IMAGE_NAME); \
	fi
