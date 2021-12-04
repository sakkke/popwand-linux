pacman --noconfirm -S \
  kde-applications-meta \
  noto-fonts \
  noto-fonts-cjk \
  noto-fonts-emoji \
  noto-fonts-extra \
  plasma-meta \
  sudo

localectl set-x11-keymap jp

useradd -mG wheel user
echo user:p@ssw0rd | chpasswd

sed -E 's/^# (%wheel ALL=\(ALL\) ALL)/\1/' /etc/sudoers | env EDITOR=tee visudo > /dev/null