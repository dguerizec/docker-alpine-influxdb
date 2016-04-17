FROM alpine:3.3

ENV INFLUX_VERSION v0.12.1

ENV GOLANG_VERSION 1.4.3
ENV GOLANG_URL https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz
ENV GOLANG_SHA1 486db10dc571a55c8d795365070f66d343458c48

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
        bash \
        curl \
        ca-certificates \
        gcc \
        musl-dev \
        openssl \
        git \
    \
    && curl -L "$GOLANG_URL" -o golang.tar.gz \
    && echo "$GOLANG_SHA1  golang.tar.gz" | sha1sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz \
    && cd /usr/local/go/src \
    && ./make.bash \
    && export GOPATH=/go \
    && export GOROOT=/usr/local/go \
    && export PATH=$GOPATH/bin:$GOROOT/bin:$PATH \
    \
    && go get github.com/sparrc/gdm \
    && go get github.com/influxdata/influxdb \
    && cd $GOPATH/src/github.com/influxdata/influxdb \
    && git checkout -q --detach "$INFLUX_VERSION" \
    && gdm restore \
    && LDFLAGS="-X main.version $INFLUX_VERSION" \
    && LDFLAGS="$LDFLAGS -X main.branch master" \
    && LDFLAGS="$LDFLAGS -X main.commit $(git rev-parse --short HEAD)" \
    && LDFLAGS="$LDFLAGS -X main.buildTime $(date -Iseconds)" \
    && go clean ./... \
    && go install -ldflags="$LDFLAGS" ./... \
    && cp $GOPATH/bin/influx* /usr/bin/ \
    \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* $GOROOT $GOPATH

ADD influxdb.conf /etc/influxdb.conf

VOLUME /var/lib/influxdb
EXPOSE 8083 8086 8088 8091

CMD ["influxd", "-config", "/etc/influxdb.conf"]
