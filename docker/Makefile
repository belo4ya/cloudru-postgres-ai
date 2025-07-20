IMAGE_NAME  ?= belo4ya/cnpg-postgresql
BASE_TAG    ?= 16.9-bookworm-ai
GIT_SHA     ?= $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE  ?= $(shell date -u +%Y%m%d-%H%M%S)

#IMAGE_TAG   = $(BASE_TAG)-$(GIT_SHA)-$(BUILD_DATE)
IMAGE_TAG   ?= $(BASE_TAG)

DOCKERFILE  ?= bookworm.Dockerfile
PLATFORMS   ?= linux/amd64,linux/arm64
IMAGE       ?= $(IMAGE_NAME):$(IMAGE_TAG)
CACHE_IMAGE ?= $(IMAGE)-buildcache

BUILD_ARGS  ?=
BUILD_FLAGS = -f $(DOCKERFILE) $(BUILD_ARGS)

.PHONY: all
all: build

.PHONY: build
build:
	docker build $(BUILD_FLAGS) -t $(IMAGE) .

.PHONY: release
release:
	docker buildx build $(BUILD_FLAGS) \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE) \
	  --push \
	  --cache-from=type=registry,ref=$(CACHE_IMAGE) \
	  --cache-to=type=registry,ref=$(CACHE_IMAGE),mode=max .

.PHONY: nocache-release
nocache-release:
	docker buildx build $(BUILD_FLAGS) \
	  --no-cache \
	  --platform $(PLATFORMS) \
	  -t $(IMAGE) \
	  --push \
	  --cache-to=type=registry,ref=$(CACHE_IMAGE),mode=max .

.PHONY: builder
builder:
	docker buildx inspect multi >/dev/null 2>&1 || docker buildx create --name multi --driver docker-container --use
	docker buildx inspect --bootstrap >/dev/null

.PHONY: rm-builder
rm-builder:
	docker buildx rm multi
