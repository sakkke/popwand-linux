pacman --needed -S base-devel
pacman --noconfirm -S \
  code \
  firefox \
  firefox-developer-edition \
  firefox-developer-edition-i18n-ja \
  firefox-i18n-ja \
  gimp \
  git \
  inkscape \
  kitty \
  krita \
  ttf-fira-code \
  vim

mkdir -p /etc/skel/.config/kitty
cat > /etc/skel/.config/kitty/kitty.conf << /cat
font_family Fira Code
/cat