mkdir -p airootfs/etc/skel/デスクトップ
install \
  -g 1000 \
  -o 1000 \
  <(curl -s https://raw.githubusercontent.com/sakkke/popwand-linux/main/scripts/installer-211213.sh) \
  airootfs/etc/skel/デスクトップ/installer.sh