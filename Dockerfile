ARG ARCH=arm64v8
FROM lopsided/archlinux-$ARCH

WORKDIR /archlinux

RUN mkdir -p /archlinux/rootfs

COPY pacstrap-docker /archlinux/

RUN ./pacstrap-docker /archlinux/rootfs \
      archlinux-keyring bash coreutils gzip iputils iproute2 man-db man-pages pacman sed tar w3m zsh && \
    # Install Arch Linux ARM keyring if available
    (pacman -r /archlinux/rootfs -S --noconfirm archlinuxarm-keyring || true) && \
    # Remove current pacman database, likely outdated very soon
    rm rootfs/var/lib/pacman/sync/*

FROM scratch
ARG ARCH=arm64v8

COPY --from=0 /archlinux/rootfs/ /
COPY rootfs/common/ /
COPY rootfs/$ARCH/ /

ENV LANG=en_US.UTF-8

RUN locale-gen && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    (pacman-key --populate archlinuxarm || true)

CMD ["/usr/sbin/zsh"]