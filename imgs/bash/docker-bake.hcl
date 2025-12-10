variable "ALPINE_VERSION" {
  default = "3.23"
}

variable "IMG_TAG" {
  default = "alpine${ALPINE_VERSION}"
}

variable "DOCKER_REPO" {
  default = "nocive/bash"
}

variable "DOCKER_PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

group "default" {
  targets = ["build"]
}

group "all" {
  targets = ["build-all"]
}

target "build" {
  output    = ["type=docker"]
  platforms = DOCKER_PLATFORMS
  tags      = [DOCKER_REPO]

  labels = {
    "docker.repository" = DOCKER_REPO
    "docker.basetag"    = IMG_TAG
  }

  args = {
    ALPINE_VERSION = ALPINE_VERSION

    # https://github.com/koalaman/shellcheck/releases
    SHELLCHECK_VERSION = "0.11.0"
    # https://github.com/mvdan/sh/releases
    SHFMT_VERSION      = "3.12.0"
  }
}

target "build-all" {
  inherits = ["build"]
  tags     = ["${DOCKER_REPO}:${IMG_TAG}-${uuidv4()}"]
}
