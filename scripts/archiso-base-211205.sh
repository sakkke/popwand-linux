cat >> packages.x86_64 << /cat
dhcpcd
efibootmgr
grub
/cat
sort -uo packages.x86_64 packages.x86_64

ln -sv /usr/share/zoneinfo/Asia/Tokyo airootfs/etc/localtime

cat > airootfs/etc/locale.conf << /cat
LANG=ja_JP.UTF-8
/cat
mkdir -p airootfs/etc/pacman.d/hooks
cat > airootfs/etc/pacman.d/hooks/40-locale-gen.hook << /cat
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