#!/bin/bash
set -eu

# ref: https://askubuntu.com/a/15856
if ((EUID)); then
  echo 'This script must be run as root'
  exit 1
fi

pacman --needed --noconfirm -Sy - << '/pacman'
archiso
ffmpeg
git
make
/pacman
rm -fr archlive
cp -r /usr/share/archiso/configs/baseline archlive
cd archlive

# lnw - ln wrapper
lnw() { to="$1"; from="$2"; shift; shift
  dir=airootfs
  mkdir -p "$(dirname "$dir/$from")"
  ln "$@" -s "$to" "$dir/$from" && echo -e "${FUNCNAME[0]}: created "'\e[1;36msymlink\e[m'": '/$from' -> '$to'"
}

# teew - tee wrapper
teew() { file="$1"; shift
  dir=airootfs
  mkdir -p "$(dirname "$dir/$file")"
  tee "$@" "$dir/$file" > /dev/null && echo -e "${FUNCNAME[0]}: created "'\e[1mfile\e[m'": '/$file'"
}

teew etc/environment << '_'
EDITOR=/usr/bin/micro
_

# ref: https://wiki.archlinux.org/title/archiso#:~:text=5).%20For%20example%3A-,archlive/airootfs/etc/group,-root%3Ax%3A0%3Aroot
teew etc/group << '_'
root:x:0:root
wheel:x:10:user
user:x:1000:
docker:x:999:user
_

# ref: https://wiki.archlinux.org/title/archiso#:~:text=to%20gshadow(5)%3A-,archlive/airootfs/etc/gshadow,-root%3A!*%3A%3Aroot%0Aarchie
teew etc/gshadow << '_'
root:!*::root
user:!*::
_

teew etc/hostname << '_'
earth
_
teew etc/locale.conf << '_'
LANG=ja_JP.UTF-8
_
lnw /usr/share/zoneinfo/Asia/Tokyo etc/localtime
teew etc/pacman.conf << '_'
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
#Color
#NoProgressBar
# We cannot check disk space from within a chroot environment
#CheckSpace
#VerbosePkgLists
ParallelDownloads = 5

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

# NOTE: You must run `pacman-key --init` before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux
# packagers with `pacman-key --populate archlinux`.

#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#   - URLs will have $repo replaced by the name of the current repo
#   - URLs will have $arch replaced by the name of the architecture
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#

# The testing repositories are disabled by default. To enable, uncomment the
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.

#[testing]
#Include = /etc/pacman.d/mirrorlist

#[core]
#Include = /etc/pacman.d/mirrorlist

#[extra]
#Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

#[community]
#Include = /etc/pacman.d/mirrorlist

# If you want to run 32 bit applications on your x86_64 system,
# enable the multilib repositories as required here.

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

#[multilib]
#Include = /etc/pacman.d/mirrorlist

# An example of a custom package repository.  See the pacman manpage for
# tips on creating your own repositories.
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs

[live]
SigLevel = Optional
Server = file:///live
_

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/40-locale-gen.hook
teew etc/pacman.d/hooks/40-locale-gen.hook << '_'
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
_

teew etc/pacman.d/hooks/shotcut-install.hook << '_'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = shotcut

[Action]
Description = Creating a Shotcut 24x24 icon...
When = PostTransaction
Exec = /etc/pacman.d/hooks.bin/shotcut-install
_
teew etc/pacman.d/hooks/shotcut-remove.hook << '_'
[Trigger]
Operation = Remove
Type = Package
Target = shotcut

[Action]
Description = Removing a Shotcut 24x24 icon...
When = PreTransaction
Exec = /etc/pacman.d/hooks.bin/shotcut-remove
_

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/uncomment-mirrors.hook
teew etc/pacman.d/hooks/uncomment-mirrors.hook << '_'
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
_

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/releng/airootfs/etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook
teew etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook << '_'
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
_

teew etc/pacman.d/hooks.bin/shotcut-install << '_'
#!/bin/bash
ffmpeg \
  -i /usr/share/icons/hicolor/128x128/apps/org.shotcut.Shotcut.png \
  -vf scale=24:-1 \
  /usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
_
teew etc/pacman.d/hooks.bin/shotcut-remove << '_'
#!/bin/bash
rm /usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
_

# ref: https://wiki.archlinux.org/title/archiso#:~:text=passwd(5)%20syntax%3A-,archlive/airootfs/etc/passwd,-root%3Ax%3A0%3A0
teew etc/passwd << '_'
root:x:0:0:root:/root:/bin/bash
user:x:1000:1000::/home/user:/bin/bash
_

# ref: https://wiki.archlinux.org/title/archiso#:~:text=5).%20For%20example%3A-,archlive/airootfs/etc/shadow,-root%3A%3A14871%3A%3A%3A%3A%3A%3A%0Aarchie
# user:p@ssw0rd
teew etc/shadow << '_'
root::14871::::::
user:$6$Ckm3hL1yVkpajjT4$SLAN7xN8R/7A9FaB6JColbio0snA0t/GHKSwUZ0YukuOBdFdPl/nYh3qAcLZsJA7Vc28gIJ2Z7wM/lFgKpXVW.:14871::::::
_

teew etc/skel/.bashrc << '_'
if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  [ ! -f ~/.config/user-dirs.dirs ] && xdg-user-dirs-update
  #weston 2>&1 | less
  exec weston
fi

# Disable ble.sh
#BLE_DISABLED=1

if ((! BLE_DISABLED)) && [ ! -d ~/.local/share/blesh ]; then
  ! type \
    git \
    make \
    &> /dev/null \
      && break
  echo 'Installing ble.sh...'
  (
    cd $(mktemp -d)
    git clone \
      --depth=1 \
      --recursive \
      --shallow-submodules \
      https://github.com/akinomyoga/ble.sh.git \
      .
    make install PREFIX=~/.local
    cd
    rm -fr $OLDPWD
  )
fi

# ref: https://github.com/akinomyoga/ble.sh#:~:text=top%20of%20.bashrc%3A-,%5B%5B%20%24%2D%20%3D%3D%20*i*%20%5D%5D%20%26%26%20source%20/path/to/blesh/ble.sh%20%2D%2Dnoattach,-%23%20your%20bashrc%20settings
[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach

set -o vi
export PS1='$(status=$?; [ $status -ne 0 ] && echo -n "=> \[\e[1;31m\]$status\[\e[m\] | ")\[\e[1;34m\]\w\[\e[m\] \[\e[1m\]->\[\e[m\] '
export PS2='->> '
export PS3='=> '
export PS4='=>> \[\e[1;32m\]$0\[\e[m\]:\[\e[1;34m\]$LINENO\[\e[m\] -> '
if ((! BLE_DISABLED)); then
  ble-import vim-airline
  bleopt exec_errexit_mark=
  bleopt vim_airline_theme=light
  ble-bind -f 'j j' vi_imap/normal-mode
fi
alias editor="$EDITOR"
alias grep='grep --color'
alias ls='ls --color'

# ref: https://github.com/akinomyoga/ble.sh#:~:text=%5B%5B%20%24%7BBLE_VERSION%2D%7D%20%5D%5D%20%26%26%20ble%2Dattach
[[ ${BLE_VERSION-} ]] && ble-attach
_
teew etc/skel/.config/gtk-3.0/settings.ini << '_'
[Settings]
gtk-cursor-theme-name=Fuchsia
_
curl \
  --create-dirs \
  -o airootfs/etc/skel/.config/kitty/current-theme.conf \
  -s \
  https://raw.githubusercontent.com/kovidgoyal/kitty-themes/master/themes/PaperColor_light.conf
teew etc/skel/.config/kitty/kitty.conf << '_'
background_opacity 0.8
font_family Fira Code
include current-theme.conf
linux_display_server x11
_
teew etc/skel/.config/pcmanfm-qt/default/settings.conf << '_'
[System]
FallbackIconThemeName=Tela-circle
_
lnw /usr/lib/systemd/user/pipewire-pulse.service etc/skel/.config/systemd/user/default.target.wants/pipewire-pulse.service
lnw /usr/lib/systemd/user/pipewire.service etc/skel/.config/systemd/user/default.target.wants/pipewire.service
lnw /usr/lib/systemd/user/pipewire-media-session.service etc/skel/.config/systemd/user/pipewire-session-manager.service
lnw /usr/lib/systemd/user/pipewire-media-session.service etc/skel/.config/systemd/user/pipewire.service.wants/pipewire-media-session.service
lnw /usr/lib/systemd/user/pipewire-pulse.socket etc/skel/.config/systemd/user/sockets.target.wants/pipewire-pulse.socket
lnw /usr/lib/systemd/user/pipewire.socket etc/skel/.config/systemd/user/sockets.target.wants/pipewire.socket
teew etc/skel/.config/weston.ini << '_'
[core]
xwayland=true

[input-method]
path=/usr/bin/fcitx5

[keyboard]
keymap_layout=jp

[launcher]
icon=/usr/share/icons-24x24/freecad.png
path=/usr/bin/FreeCAD

[launcher]
icon=/usr/share/icons-24x24/blender.png
path=/usr/bin/blender

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/gimp.png
icon=/usr/share/icons-24x24/gimp.png
path=/usr/bin/gimp

[launcher]
icon=/usr/share/icons-24x24/htop.png
path=/usr/bin/kitty htop

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/org.inkscape.Inkscape.png
icon=/usr/share/icons-24x24/inkscape.png
path=/usr/bin/inkscape

[launcher]
#icon=/usr/share/icons/gnome/24x24/apps/utilities-terminal.png
icon=/usr/share/icons-24x24/kitty.png
path=/usr/bin/kitty

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-startcenter.png
icon=/usr/share/icons-24x24/libreoffice.png
path=/usr/bin/libreoffice

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-base.png
#icon=/usr/share/icons-24x24/libreoffice-base.png
#path=/usr/bin/libreoffice --base

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-calc.png
#icon=/usr/share/icons-24x24/libreoffice-calc.png
#path=/usr/bin/libreoffice --calc

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-draw.png
#icon=/usr/share/icons-24x24/libreoffice-draw.png
#path=/usr/bin/libreoffice --draw

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-impress.png
#icon=/usr/share/icons-24x24/libreoffice-impress.png
#path=/usr/bin/libreoffice --impress

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-math.png
#icon=/usr/share/icons-24x24/libreoffice-math.png
#path=/usr/bin/libreoffice --math

#[launcher]
##icon=/usr/share/icons/hicolor/24x24/apps/libreoffice-writer.png
#icon=/usr/share/icons-24x24/libreoffice-writer.png
#path=/usr/bin/libreoffice --writer

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/mscore.png
icon=/usr/share/icons-24x24/musescore.png
path=/usr/bin/mscore

[launcher]
icon=/usr/share/icons-24x24/nomacs.png
path=/usr/bin/nomacs

#[launcher]
#icon=/usr/share/icons-24x24/neovim.png
#path=/usr/bin/kitty nvim

[launcher]
icon=/usr/share/icons-24x24/file-manager.png
path=/usr/bin/pcmanfm-qt

#[launcher]
#icon=/usr/share/icons-24x24/python.png
#path=/usr/bin/kitty python

[launcher]
icon=/usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
path=/usr/bin/shotcut

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/signal-desktop.png
icon=/usr/share/icons-24x24/signal-desktop.png
path=/usr/bin/signal-desktop

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/vivaldi.png
icon=/usr/share/icons-24x24/vivaldi.png
path=/usr/bin/vivaldi-stable

#[launcher]
#icon=/usr/share/favicons-24x24/app.diagrams.net.png
#path=/usr/bin/vivaldi-stable --app=https://app.diagrams.net/ --new-window

#[launcher]
#icon=/usr/share/favicons-24x24/codepen.io.png
#path=/usr/bin/vivaldi-stable --app=https://codepen.io/ --new-window

#[launcher]
#icon=/usr/share/favicons-24x24/diep.io.png
#path=/usr/bin/vivaldi-stable --app=https://diep.io/ --new-window

#[launcher]
##icon=/usr/share/favicons-24x24/github.com.png
#icon=/usr/share/icons-24x24/github.png
#path=/usr/bin/vivaldi-stable --app=https://github.com/ --new-window

#[launcher]
##icon=/usr/share/favicons-24x24/earth.google.com.web.png
#icon=/usr/share/icons-24x24/google-earth.png
#path=/usr/bin/vivaldi-stable --app=https://earth.google.com/web/ --new-window

[launcher]
icon=/usr/share/favicons-24x24/meet.google.com.png
path=/usr/bin/vivaldi-stable --app=https://meet.google.com/ --new-window

#[launcher]
#icon=/usr/share/favicons-24x24/squoosh.app.png
#path=/usr/bin/vivaldi-stable --app=https://squoosh.app/ --new-window

#[launcher]
##icon=/usr/share/favicons-24x24/vscode.dev.png
#icon=/usr/share/icons-24x24/visualstudiocode.png
#path=/usr/bin/vivaldi-stable --app=https://vscode.dev/ --new-window

#[launcher]
#icon=/usr/share/favicons-24x24/www.mathcha.io.editor.png
#path=/usr/bin/vivaldi-stable --app=https://www.mathcha.io/editor --new-window

[launcher]
icon=/usr/share/favicons-24x24/www.wikipedia.org.png
path=/usr/bin/vivaldi-stable --app=https://www.wikipedia.org/ --new-window

[launcher]
icon=/usr/share/favicons-24x24/www.wolframalpha.com.png
path=/usr/bin/vivaldi-stable --app=https://www.wolframalpha.com/ --new-window

[launcher]
#icon=/usr/share/favicons-24x24/www.youtube.com.png
icon=/usr/share/icons-24x24/youtube.png
path=/usr/bin/vivaldi-stable --app=https://www.youtube.com/ --new-window

#[launcher]
#icon=/usr/share/favicons-24x24/zenn.dev.png
#path=/usr/bin/vivaldi-stable --app=https://zenn.dev/ --new-window

[launcher]
icon=/usr/share/icons-24x24/vlc.png
path=/usr/bin/vlc

[output]

## For HiDPI display users, set name and scale field
#name=HDMI-A-1
#scale=2

[shell]
background-image=/usr/share/backgrounds/default.jpg
background-type=scale-crop
clock-format=none
cursor-size=24
cursor-theme=Fuchsia
panel-color=0xccffffff
panel-position=left
_
(
  cd $(mktemp -d)
  git clone \
    --depth=1 \
    --recursive \
    --shallow-submodules \
    https://github.com/akinomyoga/ble.sh.git \
    .
  make install PREFIX="$OLDPWD/airootfs/etc/skel/.local"
  cd
  rm -fr $OLDPWD
)
teew etc/skel/.local/share/icons/default/index.theme << '_'
[Icon Theme]
Inherits=Fuchsia
_
teew etc/skel/.pam_environment << '_'
# for kitty
GLFW_IM_MODULE=ibus

GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
QT_QPA_PLATFORM=wayland
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
_
teew etc/sudoers.d/user << '_'
user ALL=NOPASSWD: ALL
_

# ref: https://wiki.archlinux.org/title/archiso#:~:text=%5BService%5D%0AExecStart%3D%0AExecStart%3D%2D/sbin/agetty%20%2D%2Dautologin%20username%20%2D%2Dnoclear%20%25I%2038400%20linux
teew etc/systemd/system/getty@tty1.service.d/autologin.conf << '_'
[Service]
ExecStart=
#ExecStart=-/sbin/agetty --autologin username --noclear %I 38400 linux
ExecStart=-/sbin/agetty --autologin user --noclear %I 38400 linux
_

teew etc/vconsole.conf << '_'
KEYMAP=jp106
_
lnw /usr/lib/systemd/system/NetworkManager.service etc/systemd/system/multi-user.target.wants/NetworkManager.service
lnw /usr/lib/systemd/system/docker.service etc/systemd/system/multi-user.target.wants/docker.service
curl \
  --create-dirs \
  -o airootfs/usr/share/backgrounds/default.jpg \
  -s \
  'https://images.pexels.com/photos/2138922/pexels-photo-2138922.jpeg?crop=entropy&cs=srgb&dl=pexels-kyle-roxas-2138922.jpg&fit=crop&fm=jpg&h=2880&w=5120'
(
  mkdir -p airootfs/live
  cd airootfs/live
  temp=$(mktemp -d)
  trap "rm -fr $temp" EXIT
  pacman --cachedir "$(pwd)" --dbpath $temp -Swy - << '/pacman'
base
linux
linux-firmware
/pacman
  repo-add live.db.tar.gz *.pkg.tar.*
)
cat >> packages.x86_64 << '/cat'
blender
docker
docker-compose
fcitx5-im
fcitx5-mozc
ffmpeg
freecad
gimp
gnome-icon-theme
gvfs
htop
inkscape
kitty
libreoffice-fresh
libreoffice-fresh-ja
micro
musescore
neovim
networkmanager
nomacs
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
pcmanfm-qt
pipewire
pipewire-pulse
python
qt5-wayland
shotcut
signal-desktop
sudo
tmux
ttf-fira-code
ttf-ibm-plex
vivaldi
vivaldi-ffmpeg-codecs
vlc
weston
xdg-user-dirs
xorg-drivers
xorg-xwayland
/cat

grep -v '^#' > usr/share/favicons-24x24/list << '/grep'
#app.diagrams.net https://app.diagrams.net/
#codepen.io https://codepen.io/
#diep.io https://diep.io/
#earth.google.com.web https://earth.google.com/web/
#github.com https://github.com/
meet.google.com https://meet.google.com/
#squoosh.app https://squoosh.app/
#vscode.dev https://vscode.dev/
#www.mathcha.io.editor https://www.mathcha.io/editor
www.wikipedia.org https://www.wikipedia.org/
www.wolframalpha.com https://www.wolframalpha.com/
www.youtube.com https://www.youtube.com/
#zenn.dev https://zenn.dev/
/grep
teew usr/share/favicons-24x24/update.sh << '_'
#!/bin/bash
cwd="$(cd "$(dirname "$0")" && pwd)"
ls "$cwd" | grep '.png$' | xargs -r rm
cat "$cwd/list" | while read name domain_url; do
  curl -so "$cwd/$name.png" "https://www.google.com/s2/favicons?domain_url=$domain_url&sz=24"
done
_
bash airootfs/usr/share/favicons-24x24/update.sh
mkdir airootfs/usr/share/icons
curl -Ls \
  https://github.com/ful1e5/fuchsia-cursor/releases/download/v1.0.5/Fuchsia.tar.gz \
  | tar \
    -C airootfs/usr/share/icons \
    -xzf -
grep -v '^#' > airootfs/usr/share/icons-24x24/list << '/grep'
blender
file-manager
freecad
gimp
#github
#google-earth
htop
inkscape
kitty
libreoffice
#libreoffice-base
#libreoffice-calc
#libreoffice-draw
#libreoffice-impress
#libreoffice-math
#libreoffice-writer
musescore
#neovim
nomacs
#python
signal-desktop
#visualstudiocode
vivaldi
vlc
youtube
/grep
teew usr/share/icons-24x24/update.sh << '_'
#!/bin/bash
cwd="$(cd "$(dirname "$0")" && pwd)"
install_dir="$(cd "$cwd/../icons" && pwd)"
cd $(mktemp -d)
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git .
ls "$cwd" | grep '.png$' | xargs -r rm
cat "$cwd/list" | xargs -I{} -P0 -n1 ffmpeg \
  -width 24 \
  -i src/scalable/apps/{}.svg \
  "$cwd/{}.png"
sed -i 's/\(gtk-update-icon-cache\)/#\1/' install.sh
./install.sh -d "$install_dir"
cd
rm -fr $OLDPWD
_
bash airootfs/usr/share/icons-24x24/update.sh

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
  ["/etc/pacman.d/hooks.bin/shotcut-install"]="0:0:755"
  ["/etc/pacman.d/hooks.bin/shotcut-remove"]="0:0:755"
  ["/usr/share/favicons-24x24/update.sh"]="0:0:755"
  ["/usr/share/icons-24x24/update.sh"]="0:0:755"
)
/cat

mkarchiso -v .