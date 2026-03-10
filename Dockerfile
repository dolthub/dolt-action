FROM python:3.13-alpine

RUN apk add --no-cache bash curl jq git \
    && curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && dolt config --global --add metrics.host eventsapi.awsdev.ld-corp.com \
    && dolt config --global --add metrics.port 443 \
    && curl -sSL https://sdk.cloud.google.com | bash

USER 1001

ENV PATH=$PATH:/usr/local/gcloud/google-cloud-sdk/bin

COPY entrypoint.sh /entrypoint.sh
COPY cleanup.sh /cleanup.sh

ENTRYPOINT ["/entrypoint.sh"]
