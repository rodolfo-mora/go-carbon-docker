# https://github.com/go-graphite/go-carbon/blob/master/Dockerfile

FROM golang:1.15.3-alpine3.12 AS build

ARG gocarbon_version=0.15.5
ARG gocarbon_repo=https://github.com/go-graphite/go-carbon.git
RUN apk add --update git make \
 && git clone "${gocarbon_repo}" /usr/local/src/go-carbon \
 && cd /usr/local/src/go-carbon \
 && git checkout tags/v"${gocarbon_version}" \
 && make \
 && chmod +x go-carbon && cp -fv go-carbon /tmp

FROM alpine:3.9
COPY --from=build /tmp/go-carbon /usr/sbin/go-carbon

COPY ["./etc/", "/etc/"]

RUN apk update
RUN apk add --no-cache --update python3
RUN mkdir /var/log/go-carbon /var/lib/graphite /var/lib/graphite/whisper \
    /var/lib/graphite/tagging /var/lib/graphite/dump
RUN touch /var/run/go-carbon.pid

RUN addgroup -S carbon && adduser -S carbon -G carbon
RUN chown -R carbon:carbon /etc/go-carbon/ /var/lib/graphite/ /var/log/go-carbon \
    /etc/init.d/go-carbon /etc/go-carbon/ /var/run/ /usr/sbin/go-carbon

USER carbon
EXPOSE 2003 2004 7002 7003 7007 8081 2003/udp
ENTRYPOINT ["/bin/sh", "/etc/go-carbon/entrypoint.sh"]
