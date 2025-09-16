FROM archlinux:latest

RUN pacman -Syu --noconfirm archiso just edk2-ovmf qemu-desktop
RUN mkdir /run/shm

CMD ["/usr/bin/bash"]
