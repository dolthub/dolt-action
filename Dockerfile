# Container image that runs your code
FROM alpine:3.10

RUN apk add --no-cache bash curl jq git \
    && curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && dolt config --global --add metrics.host eventsapi.awsdev.ld-corp.com \
    && dolt config --global --add metrics.port 443
    #&& dolt config --global --add user.email bojack@horseman.com \
    #&& dolt config --global --add user.name "Bojack Horseman" \

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`
ENTRYPOINT ["/entrypoint.sh"]
