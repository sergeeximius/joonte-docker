APP_NAME="ssedov/jbs"
TAG ?= latest
BUILD_DATE := $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
REPO_URL := https://api.github.com/repos/joonte/jbs/commits/master
CURRENT_COMMIT := $(shell curl -s $(REPO_URL) | grep '"sha"' | head -1 | cut -d'"' -f4)
SHORT_COMMIT_SHA := $(shell echo $(CURRENT_COMMIT) | cut -c1-7)
JOONTE_VERSION := $(shell curl -s https://joonte.com/public/version | awk -F'"' '/version/{print $$4}' | sed 's/^v//')

# HELP
# This will output the help for each task
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build: ## Build the container image with tag (e.g. make build TAG=latest)
	@docker buildx create --name multi-arch --driver docker-container --use
	@docker buildx inspect --bootstrap
	@docker buildx build --platform linux/amd64,linux/arm64 -t $(APP_NAME):$(TAG) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg JOONTE_VERSION=$(JOONTE_VERSION) --pull --push docker
	@docker buildx rm multi-arch

build-latest: TAG=latest
build-latest: build ## Build the image with the 'latest' tag

build-versioned: ## Build the image with versioned tag including commit hash
	@if [ -z "$(CURRENT_COMMIT)" ]; then echo "Failed to get current commit SHA from GitHub API"; exit 1; fi
	@if [ -z "$(JOONTE_VERSION)" ]; then echo "Failed to get Joonte version from API"; exit 1; fi
	$(MAKE) build TAG=$(JOONTE_VERSION)-$(SHORT_COMMIT_SHA)

pull-versioned: ## Pull the versioned image from Docker Hub
	@if [ -z "$(CURRENT_COMMIT)" ]; then echo "Failed to get current commit SHA from GitHub API"; exit 1; fi
	@if [ -z "$(JOONTE_VERSION)" ]; then echo "Failed to get Joonte version from API"; exit 1; fi
	docker pull $(APP_NAME):$(JOONTE_VERSION)-$(SHORT_COMMIT_SHA)

shell: ## Creates a shell inside the container for debug purposes
	@docker run -it $(APP_NAME):$(TAG) bash
