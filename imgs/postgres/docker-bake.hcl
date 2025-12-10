variable "PG_VERSION" {
  default = "16.11"
}

variable "ALPINE_VERSION" {
  default = "3.23"
}

variable "DOCKER_REPO" {
  default = "nocive/postgres"
}

variable "DOCKER_PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMG_TAG" {
  default = "${PG_VERSION}-alpine${ALPINE_VERSION}"
}

group "default" {
  targets = ["build"]
}

group "all" {
  targets = ["build-all"]
}

target "build" {
  context   = "."
  output    = ["type=docker"]
  platforms = DOCKER_PLATFORMS
  tags      = [DOCKER_REPO]

  labels = {
    "docker.repository" = DOCKER_REPO
    "docker.basetag"    = IMG_TAG
  }

  contexts = {
    entrypoint-scripts = "../../resources/entrypoint-scripts/"
  }

  args = {
    ALPINE_VERSION = ALPINE_VERSION
    PG_VERSION     = PG_VERSION
  }
}

target "build-all" {
  inherits  = ["build"]
  tags      = ["${DOCKER_REPO}:${IMG_TAG}-${uuidv4()}"]
}
