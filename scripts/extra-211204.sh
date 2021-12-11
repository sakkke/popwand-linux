pacman --needed -S base-devel
pacman --noconfirm -S \
  code \
  docker \
  docker-compose \
  fcitx5-mozc \
  fcitx5-im \
  firefox \
  firefox-developer-edition \
  firefox-developer-edition-i18n-ja \
  firefox-i18n-ja \
  gimp \
  git \
  gparted \
  inkscape \
  kitty \
  krita \
  libreoffice-fresh \
  libreoffice-fresh-ja \
  simplescreenrecorder \
  tmux \
  ttf-fira-code \
  vim \
  vivaldi \
  wget

mkdir -p /etc/skel/.config/kitty
cat > /etc/skel/.config/kitty/kitty.conf << /cat
font_family Fira Code
/cat

cat > /etc/skel/.pam_environment << /cat
# for kitty
GLFW_IM_MODULE DEFAULT=ibus

GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE DEFAULT=fcitx
SDL_IM_MODULE DEFAULT=fcitx
XMODIFIERS DEFAULT=\@im=fcitx
/cat