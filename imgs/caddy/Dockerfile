ARG CADDY_VERSION=placeholder

FROM caddy:${CADDY_VERSION}-alpine
ARG CADDY_SOURCEMAPS_AUTHORIZED_IPS

ENV CADDY_DOCROOT="/app"
ENV CADDY_SOURCEMAPS_AUTHORIZED_IPS="$CADDY_SOURCEMAPS_AUTHORIZED_IPS"
ENV CADDY_SOURCEMAPS_SECURITY_TOKEN=""
ENV CADDY_UID=82
ENV CADDY_GID=82

RUN set -ex \
  && adduser -u "${CADDY_UID}" -D -S -G www-data www-data \
  && chown -R www-data:www-data /config /data \
  \
  && setcap -r /usr/bin/caddy

COPY --link ./rootfs/ /

USER www-data

EXPOSE 8080 8443

WORKDIR /etc/caddy
ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
