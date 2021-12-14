cat >> packages.x86_64 << /cat
edk2-shell
linux-firmware
memtest86+
syslinux
/cat
sort -uo packages.x86_64 packages.x86_64

mkdir -p airootfs/etc/skel/デスクトップ
install \
  -g 1000 \
  -o 1000 \
  <(curl -s https://raw.githubusercontent.com/sakkke/popwand-linux/main/scripts/installer-211213.sh) \
  airootfs/etc/skel/デスクトップ/installer.sh