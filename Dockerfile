ARG ALPINE_VERSION=3.24

FROM rust:alpine${ALPINE_VERSION} AS builder

RUN apk add --no-cache \
    alpine-sdk \
    pkgconfig \
    clang-dev \
    fuse3-dev \
    git \
    cmake \
    libunwind-dev

ARG MOUNTPOINT_S3_VERSION=v1.23.0
ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN git clone --depth=1 -b ${MOUNTPOINT_S3_VERSION} https://github.com/awslabs/mountpoint-s3 /work/mountpoint-s3
WORKDIR /work/mountpoint-s3
RUN git submodule update --init --recursive --recommend-shallow --depth 1
RUN cargo build --release


FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
  fuse3 \
  libgcc

COPY --from=builder /work/mountpoint-s3/target/release/mount-s3 /usr/local/bin
