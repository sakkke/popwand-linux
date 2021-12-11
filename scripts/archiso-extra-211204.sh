mkdir -p airootfs/etc/pacman.d/hooks
cat > airootfs/etc/pacman.d/hooks/vivaldi-install.hook << /cat
# remove from airootfs!
[Trigger]
Operation = Install
Type = Package
Target = vivaldi

[Action]
Description = Set default web browser to Vivaldi...
When = PostTransaction
Depends = bash
Exec = /bin/bash -c "ls -1 /home | grep -v '^root$' | xargs -I{} sudo -u {} xdg-settings set default-web-browser vivaldi-stable.desktop"
/cat

cat >> packages.x86_64 << /cat
base-devel
code
docker
docker-compose
fcitx5-mozc
fcitx5-im
firefox
firefox-developer-edition
firefox-developer-edition-i18n-ja
firefox-i18n-ja
gimp
git
gparted
krita
inkscape
kitty
libreoffice-fresh
libreoffice-fresh-ja
man
simplescreenrecorder
tmux
ttf-fira-code
vim
vivaldi
wget
/cat
sort -uo packages.x86_64 packages.x86_64

cat > airootfs/etc/environment << /cat
EDITOR=/usr/bin/vim
/cat

mkdir -p airootfs/etc/skel/.config/kitty
cat > airootfs/etc/skel/.config/kitty/kitty.conf << /cat
font_family Fira Code
/cat

cat > airootfs/etc/skel/.pam_environment << /cat
# for kitty
GLFW_IM_MODULE DEFAULT=ibus

GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE DEFAULT=fcitx
SDL_IM_MODULE DEFAULT=fcitx
XMODIFIERS DEFAULT=\@im=fcitx
/cat

cat >> airootfs/etc/group << /cat
docker:x:970:user
/cat

ln -sv /usr/lib/systemd/system/docker.service airootfs/etc/systemd/system/multi-user.target.wants/