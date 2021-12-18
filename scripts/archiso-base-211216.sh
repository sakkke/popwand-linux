#!/bin/bash
set -eu
rm -fr archlive
cp -r /usr/share/archiso/configs/baseline archlive
cd archlive
cat > airootfs/etc/environment << /cat
EDITOR=/usr/bin/nvim
/cat

# ref: https://wiki.archlinux.org/title/archiso#:~:text=5).%20For%20example%3A-,archlive/airootfs/etc/group,-root%3Ax%3A0%3Aroot
cat > airootfs/etc/group << '/cat'
root:x:0:root
wheel:x:10:user
user:x:1000:
/cat

# ref: https://wiki.archlinux.org/title/archiso#:~:text=to%20gshadow(5)%3A-,archlive/airootfs/etc/gshadow,-root%3A!*%3A%3Aroot%0Aarchie
cat > airootfs/etc/gshadow << '/cat'
root:!*::root
user:!*::
/cat

cat > airootfs/etc/hostname << /cat
earth
/cat
cat > airootfs/etc/locale.conf << '/cat'
LANG=ja_JP.UTF-8
/cat
ln -s /usr/share/zoneinfo/Asia/Tokyo airootfs/etc/localtime
mkdir -p airootfs/etc/pacman.d/hooks

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/40-locale-gen.hook
cat > airootfs/etc/pacman.d/hooks/40-locale-gen.hook << '/cat'
# remove from airootfs!
[Trigger]
Operation = Install
Type = Package
Target = glibc

[Action]
Description = Uncommenting en_US.UTF-8 locale and running locale-gen...
When = PostTransaction
Depends = glibc
Depends = sed
Depends = sh
#Exec = /bin/sh -c "sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen && locale-gen"
Exec = /bin/sh -c "sed -i 's/#\(en_US\.UTF-8\|ja_JP\.UTF-8\)/\1/' /etc/locale.gen && locale-gen"
/cat

cat > airootfs/etc/pacman.d/hooks/kitty-install.hook << '/cat'
Operation = Install
Operation = Upgrade
Type = Package
Target = kitty

[Action]
Description = Setting a theme for kitty...
When = PostTransaction
Exec = /etc/pacman.d/hooks.bin/kitty-install
/cat
cat > airootfs/etc/pacman.d/hooks/kitty-remove.hook << '/cat'
[Trigger]
Operation = Remove
Type = Package
Target = kitty

[Action]
Description = Removing a theme for kitty...
When = PreTransaction
Exec = /etc/pacman.d/hooks.bin/kitty-remove
/cat
cat > airootfs/etc/pacman.d/hooks/shotcut-install.hook << '/cat'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = shotcut

[Action]
Description = Creating a Shotcut 24x24 icon...
When = PostTransaction
Exec = /etc/pacman.d/hooks.bin/shotcut-install
/cat
cat > airootfs/etc/pacman.d/hooks/shotcut-remove.hook << '/cat'
[Trigger]
Operation = Remove
Type = Package
Target = shotcut

[Action]
Description = Removing a Shotcut 24x24 icon...
When = PreTransaction
Exec = /etc/pacman.d/hooks.bin/shotcut-remove
/cat

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/uncomment-mirrors.hook
cat > airootfs/etc/pacman.d/hooks/uncomment-mirrors.hook << '/cat'
# remove from airootfs!
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = pacman-mirrorlist

[Action]
Description = Uncommenting all mirrors in /etc/pacman.d/mirrorlist...
When = PostTransaction
Depends = pacman-mirrorlist
Depends = sed
Exec = /usr/bin/sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
/cat

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook
cat > airootfs/etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook << '/cat'
# remove from airootfs!
# As a workaround for https://bugs.archlinux.org/task/49347 , remove pacman hooks specific to the ISO build process.
# If not, they would be used when pacstrap is run in the live environment.

[Trigger]
Operation = Install
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Work around FS#49347 by removing custom pacman hooks that are only required during ISO build...
When = PostTransaction
Depends = sh
Depends = coreutils
Depends = grep
Exec = /bin/sh -c "rm -- $(grep -Frl 'remove from airootfs' /etc/pacman.d/hooks/)"
/cat

mkdir airootfs/etc/pacman.d/hooks.bin
cat > airootfs/etc/pacman.d/hooks.bin/kitty-install << '/cat'
#!/bin/bash
kitty +kitten themes --dump-theme Campbell > /etc/skel/.config/kitty/current-theme.conf
/cat
cat > airootfs/etc/pacman.d/hooks.bin/kitty-remove << '/cat'
#!/bin/bash
rm /etc/skel/.config/kitty/current-theme.conf
/cat
cat > airootfs/etc/pacman.d/hooks.bin/shotcut-install << '/cat'
#!/bin/bash
ffmpeg \
  -i /usr/share/icons/hicolor/128x128/apps/org.shotcut.Shotcut.png \
  -vf scale=24:-1 \
  /usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
/cat
cat > airootfs/etc/pacman.d/hooks.bin/shotcut-remove << '/cat'
#!/bin/bash
rm /usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
/cat

# ref: https://wiki.archlinux.org/title/archiso#:~:text=passwd(5)%20syntax%3A-,archlive/airootfs/etc/passwd,-root%3Ax%3A0%3A0
cat > airootfs/etc/passwd << '/cat'
root:x:0:0:root:/root:/bin/bash
user:x:1000:1000::/home/user:/bin/bash
/cat

# ref: https://wiki.archlinux.org/title/archiso#:~:text=5).%20For%20example%3A-,archlive/airootfs/etc/shadow,-root%3A%3A14871%3A%3A%3A%3A%3A%3A%0Aarchie
# user:p@ssw0rd
cat > airootfs/etc/shadow << '/cat'
root::14871::::::
user:$6$Ckm3hL1yVkpajjT4$SLAN7xN8R/7A9FaB6JColbio0snA0t/GHKSwUZ0YukuOBdFdPl/nYh3qAcLZsJA7Vc28gIJ2Z7wM/lFgKpXVW.:14871::::::
/cat

mkdir airootfs/etc/skel
cat > airootfs/etc/skel/.bashrc << '/cat'
if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec weston
fi
export PS1='$(status=$?; [ $status -ne 0 ] && echo -n "=> \[\e[1;31m\]$status\[\e[m\] | ")\[\e[1;34m\]\w\[\e[m\] \[\e[1m\]->\[\e[m\] '
alias grep='grep --color'
alias ls='ls --color'
/cat
mkdir -p airootfs/etc/skel/.config/kitty
cat > airootfs/etc/skel/.config/kitty/kitty.conf << '/cat'
background_opacity 0.7
font_family Fira Code
include current-theme.conf
linux_display_server x11
/cat
cat > airootfs/etc/skel/.config/weston.ini << '/cat'
[core]
xwayland=true

[input-method]
path=/usr/bin/fcitx5

[keyboard]
keymap_layout=jp

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/gimp.png
icon=/usr/local/share/icons/Tela-circle/24x24/apps/gimp.png
path=/usr/bin/gimp

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/org.inkscape.Inkscape.png
icon=/usr/local/share/icons/Tela-circle/24x24/apps/inkscape.png
path=/usr/bin/inkscape

[launcher]
icon=/usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
path=/usr/bin/shotcut

[launcher]
#icon=/usr/share/icons/gnome/24x24/apps/utilities-terminal.png
icon=/usr/local/share/icons/Tela-circle/24x24/apps/kitty.png
path=/usr/bin/kitty

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-startcenter.png
icon=/usr/local/share/icons/Tela-circle/24x24/apps/libreoffice.png
path=/usr/bin/libreoffice

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/vivaldi.png
icon=/usr/local/share/icons/Tela-circle/24x24/apps/vivaldi.png
path=/usr/bin/vivaldi-stable

[output]
#scale=2

[shell]
background-image=/usr/share/backgrounds/archlinux/awesome.png
background-type=scale-crop
clock-format=none
panel-position=left
/cat
cat > airootfs/etc/skel/.pam_environment << '/cat'
# for kitty
GLFW_IM_MODULE=ibus

GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
/cat
mkdir -p airootfs/etc/sudoers.d
cat > airootfs/etc/sudoers.d/wheel << '/cat'
%wheel ALL=(ALL) ALL
/cat
mkdir airootfs/etc/systemd/system/getty@tty1.service.d

# ref: https://wiki.archlinux.org/title/archiso#:~:text=%5BService%5D%0AExecStart%3D%0AExecStart%3D%2D/sbin/agetty%20%2D%2Dautologin%20username%20%2D%2Dnoclear%20%25I%2038400%20linux
cat > airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf << '/cat'
[Service]
ExecStart=
#ExecStart=-/sbin/agetty --autologin username --noclear %I 38400 linux
ExecStart=-/sbin/agetty --autologin user --noclear %I 38400 linux
/cat

cat > airootfs/etc/vconsole.conf << '/cat'
KEYMAP=jp106
/cat
ln -s /usr/lib/systemd/system/NetworkManager.service airootfs/etc/systemd/system/multi-user.target.wants/
cat >> packages.x86_64 << '/cat'
archlinux-wallpaper
fcitx5-im
fcitx5-mozc
ffmpeg
gimp
gnome-icon-theme
inkscape
kitty
libreoffice-fresh
libreoffice-fresh-ja
neovim
networkmanager
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
shotcut
sudo
ttf-fira-code
vivaldi
vivaldi-ffmpeg-codecs
weston
xorg-xwayland
/cat

(
  cd $(mktemp -d)
  git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git .
  mkdir -p "$OLDPWD/airootfs/usr/local/share/icons/Tela-circle/24x24/apps"
  cat << /cat | xargs -I{} -P0 -n1 ffmpeg \
    -width 24 \
    -i src/scalable/apps/{}.svg \
    "$OLDPWD/airootfs/usr/local/share/icons/Tela-circle/24x24/apps/{}.png"
gimp
inkscape
kitty
libreoffice
vivaldi
/cat
  cd
  rm -fr $OLDPWD
)

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/baseline/profiledef.sh
# ref: https://wiki.archlinux.org/title/archiso#:~:text=the%20correct%20permissions%3A-,archlive/profiledef.sh,-...%0Afile_permissions%3D(%0A%20%20...%0A%20%20%5B%22/etc/shadow
cat > profiledef.sh << '/cat'
#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-baseline"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux baseline"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:0400"
  ["/etc/pacman.d/hooks.bin/kitty-install"]="0:0:755"
  ["/etc/pacman.d/hooks.bin/kitty-remove"]="0:0:755"
  ["/etc/pacman.d/hooks.bin/shotcut-install"]="0:0:755"
  ["/etc/pacman.d/hooks.bin/shotcut-remove"]="0:0:755"
)
/cat

mkarchiso -v .