# vim:set ft=dockerfile:
FROM debian:buster-slim

LABEL maintainer="Mason Chase <public@masonian.com>"

RUN useradd --system asterisk

RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends --no-install-suggests \
    autoconf \
    binutils-dev \
    build-essential \
    ca-certificates \
    curl \
    file \
    libcurl4-openssl-dev \
    libedit-dev \
    libgsm1-dev \
    libogg-dev \
    libpopt-dev \
    libresample1-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite3-dev \
    libmariadb-dev \
    libsrtp2-dev \
    libssl-dev \
    libvorbis-dev \
    libxml2-dev \
    libxslt1-dev \
    procps \
    portaudio19-dev \
    unixodbc \
    unixodbc-bin \
    unixodbc-dev \
    odbcinst \
    uuid \
    uuid-dev \
    xmlstarlet

RUN apt-get purge -y --auto-remove
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/asterisk && cd /usr/src/asterisk
WORKDIR /usr/src/asterisk
