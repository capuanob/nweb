# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/nweb/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/nweb.git
WORKDIR /nweb


## Build
RUN clang nweb23.c -o nweb-non-daemon

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd nweb-non-daemon | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /nweb/nweb-non-daemon /nweb
COPY --from=builder /deps /usr/lib

RUN mkdir /nwebdir
env AFL_NO_FORKSRV=1
CMD /nweb 8181 /nwebdir
