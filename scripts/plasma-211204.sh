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

cat > /etc/sudoers.d/wheel << /cat
%wheel ALL=(ALL) ALL
/cat