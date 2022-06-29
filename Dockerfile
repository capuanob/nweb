# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
ADD . /nweb
WORKDIR /nweb

## Build
RUN clang nweb23.c -o nweb -DMAYHEM=1

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd nweb | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /nweb/nweb /nweb
COPY --from=builder /deps /usr/lib

RUN mkdir /nwebdir
ENV AFL_NO_FORKSRV=1
