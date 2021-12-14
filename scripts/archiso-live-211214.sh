mkdir -p airootfs/etc/skel/デスクトップ
install \
  <(curl -s https://raw.githubusercontent.com/sakkke/popwand-linux/main/scripts/installer-211213.sh) \
  airootfs/etc/skel/デスクトップ/installer.sh