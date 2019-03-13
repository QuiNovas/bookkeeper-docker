FROM openjdk:8-jre-alpine
LABEL maintainer="Mathew Moon <mmoon@quinovas.com>"

RUN set -x && \
    apk add --no-cache --virtual .build-deps \
       ca-certificates \
       gnupg \
       libressl \
       wget \
      shadow && \
    apk add --no-cache bash \
      su-exec && \
    mkdir /journal /ledgers /logs /conf /indexes && \
    adduser -D bookkeeper && \
    cd /tmp && \
    wget -nv "https://archive.apache.org/dist/bookkeeper/bookkeeper-4.9.0/bookkeeper-server-4.9.0-bin.tar.gz" && \
    wget -nv "https://archive.apache.org/dist/bookkeeper/bookkeeper-4.9.0/bookkeeper-server-4.9.0-bin.tar.gz.asc" && \
    wget -nv "https://archive.apache.org/dist/bookkeeper/bookkeeper-4.9.0/bookkeeper-server-4.9.0-bin.tar.gz.sha512" && \
    sha512sum -c bookkeeper-server-4.9.0-bin.tar.gz.sha512 && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "FD74402C" && \
    gpg --batch --verify "bookkeeper-server-4.9.0-bin.tar.gz.asc" "bookkeeper-server-4.9.0-bin.tar.gz" && \
    tar -xzf "bookkeeper-server-4.9.0-bin.tar.gz" && \
    mv bookkeeper-server-4.9.0 /bookkeeper && \
    rm -rf ./* && \
    apk del --no-cache .build-deps && \
    rm -f /bookkeeper/bin/*

WORKDIR /bookkeeper

COPY ./bookkeeper /bookkeeper/bin/bookkeeper
COPY ./client /bookkeeper/bin/client
COPY ./bookkeeper.conf /conf/bookkeeper.conf
COPY ./client.conf /conf/client.conf
COPY ./log4j.properties /conf/log4j.properties
COPY ./log4j.cli.properties /conf/log4j.cli.properties

RUN chmod +x -R /bookkeeper/bin && \
    chown -R bookkeeper:bookkeeper /bookkeeper /ledgers /logs /journal /conf /indexes

ENV PATH=$PATH:/bookkkeeper/bin

ENTRYPOINT [ "/bookkeeper/bin/bookkeeper" ]
