#!/usr/bin/env sh
set -eu

docker-configure-app

exec "$@"
