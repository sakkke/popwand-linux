cat > airootfs/etc/pacman.d/hooks/zzzz99-remove-custom-hooks-from-airootfs.hook << /cat
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

cat >> packages.x86_64 << /cat
dhcpcd
efibootmgr
grub
/cat
sort -uo packages.x86_64 packages.x86_64

mkdir -p airootfs/etc/pacman.d
cat /etc/pacman.d/mirrorlist > airootfs/etc/pacman.d/mirrorlist

ln -sv /usr/share/zoneinfo/Asia/Tokyo airootfs/etc/localtime

cat > airootfs/etc/locale.conf << /cat
LANG=ja_JP.UTF-8
/cat
mkdir -p airootfs/etc/pacman.d/hooks
cat > airootfs/etc/pacman.d/hooks/40-locale-gen.hook << /cat
# remove from airootfs!
[Trigger]
Operation = Install
Type = Package
Target = glibc

[Action]
Description = Uncommenting ja_JP.UTF-8 locale and running locale-gen...
When = PostTransaction
Depends = glibc
Depends = sed
Depends = sh
Exec = /bin/sh -c "sed -i 's/#\(ja_JP\.UTF-8\)/\1/' /etc/locale.gen && locale-gen"
/cat

cat > airootfs/etc/vconsole.conf << /cat
KEYMAP=jp106
/cat

cat > airootfs/etc/hostname << /cat
earth
/cat

ln -sv /usr/lib/systemd/system/dhcpcd.service airootfs/etc/systemd/system/multi-user.target.wants/