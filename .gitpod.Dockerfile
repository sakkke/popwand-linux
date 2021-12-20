FROM archlinux/archlinux
RUN pacman --needed --noconfirm -Sy \
    git \
    sudo \
  && echo 'gitpod ALL=NOPASSWD: ALL' \
    | tee /etc/sudoers.d/gitpod
