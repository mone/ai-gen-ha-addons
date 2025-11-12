ARG BUILD_FROM=qmcgaw/gluetun:latest
FROM ${BUILD_FROM}

USER root

RUN apk add --no-cache jq

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

COPY rootfs/ /

