ARG PECL_GRPC_VERSION=placeholder
ARG PECL_OTEL_VERSION=placeholder
ARG PECL_REDIS_VERSION=placeholder

FROM builder AS build

COPY --link --from=caddy:builder-alpine /usr/bin/xcaddy /usr/bin/xcaddy

SHELL ["sh", "-euxo", "pipefail", "-c"]

RUN \
  CGO_ENABLED=1 \
  XCADDY_SETCAP=1 \
  XCADDY_GO_BUILD_FLAGS=$'-tags=nobadger,nomysql,nopgx -ldflags "-w -s -extldflags \'-Wl,-z,stack-size=0x80000\'"' \
  CGO_CFLAGS=$(php-config --includes) \
  CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
  xcaddy build \
      --output /usr/local/bin/frankenphp \
      --with github.com/dunglas/frankenphp=./ \
      --with github.com/dunglas/frankenphp/caddy=./caddy/

FROM runner
ARG PECL_GRPC_VERSION
ARG PECL_OTEL_VERSION
ARG PECL_REDIS_VERSION

ENV APP_CACHE_DIR=/var/app/cache
ENV APP_LOG_DIR=/var/app/logs

# default uid and gid for www-data in alpine
ENV APP_UID=82
ENV APP_GID=82

# frankenphp
COPY --link --from=build /usr/local/bin/frankenphp /usr/local/bin/frankenphp

SHELL ["sh", "-euxo", "pipefail", "-c"]

RUN \
  ############################################ \
  ## prepare base system \
  ############################################ \
  apk --no-cache upgrade \
  \
  # base dependencies \
  && apk add --no-cache \
    bash \
    ca-certificates \
    git \
    grep \
    icu-data-full \
    sed \
    yarn \
  \
  && chown -R ${APP_UID}:${APP_GID} /data/caddy /config/caddy /home/www-data /var/www \
  \
  && mkdir -p "$APP_CACHE_DIR" "$APP_LOG_DIR" \
  && chmod 777 "$APP_CACHE_DIR" "$APP_LOG_DIR" \
  \
  ############################################ \
  ## php extensions \
  ############################################ \
  && ini_dir="$(php-config --ini-dir)" \
  \
  && install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    grpc-${PECL_GRPC_VERSION} \
    intl \
    opcache \
    opentelemetry-${PECL_OTEL_VERSION} \
    pcntl \
    redis-${PECL_REDIS_VERSION} \
    xsl \
    zip \
  \
  # grpc \
  && echo "grpc.enable_fork_support = 1" >> "$ini_dir/docker-php-ext-grpc.ini" \
  && echo "grpc.poll_strategy = epoll1" >> "$ini_dir/docker-php-ext-grpc.ini"

SHELL ["sh", "-c"]

# composer
ENV COMPOSER_CACHE_DIR=/var/cache/composer
ENV COMPOSER_HOME=/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH=${COMPOSER_HOME}/vendor/bin:$PATH
COPY --link --from=composer:2 /usr/bin/composer /usr/bin/

COPY --link ./rootfs /

# opentelemetry: https://opentelemetry.io/docs/languages/sdk-configuration/
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://172.25.1.1:4317
ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc
ENV OTEL_PHP_AUTOLOAD_ENABLED=true
ENV OTEL_PHP_EXCLUDED_URLS=^/_
ENV OTEL_PROPAGATORS=b3multi
ENV OTEL_SERVICE_NAME=undefined
ENV OTEL_LOGS_EXPORTER=none
ENV OTEL_METRICS_EXPORTER=none
ENV OTEL_TRACES_EXPORTER=otlp

USER www-data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
