FROM archlinux/archlinux
RUN pacman --noconfirm -S \
    git \
    sudo \
  && echo 'gitpod ALL=NOPASSWD: ALL' \
    | tee /etc/sudoers.d/gitpod
