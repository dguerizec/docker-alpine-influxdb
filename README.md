# docker-alpine-influxdb

This tiny image is based on the official [Alpine Linux](http://www.alpinelinux.org) 3.3 and contains a build of [InfluxDB](https://influxdata.com) v0.10.1.

[![](https://badge.imagelayers.io/imko/docker-alpine-influxdb:latest.svg)](https://imagelayers.io/?images=imko/docker-alpine-influxdb:latest)

## Build this image

    $ docker build -t imko/docker-alpine-influxdb .

## Run this image

    $ docker run -p 8083:8083 -p 8086:8086 -v ./data:/var/lib/influxdb imko/docker-alpine-influxdb

## Use as base image

    FROM imko/docker-alpine-influxdb:v0.10.1
    ADD influxdb.conf /etc/influxdb.conf

## Use with docker-compose

    $ cat docker-compose.yml
    version: '2'
    services:
      grafana:
        image: grafana/grafana
        environment:
          - "GF_SERVER_ROOT_URL=http://grafana.server.name"
          - "GF_SECURITY_ADMIN_PASSWORD=secret
        volumes:
          - grafana-storage:/var/lib/grafana
        ports:
          - "3000:3000"
        links:
          - influxdb
      influxdb:
        image: imko/docker-alpine-influxdb
        volumes:
          - influx-storage:/var/lib/influxdb
        ports:
          - "8083:8083"
          - "8086:8086"
    volumes:
      influx-storage:
      grafana-storage:
