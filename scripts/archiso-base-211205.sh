cat >> packages.x86_64 << /cat
dhcpcd
efibootmgr
grub
/cat
sort -uo packages.x86_64 packages.x86_64

cat > airootfs/etc/vconsole.conf << /cat
KEYMAP=jp106
/cat

cat > airootfs/etc/hostname << /cat
earth
/cat

ln -sv /usr/lib/systemd/system/dhcpcd.service airootfs/etc/systemd/system/multi-user.target.wants/

mkdir airootfs/etc/sddm.conf.d
cat > airootfs/etc/sddm.conf.d/autologin.conf << /cat
[Autologin]
User=user
Session=plasma.desktop
/cat