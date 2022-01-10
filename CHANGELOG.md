# Changelog

## 2022-01-10
### Added
- add `https://codepen.io/pen/`
- add `texlive-must` and `texlive-langjapanese`

## 2022-01-09
### Added
- add `openbsd-netcat`
- add `lmms`
- add `texstudio`
- add `tree`

### Fixed
- fix issue that `btop` is not installed
- fix issue that `paru-bin` is missing in the post-installation environment
- fix error when file name contains space in `lstree()`

## 2022-01-08
### Added
- add `lstree()` to `.bashrc`
- add multiple locations support in `lstree()`
- add options support in `lstree()`
- add `(-h|--help)` to `lstree()`
- add `paru-bin` and AUR support
- add `fzf`
- add `/usr/bin/fzfmenu`
- add trap to clean up processes

## 2022-01-07
### Added
- add `pgrepw()` and `killw()` to `.bashrc`

## 2022-01-06
### Added
- add `pgrepw()` and `killw()`

## 2022-01-05
### Fixed
- make hook run manually in `pacstrap` phase
- avoid segmentation fault when clip added to track
- fix issue that all necessary files can not be downloaded correctly
- fix "no such process" by `kill` command

### Security
- set editor to no in `/efi/loader/loader.conf`

## 2022-01-04
### Added
- add `/usr/bin/capture-export` and a keybind to launch it
- add `nm-connection-editor`
- add `pcurses`

### Changed
- remove a keybind to open `/installer` in the post-installation environment

### Security
- disable login to `root`

## 2022-01-03
### Added
- add a keybind to open `pmw-console`
- add a keybind to open `/installer`
- add `/etc/sudoers.d/wheel` to the post-installation environment

### Fixed
- fix btop install path
- uncomment to add Deepl Translator to launcher
- fix a line that `--dbpath` option is missing
- fix partitioning
- fix issue that `useradd` command was being executed before adding files to `/etc/skel/`
- fix issue that Shotcut icon is missing
- fix regex when editing `weston.ini`

## 2022-01-02
### Added
- add darkhttpd to dependencies
- add `/efi/loader/loader.conf`
- add base-devel
- add [weston-binder](https://github.com/tarvi-verro/weston-binder) module
- add brightnessctl
- add pamixer
- add basic keybinds
- add `/usr/bin/pmw-console`

### Changed
- optimize downloads
- change the backup directory of `bootx64.efi` to `/boot`
- change hostname to `popwlive`

### Fixed
- fix btop launcher

## 2022-01-01
### Added
- add aliases to `.bashrc` (`e[dnvx]`)
- add files to include in installer (`{NetworkManager,docker}.service`)
- add process to initialize keyring to installer
- add GParted
- add firewalld
- add VirtualBox
- add OpenJDK
- add Deno
- add [btop](https://github.com/aristocratos/btop)
- add `https://www.deepl.com/translator`
- add mouse support in tmux

### Changed
- change hostname
- update `profiledef.sh`
- use circle folder version Tela-circle-icon-theme
- update packages to be installed on the new system
- update misc options in `pacman.conf`
- convert indentation to tabs in `archiso-base-211216.md`

### Fixed
- fix `update-keyring.hook`

### Removed
- remove `/pacman.d/hooks/update-keyring.hook`

## 2021-12-31
### Changed
- change error message color

### Fixed
- fix issue that characters would not read from `/dev/tty`
- fix issue where script would fail

## 2021-12-30
### Added
- add installer to launcher
- add man
- add texinfo

### Changed
- add "popw" prefix to PARTLABEL
- update installer
- update readme
- change `-p` option to be used as default argument in `cpw()`
- change `/etc/sudoer.d/user` to `/etc/sudoer.d/wheel`

### Fixed
- fix hook description
- fix issue where hook would not run
- fix permissions for multiple files

## 2021-12-29
### Added
- add `etc/skel/tmux.conf`
- add asdf
- add "自家製 Rounded M+"
- add `/installer`
- add unzip to dependencies
- add `/etc/pacman.d/hooks/update-keyring`

## 2021-12-28
### Added
- add local repository for Pacman
- add arch-install-scripts
- add freerdp

## 2021-12-27
### Added
- add xdg-user-dirs

### Changed
- update `sudoers.d`
- update launcher items

## 2021-12-26
### Added
- add `https://app.diagrams.net/`
- add `https://www.mathcha.io/editor`
- add python
- add FreeCAD
- add MuseScore

### Changed
- set micro to default editor

## 2021-12-25
### Added
- add `https://github.com/`
- add nomacs
- add Blender
- add Signal Desktop
- add `https://earth.google.com/web/`
- add `https://www.wolframalpha.com/`
- add `https://www.wikipedia.org/`
- add `pipewire-pulse`

### Changed
- update YouTube icon
- set `QT_QPA_PLATFORM` to `wayland`

### Fixed
- fix wrong path

### Removed
- remove unused package

## 2021-12-24
### Added
- add `https://www.youtube.com/`
- add items related to LibreOffice to the launcher
- add Neovim to the launcher

### Fixed
- fix `rm: missing operand`
- fix issue where there was no sound after startup

## 2021-12-23
### Added
- add Wayland support for PCManFM-Qt
- add gvfs
- add apps
- add pipewire

### Changed
- change PCManFM-Qt default icon to Tela-circle
- change installation path of icon

## 2021-12-22
### Added
- add tmux
- add htop
- add vlc
- add pcmanfm-qt
- add line to fully install icon
- add `jj` bind to Bash
- add `BLE_DISABLED` variable
- add Fuchsia cursor theme
- add `https://vscode.dev/` as app

### Changed
- change installation path of Tera-circle-icon-theme from `/usr/local/share/icons` to `/usr/share/icons`
- change default background image
- change panel color
- change default theme for kitty
- set vim_airline_theme to light
- change default background opacity for kitty

## 2021-12-21
### Added
- add [ble.sh](https://github.com/akinomyoga/ble.sh)
- add docker

### Changed
- update `archiso-base-211216.sh`

## 2021-12-20
### Added
- add .gitpod.yml
- add editor alias to .bashrc
- add lines to install dependencies

### Changed
- update prompts

## 2021-12-19
### Fixed
- fix `archiso-base-211216.sh`

## 2021-12-18
### Added
- set background opacity for kitty
- add fcitx5
- set theme for kitty
- update bash prompt
- add aliases to .bashrc
- add vivaldi-ffmpeg-codecs
- add xorg-drivers
- add ttf-ibm-plex

## 2021-12-17
### Added
- set panel position to left
- set kitty instead of weston-terminal
- add Inkscape to launcher
- add GIMP
- add LibreOffice Fresh
- add Shotcut
- apply Tela-circle-icon-theme to each icon in the launcher

## 2021-12-16
### Added
- add new base

## 2021-12-15
### Added
- add aria2

### Changed
- update `archiso-packages-211211.sh`

## 2021-12-14
### Added
- add confirmation prompt to installer
- add install process to installer
- add script for live environment

## 2021-12-13
### Added
- add new installer

## 2021-12-12
### Added
- add xf86-video-vesa
- add package to include in live repo

### Changed
- update packages

### Removed
- remove hook that sets default browser

## 2021-12-11
### Added
- add simplescreenrecorder
- add wget
- add docker
- add local repository
- add xf86-video-vmware
- add man

### Changed
- update `archiso-fixes-211208.sh`

## 2021-12-10
### Added
- add driver
- add script to remove custom hooks
- add gparted
- add fcitx5

### Changed
- update `archiso-base-211205.sh`
- update `archiso-fixes-211208.sh`
- set default web browser to Vivaldi
- set default editor to Vim

### Fixed
- fix hook in archiso fixes script

## 2021-12-09
### Added
- add tmux

## 2021-12-08
### Added
- add locale config
- add vivaldi
- add fixes script
- add script for vmware

### Changed
- change timezone

## 2021-12-07
### Changed
- update `arch-extra-211204.sh`

## 2021-12-06
### Added
- archiso base script

### Changed
- update `plasma-211204.sh`
- update `arch-plasma-211204.sh`
- update `arch-extra-211204.sh`

## 2021-12-05
### Changed
- update `extra-211204.sh`

## 2021-12-04
### Added
- plasma script
- archiso plasma script
- extra script
- archiso extra script

### Changed
- update `installer-211203.sh`

## 2021-12-03
### Added
- installer
- logo