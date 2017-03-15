FROM alpine:3.5
MAINTAINER Aestetype

# install giddyup
RUN apk add --update --no-cache curl \
    && mkdir -p /opt/rancher/bin \
    && curl -L https://github.com/aslafy-z/giddyup/releases/download/container-names/giddyup -o /opt/rancher/bin/giddyup \
    && chmod u+x /opt/rancher/bin/*

ADD ./*.sh /opt/rancher/bin/
RUN chmod u+x /opt/rancher/bin/*.sh

VOLUME /opt/rancher/bin
