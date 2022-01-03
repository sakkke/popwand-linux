#!/bin/bash
set -eu
error() {
	echo -e "\\e[31m$*\\e[m"
}

# ref: https://askubuntu.com/a/15856
if ((EUID)); then
	error 'This script must be run as root'
	exit 1
fi

self="$(realpath "$0")"
pacman --needed --noconfirm -Sy - << '/pacman'
archiso
base-devel
darkhttpd
ffmpeg
git
unzip
weston
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

cat > packages.list << '/cat'
arch-install-scripts
base-devel
blender
brightnessctl
deno
docker
docker-compose
ed
fcitx5-im
fcitx5-mozc
ffmpeg
firewalld
freecad
freerdp
gimp
gnome-icon-theme
gparted
gvfs
htop
inkscape
jdk-openjdk
kitty
libreoffice-fresh
libreoffice-fresh-ja
man
micro
musescore
neovim
networkmanager
nomacs
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
pamixer
pcmanfm-qt
pipewire
pipewire-pulse
python
qt5-wayland
shotcut
signal-desktop
tmux
ttf-fira-code
ttf-ibm-plex
virtualbox
virtualbox-guest-iso
virtualbox-host-modules-arch
vivaldi
vivaldi-ffmpeg-codecs
vlc
weston
xdg-user-dirs
xorg-drivers
xorg-xhost
xorg-xwayland
/cat
cat packages.list >> packages.x86_64
cat > pacman.conf << '/cat'
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
Color
#NoProgressBar
# We cannot check disk space from within a chroot environment
#CheckSpace
#VerbosePkgLists
ParallelDownloads = 5
ILoveCandy

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

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

#[community-testing]
#Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

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
/cat
pacman --noconfirm -Swy - < packages.x86_64
teew etc/environment << '_' # use;
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
popwlive
_
teew etc/locale.conf << '_' # use;
LANG=ja_JP.UTF-8
_
lnw /usr/share/zoneinfo/Asia/Tokyo etc/localtime -f # use;
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
Color
#NoProgressBar
# We cannot check disk space from within a chroot environment
#CheckSpace
#VerbosePkgLists
ParallelDownloads = 5
ILoveCandy

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

teew etc/pacman.d/hooks/shotcut-install.hook << '_' # use;
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
teew etc/pacman.d/hooks/shotcut-remove.hook << '_' # use;
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

teew etc/pacman.d/hooks.bin/shotcut-install << '_' # use;
#!/bin/bash
ffmpeg \
	-i /usr/share/icons/hicolor/128x128/apps/org.shotcut.Shotcut.png \
	-vf scale=24:-1 \
	/usr/share/icons/hicolor/24x24/apps/org.shotcut.Shotcut.png
_
teew etc/pacman.d/hooks.bin/shotcut-remove << '_' # use;
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

# ref: https://asdf-vm.com/guide/getting-started.html#_2-download-asdf
git clone https://github.com/asdf-vm/asdf.git airootfs/etc/skel/.asdf --branch v0.8.1

teew etc/skel/.bashrc << '_' # use;
if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
	[ ! -f ~/.config/user-dirs.dirs ] && xdg-user-dirs-update

	: 'For RDP session' || {
		[ ! -f tls.key ] && openssl genrsa -out tls.key 2048
		[ ! -f tls.csr ] && openssl req -new -key tls.key -out tls.csr
		[ ! -f tls.crt ] && openssl x509 -req -days 365 -signkey tls.key -in tls.csr -out tls.crt
		exec weston --backend=rdp-backend.so --rdp-tls-cert=tls.crt --rdp-tls-key=tls.key
	}

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
alias ed="$(echo -e 'ed -p"(ed) \e[1m->\e[m "')"
alias en='nvim -c"se nu" -e' # ex powered nvim
alias ev='vim -c"se nu" -e' # ex powered vim
alias ex='ex -c"se nu"'
alias editor="$EDITOR"
alias grep='grep --color'
alias ls='ls --color'

# ref: https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# ref: https://github.com/akinomyoga/ble.sh#:~:text=%5B%5B%20%24%7BBLE_VERSION%2D%7D%20%5D%5D%20%26%26%20ble%2Dattach
[[ ${BLE_VERSION-} ]] && ble-attach
_
teew etc/skel/.config/fontconfig/fonts.conf << '_' # use;
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Rounded M+ 1c</family>
		</prefer>
	</alias>
</fontconfig>
_
teew etc/skel/.config/gtk-3.0/settings.ini << '_' # use;
[Settings]
gtk-cursor-theme-name=Fuchsia
_
curl \
	--create-dirs \
	-o airootfs/etc/skel/.config/kitty/current-theme.conf \
	-s \
	https://raw.githubusercontent.com/kovidgoyal/kitty-themes/master/themes/PaperColor_light.conf
teew etc/skel/.config/kitty/kitty.conf << '_' # use;
background_opacity 0.8
font_family Fira Code
include current-theme.conf
linux_display_server x11
_
teew etc/skel/.config/pcmanfm-qt/default/settings.conf << '_' # use;
[System]
FallbackIconThemeName=Tela-circle
_
lnw /usr/lib/systemd/user/pipewire-pulse.service etc/skel/.config/systemd/user/default.target.wants/pipewire-pulse.service # use;
lnw /usr/lib/systemd/user/pipewire.service etc/skel/.config/systemd/user/default.target.wants/pipewire.service # use;
lnw /usr/lib/systemd/user/pipewire-media-session.service etc/skel/.config/systemd/user/pipewire-session-manager.service # use;
lnw /usr/lib/systemd/user/pipewire-media-session.service etc/skel/.config/systemd/user/pipewire.service.wants/pipewire-media-session.service # use;
lnw /usr/lib/systemd/user/pipewire-pulse.socket etc/skel/.config/systemd/user/sockets.target.wants/pipewire-pulse.socket # use;
lnw /usr/lib/systemd/user/pipewire.socket etc/skel/.config/systemd/user/sockets.target.wants/pipewire.socket # use;
teew etc/skel/.config/weston.ini << '_' # use;
[core]
modules=binder.so
xwayland=true

[input-method]
path=/usr/bin/fcitx5

[keybind]
exec=brightnessctl set 5%-
key=brightnessdown

[keybind]
exec=brightnessctl set +5%
key=brightnessup

[keybind]
exec=kitty sudo /installer
key=super+f1

[keybind]
exec=pamixer -t
key=mute

[keybind]
exec=pamixer -d 5
key=volumedown

[keybind]
exec=pamixer -i 5
key=volumeup

[keybind]
exec=vivaldi-stable
key=super+1

[keybind]
exec=kitty pmw-console
key=super+delete

[keybind]
exec=pcmanfm-qt
key=super+e

[keybind]
exec=kitty
key=super+enter

[keybind]
exec=kitty btop
key=super+esc

[keyboard]
keymap_layout=jp

[launcher]
icon=/usr/share/icons-24x24/system-log-out.png
path=/usr/bin/kitty pmw-console

[launcher]
icon=/usr/share/icons-24x24/system-os-install.png
path=/usr/bin/kitty sudo /installer

[launcher]
icon=/usr/share/icons-24x24/freecad.png
path=/usr/bin/FreeCAD

[launcher]
icon=/usr/share/icons-24x24/virtualbox.png
path=/usr/bin/VirtualBox

[launcher]
icon=/usr/share/icons-24x24/blender.png
path=/usr/bin/blender

[launcher]
icon=/usr/share/icons-24x24/utilities-system-monitor.png
path=/usr/bin/kitty btop

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/firewall-config.png
icon=/usr/share/icons-24x24/gufw.png
path=/usr/bin/x-app-as-root firewall-config

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/gimp.png
icon=/usr/share/icons-24x24/gimp.png
path=/usr/bin/gimp

[launcher]
#icon=/usr/share/icons/hicolor/24x24/apps/gparted.png
icon=/usr/share/icons-24x24/gparted.png
path=/usr/bin/x-app-as-root gparted

#[launcher]
#icon=/usr/share/icons-24x24/htop.png
#path=/usr/bin/kitty htop

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

[launcher]
icon=/usr/share/favicons-24x24/www.deepl.com.translator.png
path=/usr/bin/vivaldi-stable --app=https://www.deepl.com/translator --new-window

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
teew etc/skel/.local/share/icons/default/index.theme << '_' # use;
[Icon Theme]
Inherits=Fuchsia
_
teew etc/skel/.pam_environment << '_' # use;
# for kitty
GLFW_IM_MODULE=ibus

GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
QT_QPA_PLATFORM=wayland
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
_
teew etc/skel/.tmux.conf << '_' # use;
# ref: https://github.com/tmux-plugins/tpm/issues/105#issue-204507647
setenv -g TMUX_PLUGIN_MANAGER_PATH ~/.tmux/plugins

# ref: https://github.com/tmux-plugins/tpm/blob/master/docs/automatic_tpm_installation.md#automatic-tpm-installation
if "test ! -d ~/.tmux/plugins/tpm" \
	 "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

# Settings
set -g default-terminal tmux-256color
set -g mouse on

# Plugins
set -g @plugin wfxr/tmux-power

# Plugin settings
set -g @tmux_power_theme snow

run ~/.tmux/plugins/tpm/tpm
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

teew etc/vconsole.conf << '_' # use;
KEYMAP=jp106
_
lnw /usr/lib/systemd/system/firewalld.service etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service # use;
lnw /usr/lib/systemd/system/NetworkManager.service etc/systemd/system/multi-user.target.wants/NetworkManager.service # use;
lnw /usr/lib/systemd/system/docker.service etc/systemd/system/multi-user.target.wants/docker.service # use;
lnw /usr/lib/systemd/system/firewalld.service etc/systemd/system/multi-user.target.wants/firewalld.service # use;
curl \
	--create-dirs \
	-o airootfs/usr/share/backgrounds/default.jpg \
	-s \
	'https://images.pexels.com/photos/2138922/pexels-photo-2138922.jpeg?crop=entropy&cs=srgb&dl=pexels-kyle-roxas-2138922.jpg&fit=crop&fm=jpg&h=2880&w=5120'
teew installer << '_'
#!/bin/bash
set -eu
trap 'read -p"Press any key to continue..."' EXIT
error() {
	echo -e "\\e[31m$*\\e[m"
}

# ref: https://askubuntu.com/a/15856
if ((EUID)); then
	error 'This script must be run as root'
	exit 1
fi

cd /

# cpw - cp wrapper
cpw() { from="$1"; to="$2"; shift; shift
	dir=mnt
	mkdir -p "$(dirname "$dir/$to")"
	cp "$@" -p "$from" "$dir/$to" && echo -e "${FUNCNAME[0]}: created: '/$to'"
}
export -f cpw

list_devices() {
	ls /dev \
		| grep '^\(mmcblk[0-9]\+\|nvme[0-9]\+n[0-9]\+\|sd[a-z]\+\)$'
}
list_partitions() {
	ls /dev \
		| grep '^\(mmcblk[0-9]\+p[0-9]\+\|nvme[0-9]\+n[0-9]\+p[0-9]\+\|sd[a-z]\+[0-9]\+\)$'
}

# lnw - ln wrapper
lnw() { to="$1"; from="$2"; shift; shift
	dir=mnt
	mkdir -p "$(dirname "$dir/$from")"
	ln "$@" -s "$to" "$dir/$from" && echo -e "${FUNCNAME[0]}: created "'\e[1;36msymlink\e[m'": '/$from' -> '$to'"
}

# teew - tee wrapper
teew() { file="$1"; shift
	dir=mnt
	mkdir -p "$(dirname "$dir/$file")"
	tee "$@" "$dir/$file" > /dev/null && echo -e "${FUNCNAME[0]}: created "'\e[1mfile\e[m'": '/$file'"
}

echo 'Select installation type'
select installation_type in 'custom (recommended)' auto; do
	if [ ! -z "$installation_type" ]; then
		break
	else
		error 'Input is expected to be "1" or "2"'
	fi
done
case "$installation_type" in
	auto )
		echo 'Select device'
		select _device in $(list_devices); do
			if file /dev/$_device; then
				device=/dev/$_device$(grep '^[mn]' <<< $_device > /dev/null && echo p; :)
				parted -s /dev/$_device \
					mklabel gpt \
					mkpart popwesp fat32 0% 512Mib \
					set 1 esp on \
					mkpart popwboot fat32 512Mib 1536Mib \
					set 2 bls_boot on \
					mkpart popwroot ext4 1536Mib 100%
				mkfs.fat -F32 ${device}1
				mkfs.fat -F32 ${device}2
				mkfs.ext4 -F ${device}3
				popwesp=${device}1
				popwboot=${device}2
				popwroot=${device}3
				break
			fi
		done
		;;

	'custom (recommended)' )
		echo 'Select EFI system partition'
		select _popwesp in $(list_partitions); do
			if file /dev/$_popwesp; then
				popwesp=/dev/$_popwesp
				break
			fi
		done
		echo 'Select boot partition'
		select _popwboot in $(list_partitions); do
			if file /dev/$_popwboot; then
				popwboot=/dev/$_popwboot
				break
			fi
		done
		echo 'Select root partition'
		select _popwroot in $(list_partitions); do
			if file /dev/$_popwroot; then
				popwroot=/dev/$_popwroot
				break
			fi
		done
		;;
esac
echo -e '[\e[1mInstallation info\e[m]'
echo ---
{
	echo -e "\\e[1;31mInstallation type\\e[m: $installation_type"
	echo -e "\\e[1;33mDevice\\e[m: ${device:-\e[2mNONE, it is right\e[m}"
	echo -e "\\e[1;32mEFI system partition\\e[m: ${popwesp:-\e[2m${device}1\e[m}"
	echo -e "\\e[1;34mBoot partition\\e[m: ${popwboot:-\e[2m${device}2\e[m}"
	echo -e "\\e[1;33mRoot partition\\e[m: ${popwroot:-\e[2m${device}3\e[m}"
} | column -R1 -o: -s: -t
echo ---
while :; do
	read -p'Continue? [y/N] ' yorn
	case "$yorn" in
		'' | [Nn] )
			error 'Installation canceled'
			exit 1
			;;

		[Yy] )
			break
			;;

		* )
			error 'Input is expected to be "y" or "n"'
			;;
	esac
done

mount $popwroot /mnt
mkdir /mnt/{boot,efi}
mount $popwboot /mnt/boot
mount $popwesp /mnt/efi

cat /dev/urandom | gzip -1 > /dev/null &
pid=$!
pacman-key --init
pacman-key --populate archlinux
kill $pid
pacstrap /mnt - < /live/packages

genfstab -U /mnt >> /mnt/etc/fstab
_
{
	echo
	file="$self"
	cat -n "$file" | grep 'use;$' | while read n cmd _; do
		i=$n
		while :; do
			if [ $cmd = lnw ] || [ "$(sed -n ${i}p "$file")" = _ ]; then
				break
			else
				let i++
			fi
		done
		sed -n $n,${i}p "$file"
	done
	echo
} >> airootfs/installer
cat >> airootfs/installer << '_'
chmod 755 /mnt/etc/pacman.d/hooks.bin/shotcut-install
chmod 755 /mnt/etc/pacman.d/hooks.bin/shotcut-remove
cpw {/,}etc/skel/.asdf -r
cpw {/,}etc/skel/.config/kitty/current-theme.conf
sed -zi \
	's:[launcher]\nicon=/usr/share/icons-24x24/system-os-install.png\npath=/usr/bin/kitty sudo /installer\n\n::' \
	/mnt/etc/skel/.config/weston.ini
cpw {/,}etc/skel/.local/share/blesh -r
cpw {/,}etc/skel/.local/share/doc/blesh -r

arch-chroot /mnt /bin/bash << '/arch-chroot'
error() {
	echo -e "\\e[31m$*\\e[m"
}

hwclock --systohc

sed -i 's/#\(en_US\.UTF-8\|ja_JP\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

echo root:toor | chpasswd

[ -f /efi/efi/boot/bootx64.efi ] && cp /efi/efi/boot/bootx64.efi /boot/bootx64.efi.$(date +%s).bak
bootctl --boot-path=/boot --esp-path=/efi install

while :; do
	echo 'Enter a new user name'
	read -p'Username: ' username < /dev/tty
	if grep '^[_a-z][-0-9_a-z]\{0,16\}$' <<< "$username" > /dev/null; then
		useradd -Gdocker,wheel -m $username
		break
	else
		error "Input is expected to be '^[_a-z][-0-9_a-z]\\{0,16\\}$'"
	fi
done
while :; do
	if passwd $username < /dev/tty; then
		break
	else
		error "Could not set a password. Try again."
	fi
done
/arch-chroot

chmod 755 /mnt/usr/bin/btop
chmod 755 /mnt/usr/bin/pmw-console
chmod 755 /mnt/usr/bin/x-app-as-root
cpw {/,}usr/lib/weston/binder.so
chmod 755 /mnt/usr/lib/weston/binder.so
cpw {/,}usr/share/backgrounds/default.jpg
chmod 755 /mnt/usr/share/favicons-24x24/update.sh
ls /usr/share/favicons-24x24/ \
	| grep '.png$' \
	| xargs -I{} bash -c 'cpw /usr/share/favicons-24x24/{} usr/share/favicons-24x24/{}'
cpw {/,}usr/share/fonts/rounded-mplus -r
cpw {/,}usr/share/icons/Fuchsia -r
cpw {/,}usr/share/icons/Tela-circle -r
cpw {/,}usr/share/icons/Tela-circle-dark -r
chmod 755 /mnt/usr/share/icons-24x24/update.sh
ls /usr/share/icons-24x24/ \
	| grep '.png$' \
	| xargs -I{} bash -c 'cpw /usr/share/icons-24x24/{} usr/share/icons-24x24/{}'

teew boot/loader/entries/popw.conf << '$'
title Popwand Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=PARTLABEL=popwroot rw
$

teew efi/loader/loader.conf << '$'
default popw.conf
timeout 15
$

teew etc/hostname << $
popw-$(tr -dc '[:alnum:]' < /dev/urandom | fold -w8 | head -n1)
$

umount -R /mnt
echo 'Installation is complete!'
_
(
	mkdir -p airootfs/live
	cd airootfs/live
	temp=$(mktemp -d)
	trap "rm -fr $temp" EXIT
	cp "$OLDPWD/packages.list" packages
	cat <<- '/cat' | xargs -I{} sed -i '$a{}' packages
	base
	linux
	linux-firmware
	/cat
	cat <<- '/cat' | xargs -I{} sed -i '/^{}$/d' packages
	arch-install-scripts
	/cat
	mirrorlist=$(mktemp)
	cat > $mirrorlist <<- /cat
	Server = http://localhost:8888
	/cat
	ln -fs /var/lib/pacman/sync/community.db /var/cache/pacman/pkg/
	ln -fs /var/lib/pacman/sync/core.db /var/cache/pacman/pkg/
	ln -fs /var/lib/pacman/sync/extra.db /var/cache/pacman/pkg/
	darkhttpd /var/cache/pacman/pkg --port 8888 &
	pid=$!
	pacman --cachedir "$(pwd)" --config <(cat <<- /cat
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
	Color
	NoProgressBar
	# We cannot check disk space from within a chroot environment
	#CheckSpace
	#VerbosePkgLists
	ParallelDownloads = 5
	ILoveCandy

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
	#   - URLs will have \$repo replaced by the name of the current repo
	#   - URLs will have \$arch replaced by the name of the architecture
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

	[core]
	Include = $mirrorlist

	[extra]
	Include = $mirrorlist

	#[community-testing]
	#Include = /etc/pacman.d/mirrorlist

	[community]
	Include = $mirrorlist

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
	/cat
	) --dbpath $temp --noconfirm -Swy - < packages
	kill $pid
	rm $mirrorlist /var/cache/pacman/pkg/{community,core,extra}.db
	repo-add live.db.tar.gz *.pkg.tar.{xz,zst}
)

(
	cd $(mktemp -d)
	curl -Ls https://github.com/aristocratos/btop/releases/download/v1.1.4/btop-x86_64-linux-musl.tbz \
		| tar -jxf- bin/btop
	teew usr/bin/btop <  bin/btop
	cd
	rm -fr $OLDPWD
)
teew usr/bin/pmw-console << '_' # use;
#!/bin/bash

#: pmw-console - Power Management Wizard for console

error() {
	echo -e "\\e[31m$*\\e[m"
}

select action in cancel logout poweroff reboot; do
	case "$action" in
		'' )
			error 'Input is expected to be "1", "2", "3" or "4"'
			;;

		cancel )
			break
			;;

		logout )
			kill -9 -1
			exit $?
			;;

		poweroff )
			poweroff
			exit $?
			;;

		reboot )
			reboot
			exit $?
			;;
	esac
done
_
teew usr/bin/x-app-as-root << '_' # use;
#!/bin/bash
xhost si:localuser:root
trap 'xhost -si:localuser:root' EXIT
kitty sudo "$@"
_
(
	cd $(mktemp -d)
	git clone --depth=1 https://github.com/tarvi-verro/weston-binder.git .
	make
	mkdir -p "$OLDPWD/airootfs/usr/lib/weston"
	make install WESTON_MODPREFIX="$OLDPWD/airootfs/usr/lib/weston"
	cd
	rm -fr $OLDPWD
)
teew usr/share/favicons-24x24/list << '_' # use;
#app.diagrams.net https://app.diagrams.net/
#codepen.io https://codepen.io/
#diep.io https://diep.io/
#earth.google.com.web https://earth.google.com/web/
#github.com https://github.com/
meet.google.com https://meet.google.com/
#squoosh.app https://squoosh.app/
#vscode.dev https://vscode.dev/
www.deepl.com.translator https://www.deepl.com/translator
#www.mathcha.io.editor https://www.mathcha.io/editor
www.wikipedia.org https://www.wikipedia.org/
www.wolframalpha.com https://www.wolframalpha.com/
www.youtube.com https://www.youtube.com/
#zenn.dev https://zenn.dev/
_
teew usr/share/favicons-24x24/update.sh << '_' # use;
#!/bin/bash
cwd="$(cd "$(dirname "$0")" && pwd)"
ls "$cwd" | grep '.png$' | xargs -r rm
grep -v '^#' "$cwd/list" | while read name domain_url; do
	curl -so "$cwd/$name.png" "https://www.google.com/s2/favicons?domain_url=$domain_url&sz=24"
done
_
bash airootfs/usr/share/favicons-24x24/update.sh
(
	cd $(mktemp -d)
	curl -LOs https://osdn.jp/downloads/users/8/8574/rounded-mplus-20150529.zip
	mkdir -p "$OLDPWD/airootfs/usr/share/fonts/rounded-mplus"
	unzip -d "$OLDPWD/airootfs/usr/share/fonts/rounded-mplus" rounded-mplus-20150529.zip
	cd
	rm -fr $OLDPWD
)
mkdir -p airootfs/usr/share/icons
curl -Ls \
	https://github.com/ful1e5/fuchsia-cursor/releases/download/v1.0.5/Fuchsia.tar.gz \
	| tar \
		-C airootfs/usr/share/icons \
		-xzf -
teew usr/share/icons-24x24/list << '_' # use;
blender
file-manager
freecad
gimp
#github
#google-earth
gparted
gufw
#htop
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
system-log-out
system-os-install
utilities-system-monitor
virtualbox
#visualstudiocode
vivaldi
vlc
youtube
_
teew usr/share/icons-24x24/update.sh << '_' # use;
#!/bin/bash
cwd="$(cd "$(dirname "$0")" && pwd)"
install_dir="$(cd "$cwd/../icons" && pwd)"
cd $(mktemp -d)
git clone --depth=1 https://github.com/vinceliuice/Tela-circle-icon-theme.git .
ls "$cwd" | grep '.png$' | xargs -r rm
grep -v '^#' "$cwd/list" | xargs -I{} -P0 -n1 ffmpeg \
	-width 24 \
	-i src/scalable/apps/{}.svg \
	"$cwd/{}.png"
sed -i 's/\(gtk-update-icon-cache\)/#\1/' install.sh
./install.sh -c -d "$install_dir"
cd
rm -fr $OLDPWD
_
bash airootfs/usr/share/icons-24x24/update.sh

# ref: https://gitlab.archlinux.org/archlinux/archiso/-/blob/754caf0ca21476d52d8557058f665b9078982877/configs/baseline/profiledef.sh
# ref: https://wiki.archlinux.org/title/archiso#:~:text=the%20correct%20permissions%3A-,archlive/profiledef.sh,-...%0Afile_permissions%3D(%0A%20%20...%0A%20%20%5B%22/etc/shadow
cat > profiledef.sh << '/cat'
#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="popwandlinux-baseline"
iso_label="POPW_$(date +%Y%m)"
iso_publisher="Popwand Linux <https://github.com/sakkke/popwand-linux>"
iso_application="Popwand Linux baseline"
iso_version="$(date +%Y.%m.%d)"
install_dir="popw"
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
	["/installer"]="0:0:755"
	["/usr/bin/btop"]="0:0:755"
	["/usr/bin/pmw-console"]="0:0:755"
	["/usr/bin/x-app-as-root"]="0:0:755"
	["/usr/lib/weston/binder.so"]="0:0:755"
	["/usr/share/favicons-24x24/update.sh"]="0:0:755"
	["/usr/share/icons-24x24/update.sh"]="0:0:755"
)
/cat

mkarchiso -v .