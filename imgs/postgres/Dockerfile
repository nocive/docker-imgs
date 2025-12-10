ARG ALPINE_VERSION=placeholder
ARG PG_VERSION=placeholder

FROM postgres:${PG_VERSION}-alpine${ALPINE_VERSION}

RUN apk add --no-cache \
  shadow \
  su-exec \
  \
  # remove dialout (20) group since that's often the primary GID in OSX \
  && groupdel dialout \
  \
  # replace gosu usages with su-exec \
  # https://github.com/docker-library/postgres/issues/1304 \
  && rm -f /usr/local/bin/gosu \
  && sed -i 's/gosu postgres/su-exec postgres/g' /usr/local/bin/docker-*


COPY --link --from=entrypoint-scripts entrypoint-su-exec chown-path set-user-group-home /usr/local/bin/

ENV EUSER=postgres
ENV EUID=999
ENV EGROUP=postgres
ENV EGID=999

ENTRYPOINT ["/usr/local/bin/entrypoint-su-exec", "/usr/local/bin/docker-entrypoint.sh"]
