# vim:set ft=dockerfile:
FROM ubuntu:focal

LABEL maintainer="Mason Chase <public@masonian.com>"

ENV ASTERISK_VERSION=18
RUN echo $ASTERISK_VERSION

RUN useradd --system asterisk
#RUN adduser --gecos "" --no-create-home --uid 1000 --disabled-password asterisk

RUN apt-get update -qq
#RUN apt-get install software-properties-common build-essential -y
#RUN add-apt-repository ppa:ondrej/php
 # --no-install-recommends --no-install-suggests 
#RUN export DEBIAN_FRONTEND=noninteractive
#RUN export TZ=Etc/UTC
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN apt-get install --no-install-recommends --no-install-suggests -yq tzdata 
RUN export DEBIAN_FRONTEND="noninteractive" ; apt-get install -yq \
    apt-utils \
    autoconf \
    binutils-dev \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    file \
    libcurl4-openssl-dev \
    libedit-dev \
    libpopt-dev \
    libgsm1-dev \
    libjansson-dev \
    libogg-dev \
    libpopt-dev \
    libresample1-dev \
    libspandsp-dev \
    libspeex-dev \
    libspeexdsp-dev \
    libsqlite3-dev \
    mariadb-client mariadb-common libmariadb-dev libmariadb-dev-compat \
    librust-winapi-dev \
    libsox-dev libsox3 sox \
    libsrtp2-dev \
    libssl-dev \
    libvorbis-dev \
    libxml2-dev \
    libxslt1-dev \
    ncurses-base ncurses-bin \
    opus-tools \
    odbcinst \
    php7.4 \
    python3 \
    python3-certbot python3-certbot-dns-cloudflare \
    procps \
    portaudio19-dev \
    subversion \
    uuid \
    uuid-dev \
    vim \
    xmlstarlet 
RUN apt-get install -y unixodbc unixodbc-dev python3-dev python3-pip python3-mysqldb
RUN pip install alembic

RUN apt-get purge -y --auto-remove
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/asterisk && cd /usr/src/asterisk
WORKDIR /usr/src/asterisk

RUN curl -vsL https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.17-linux-ubuntu19.04-x86-64bit.tar.gz | tar --strip-components 1 -xz
RUN curl -vsL http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}-current.tar.gz | tar --strip-components 1 -xz
RUN : ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}

RUN ls -la 
RUN contrib/scripts/get_mp3_source.sh
RUN contrib/scripts/install_prereq
RUN ./bootstrap.sh
RUN ./configure --with-resample \
            --with-crypto \
            --with-srtp \
            --with-pjproject-bundled \
            --with-jansson-bundled
# disable BUILD_NATIVE to avoid platform issues
RUN make menuselect.makeopts
RUN menuselect/menuselect --enable format_mp3 \
                          --enable app_mysql \
                          --enable res_config_mysql \
                          --enable cdr_mysql \
                          --enable app_skel \
                          --enable app_fax \
                          --enable app_ivrdemo \
                          --enable app_saycounted \
                          --enable res_pktccops \
                          --enable res_fax \
                          --enable res_fax_spandsp \
                          --disable BUILD_NATIVE \
                          --enable G711_NEW_ALGORITHM \
                          --enable G711_REDUCED_BRANCHING \
                          --enable CORE-SOUNDS-EN-WAV \
                          --enable CORE-SOUNDS-EN-ULAW \
                          --enable CORE-SOUNDS-EN-ALAW \
                          --enable CORE-SOUNDS-EN-G729 \
                          --enable CORE-SOUNDS-EN-G722 \
                          --enable MOH-OPSOUND-ULAW \
                          --enable MOH-OPSOUND-ALAW \
                          --enable MOH-OPSOUND-GSM \
                          --enable MOH-OPSOUND-G729 \
                          --enable MOH-OPSOUND-G722 \
                          --enable res_chan_stats \
                          --enable app_statsd \
                          --enable res_endpoint_stats \
                          --enable codec_opus \
                          --enable res_chan_stats \
                          --enable res_endpoint_stats \
                          --enable smsq \
                          --enable BETTER_BACKTRACES  
                          #--enable res_mongodb \
                          # enable good things

ENV ASTERISK_VERSION 18-current
ENV OPUS_CODEC       asterisk-18.0/x86-64/codec_opus-18.0_current-x86_64

RUN make -j ${JOBS} all
RUN make install

# copy default configs
COPY configs/*.conf /etc/asterisk/

# set runuser and rungroup
RUN sed -i -E 's/^;(run)(user|group)/\1\2/' /etc/asterisk/asterisk.conf

RUN cp -r /etc/asterisk /etc/asterisk_samples

ENV OPUS_CODEC       asterisk-18.0/x86-64/codec_opus-18.0_current-x86_64
RUN mkdir -p /usr/src/codecs/opus \
  && cd /usr/src/codecs/opus \
  && curl -vsL http://downloads.digium.com/pub/telephony/codec_opus/${OPUS_CODEC}.tar.gz | tar --strip-components 1 -xz \
  && cp *.so /usr/lib/asterisk/modules/ \
  && cp codec_opus_config-en_US.xml /var/lib/asterisk/documentation/


RUN curl http://asterisk.hosting.lv/bin/codec_g729-ast180-gcc4-glibc-x86_64-pentium4.so -o /usr/lib/asterisk/modules/codec_g729.so

#COPY build-asterisk.sh /
#RUN /build-asterisk.sh

EXPOSE 5060/udp 5060/tcp 5061/tcp
RUN mkdir -p /etc/asterisk/ \
          /var/spool/asterisk/fax \
          /volumes/astcachedir \
          /volumes/astdbdir \
          /volumes/astkeydir \
          /volumes/astdatadir \
          /volumes/astvarlibdir \
          /volumes/astagidir \
          /volumes/astspooldir \
          /volumes/astrundir \
          /volumes/astlogdir

RUN chown -R asterisk:asterisk /etc/asterisk \
                           /var/*/asterisk \
                           /usr/*/asterisk \
                           /volumes

RUN chmod -R 750 /var/spool/asterisk

VOLUME /etc/asterisk /var/lib/asterisk 
# /volumes/astcachedir /volumes/astdbdir /var/lib/asterisk/sounds /var/lib/asterisk/phoneprov /volumes/astkeydir /volumes/astdatadir /volumes/astagidir /volumes/astspooldir /volumes/astrundir /volumes/astlogdir

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/asterisk", "-vvvvvvvvdddf", "-X", "-T", "-W", "-U", "asterisk", "-p"]
