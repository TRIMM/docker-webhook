# Dockerfile for https://github.com/adnanh/webhook
FROM golang:alpine3.12 AS build
WORKDIR /go/src/github.com/adnanh/webhook
ENV WEBHOOK_VERSION 2.7.0
RUN apk add --update -t build-deps curl libc-dev gcc libgcc
RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar -xzf webhook.tar.gz --strip 1 &&  \
    go get -d && \
    go build -o /usr/local/bin/webhook && \
    apk del --purge build-deps && \
    rm -rf /var/cache/apk/* && \
    rm -rf /go

FROM alpine:3.12
ENV DOCKER_COMPOSE_VERSION 1.26.0
COPY --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN apk --update add py-pip
RUN apk --update add --virtual build-dependencies gcc python2-dev libffi-dev openssl-dev musl-dev make &&\
    pip install -U docker-compose==${DOCKER_COMPOSE_VERSION} &&\
    apk del build-dependencies &&\
    rm -rf `find / -regex '.*\.py[co]' -or -name apk`

WORKDIR /etc/webhook
VOLUME ["/etc/webhook"]
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/webhook"]
