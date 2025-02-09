# define the target here
ARG ARCH="x86_64"
ARG BASE_IMAGE="debian:12-slim"

# builder statge
FROM ${BASE_IMAGE} AS builder

ARG ARCH

ADD https://github.com/richfelker/musl-cross-make.git /musl-cross-make

WORKDIR /musl-cross-make

ENV TARGET="${ARCH}-linux-musl" MAKEFLAGS="-j4" CFLAGS="-mtune=generic -O2 -pipe" CPPFLAGS="-mtune=generic -O2 -pipe" CXXFLAGS="-mtune=generic -O2 -pipe"

RUN apt update && apt install -y build-essential file git texinfo wget

RUN make install

# it's to fix a symbolic link that points to an inexistent file...
RUN cd output/${ARCH}-linux-musl/lib/ && rm -f ld-musl-${ARCH}.so.1 && \
    ln -s libc.so ld-musl-${ARCH}.so.1

# final stage
FROM ${BASE_IMAGE}

ARG ARCH
ARG BASE_IMAGE

LABEL org.opencontainers.image.authors="null31 <null@rwx.moe>"
LABEL org.opencontainers.image.base.name="${BASE_IMAGE}"
LABEL org.opencontainers.image.title="null31/musl-cross-make:${ARCH}"
LABEL org.opencontainers.image.version="18.09.2024"
LABEL target="${ARCH}-linux-musl"

COPY --from=builder /musl-cross-make/output /usr/
