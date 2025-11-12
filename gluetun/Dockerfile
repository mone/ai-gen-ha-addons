ARG BUILD_FROM=qmcgaw/gluetun:v3.40.0
FROM ${BUILD_FROM}

USER root

RUN apk add --no-cache jq

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

COPY rootfs/ /

