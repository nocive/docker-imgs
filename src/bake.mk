SRC_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
BAKE_OPTS ?=
UNAME_SM = $(shell uname -sm)

ifeq ($(UNAME_SM),Linux x86_64)
LOCAL_ARCH = linux/amd64
else ifeq ($(UNAME_SM),Linux aarch64)
LOCAL_ARCH = linux/arm64
else
$(error Unsupported architecture)
endif

ifeq ($(BAKE_CHECK),1)
BAKE_OPTS += --check
endif

.PHONY: all
all: clean build-local manifest

.PHONY: check
check:
	BAKE_CHECK=1 $(MAKE) build-local

.PHONY: build-all
build-all:
	docker buildx bake \
		-f docker-bake.hcl \
		--metadata-file .bake_build_all.json \
		--provenance=true \
		--sbom=true \
		--set '*.output=type=image,push=true' \
		$(BAKE_OPTS) \
		all

.PHONY: build-local
build-local: build-$(LOCAL_ARCH)

.PHONY: ci-linux/amd64
build-linux/amd64:
	docker buildx bake \
		-f docker-bake.hcl \
		--metadata-file .bake_build_amd64.json \
		--provenance=true \
		--sbom=true \
		--set '*.platform=linux/amd64' \
		--set '*.output=type=image,push-by-digest=true,name-canonical=true,push=true' \
		$(BAKE_OPTS)

.PHONY: ci-linux/arm64
build-linux/arm64:
	docker buildx bake \
		-f docker-bake.hcl \
		--metadata-file .bake_build_arm64.json \
		--provenance=true \
		--sbom=true \
		--set '*.platform=linux/arm64' \
		--set '*.output=type=image,push-by-digest=true,name-canonical=true,push=true' \
		$(BAKE_OPTS)

.PHONY: manifest
manifest:
	$(SRC_DIR)/manifests-json.sh push

.PHONY: ls-platforms
ls-platforms:
	@BUILDKIT_PROGRESS=quiet docker buildx bake --print | jq -r '[.target[].platforms[]]|unique[]'

.PHONY: clean
clean:
	rm -f .bake_build_*.json manifest.json

.PHONY: ci-linux/amd64
ci-linux/amd64: build-linux/amd64

.PHONY: ci-linux/arm64
ci-linux/arm64: build-linux/arm64

.PHONY: ci-manifest
ci-manifest: manifest
