# Based on https://github.com/bambocher/docker-exim-relay DKIM conf removed
FROM alpine:3.12.0
LABEL maintainer="docmain@pristavk.in"

ARG VERSION=4.93-r1

LABEL org.label-schema.version=$VERSION \
#      org.label-schema.vcs-url=https://github.com/bambocher/docker-exim-relay \
      org.label-schema.license=MIT \
      org.label-schema.schema-version=1.0

RUN apk --no-cache add exim=$VERSION libcap openssl \
    && ln -s /dev/stdout /var/log/exim/mainlog \
    && ln -s /dev/stderr /var/log/exim/paniclog \
    && ln -s /dev/stderr /var/log/exim/rejectlog \
    && chown -R exim: /var/log/exim \
    && chmod 0755 /usr/sbin/exim \
    && setcap cap_net_bind_service=+ep /usr/sbin/exim \
    && apk del libcap

COPY ./exim.conf /etc/exim

USER exim
VOLUME ["/var/spool/exim"]
EXPOSE 25

ENTRYPOINT ["/usr/sbin/exim"]
CMD ["-bdf", "-q15m"]