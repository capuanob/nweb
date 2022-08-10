# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang

ADD . /nweb
WORKDIR /nweb

## Build
RUN clang nweb23.c -o nweb -DMAYHEM=1

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /nweb/nweb /nweb

RUN mkdir /nwebdir
