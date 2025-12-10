variable "FRANKENPHP_VERSION" {
  # https://github.com/dunglas/frankenphp/releases
  default = "1.10.1"
}

variable "PHP_VERSION" {
  default = "8.4.15"
}

variable "DOCKER_PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "DOCKER_REPO" {
  default = "nocive/frankenphp"
}

variable "IMG_TAG" {
  default = "${FRANKENPHP_VERSION}-php${PHP_VERSION}-alpine"
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
    builder = "docker-image://dunglas/frankenphp:${FRANKENPHP_VERSION}-builder-php${PHP_VERSION}-alpine"
    runner  = "docker-image://dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}-alpine"
  }

  args = {
    # https://pecl.php.net/package/grpc
    PECL_GRPC_VERSION  = "1.76.0"
    # https://pecl.php.net/package/opentelemetry
    PECL_OTEL_VERSION  = "1.2.1"
    # https://pecl.php.net/package/redis
    PECL_REDIS_VERSION = "6.3.0"
  }
}

target "build-all" {
  inherits = ["build"]
  tags     = ["${DOCKER_REPO}:${IMG_TAG}-${uuidv4()}"]
}
