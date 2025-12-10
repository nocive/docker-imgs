ARG ALPINE_VERSION=placeholder
ARG SHELLCHECK_VERSION=placeholder
ARG SHFMT_VERSION=placeholder

FROM koalaman/shellcheck:v${SHELLCHECK_VERSION} AS shellcheck

FROM alpine:${ALPINE_VERSION}
ARG SHELLCHECK_VERSION
ARG SHFMT_VERSION
ARG TARGETARCH

RUN --mount=type=cache,sharing=locked,id=apk-${TARGETARCH}/var/cache/apk,target=/var/cache/apk \
  apk add --no-cache \
    bash \
    git

ADD --link --chmod=0755 https://github.com/mvdan/sh/releases/download/v${SHFMT_VERSION}/shfmt_v${SHFMT_VERSION}_linux_${TARGETARCH} /usr/local/bin/shfmt
RUN shfmt --version

COPY --link --from=shellcheck /bin/shellcheck /usr/local/bin/
RUN shellcheck --version

USER nobody
