FROM debian:stable-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nasm \
        qemu-system-x86 \
        make \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /orinal

CMD ["bash"]
