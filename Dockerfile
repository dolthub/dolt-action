FROM python:3.9.5-alpine

COPY install.sh /install.sh

ARG dolt_version=0.28.4
RUN apk add --no-cache bash curl jq git \
    && DOLT_VERSION=$dolt_version /install.sh \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && dolt config --global --add metrics.host eventsapi.awsdev.ld-corp.com \
    && dolt config --global --add metrics.port 443 \
    && curl -sSL https://sdk.cloud.google.com | bash

USER 1001

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

COPY entrypoint.sh /entrypoint.sh
COPY cleanup.sh /cleanup.sh

ENTRYPOINT ["/entrypoint.sh"]
