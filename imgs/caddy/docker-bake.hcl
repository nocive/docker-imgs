variable "CADDY_VERSION" {
  # https://github.com/caddyserver/caddy/releases
  default = "2.10.2"
}

variable "DOCKER_REPO" {
  default = "nocive/caddy"
}

variable "DOCKER_PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMG_TAG" {
  default = "${CADDY_VERSION}"
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

  args = {
    CADDY_VERSION = CADDY_VERSION

    CADDY_SOURCEMAPS_AUTHORIZED_IPS = ""
  }
}

target "build-all" {
  inherits  = ["build"]
  tags      = ["${DOCKER_REPO}:${IMG_TAG}-${uuidv4()}"]
}
