IMAGE_NAME ?= belo4ya/cnpg-postgresql
PLATFORMS  ?= linux/amd64,linux/arm64
PUSH       ?= true

PUSH_FLAG = $(if $(filter true,$(PUSH)),--push,)

all:
	docker buildx bake all --load $(PUSH_FLAG)

pg15 pg16 pg17:
	docker buildx bake $@ --load $(PUSH_FLAG)

.PHONY: builder
builder:
	docker buildx inspect multi >/dev/null 2>&1 || docker buildx create --name multi --driver docker-container --use
	docker buildx inspect --bootstrap >/dev/null

.PHONY: rm-builder
rm-builder:
	docker buildx rm multi

#=======================================================================================================================
#=======================================================================================================================

IMAGE_NAME  ?= belo4ya/cnpg-postgresql
BASE_TAG    ?= 16.9-bookworm-ai
GIT_SHA     ?= $(shell git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)
BUILD_DATE  ?= $(shell date -u +%Y%m%d-%H%M%S)

#IMAGE_TAG   = $(BASE_TAG)-$(GIT_SHA)-$(BUILD_DATE)
IMAGE_TAG   ?= $(BASE_TAG)

DOCKERFILE  ?= bookworm.Dockerfile
IMAGE       ?= $(IMAGE_NAME):$(IMAGE_TAG)

BUILD_ARGS  ?=
BUILD_FLAGS = -f $(DOCKERFILE) $(BUILD_ARGS)

.PHONY: build
build:
	docker build $(BUILD_FLAGS) -t $(IMAGE) .
