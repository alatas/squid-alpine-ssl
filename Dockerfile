FROM alpine:3.7

LABEL maintainer="alatash@gmail.com"

ENV SSL_BUMP=1 \
    CN=squid.local \
    O=squid \
    OU=squid \
    C=US

RUN apk add --no-cache \
    squid=3.5.27-r0 \
    openssl=1.0.2o-r0

COPY start.sh /usr/local/bin/
COPY openssl.cnf.add /etc/ssl
COPY conf/squid*.conf /etc/squid/

RUN cat /etc/ssl/openssl.cnf.add >> /etc/ssl/openssl.cnf

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 3128

ENTRYPOINT ["/usr/local/bin/start.sh"]