FROM debian:stretch

ENV TOR_VERSION=7.5.1
# Via https://dist.torproject.org/torbrowser/$TOR_VERSION/sha256sums-signed-build.txt
ENV SHA256_CHECKSUM=4087c5e18f6290296d7f343d5286193be496e979d4f19f239db6d40702cbb5b0
ENV LANG=C.UTF-8
ENV RELEASE_FILE=tor-browser-linux64-${TOR_VERSION}_en-US.tar.xz
ENV RELEASE_KEY=0x4E2C6E8793298290
ENV RELEASE_URL=https://dist.torproject.org/torbrowser/${TOR_VERSION}/${RELEASE_FILE}
ENV PATH=$PATH:/usr/local/bin/Browser

RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      curl \
      file \
      gpg \
      libx11-xcb1 \
      libasound2 \
      libdbus-glib-1-2 \
      libgtk2.0-0 \
      libxrender1 \
      libxt6 \
      xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --home-dir /home/user user && \
    chown -R user:user /home/user

WORKDIR /usr/local/bin
RUN gpg --keyserver https://pgp.mit.edu --recv-keys $RELEASE_KEY && \
    curl --fail -O -sSL ${RELEASE_URL} && \
    curl --fail -O -sSL ${RELEASE_URL}.asc && \
    gpg --verify ${RELEASE_FILE}.asc && \
    echo "$SHA256_CHECKSUM $RELEASE_FILE" > sha256sums.txt && \
    sha256sum -c sha256sums.txt && \
    tar --strip-components=1 -vxJf ${RELEASE_FILE} && \
    rm -v ${RELEASE_FILE}* sha256sums.txt && \
    mkdir -p /usr/local/bin/Browser/Downloads && \
    chown -R user:user /usr/local/bin

WORKDIR /usr/local/bin/Browser/Downloads
USER user

COPY ["start", "/usr/local/bin/"]
ENTRYPOINT ["start"]
CMD [""]
