cat >> packages.x86_64 << /cat
kde-applications-meta
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
plasma-meta
sudo
/cat
sort -o packages.x86_64 packages.x86_64

mkdir -p airootfs/etc/X11/xorg.conf.d
cat > airootfs/etc/X11/xorg.conf.d/00-keyboard.conf << /cat
Section "InputClass"
  Identifier "system-keyboard"
  MatchIsKeyboard "on"
  Option "XkbLayout" "jp"
EndSection
/cat

# root:toor
# user:p@ssw0rd
cat > airootfs/etc/group << /cat
root:x:0:root
wheel:x:10:user
user:x:1000:
/cat
cat > airootfs/etc/gshadow << /cat
root:!*::root
user:!*::
/cat
cat > airootfs/etc/passwd << /cat
root:x:0:0:root:/root:/bin/bash
user:x:1000:1000::/home/user:/bin/bash
/cat
cat > airootfs/etc/shadow << /cat
root:$6$HP5hXSnjUt1vVlOc$ZqDnjAHYfXCzOenfv/U2TEJc5vIFoKl4yvuSHmAXbl.hSC3mEWHwQK0aS9RYT282AdIejYd1blNbu0Kqh1kdX.:14871::::::
user:$6$VBv.I1CUXU.k2TEF$Ca89ThDMF5j7QHldbh7qPdNntnOw1O2qP1ELCvuoEUUR.XNMv1ARVLva7OQTE.cMAYByyDKNJKEdJ69Wzeo4i.:14871::::::
/cat

mkdir -p airootfs/sudoers.d
cat > airootfs/etc/sudoers.d/wheel << /cat
%wheel ALL=(ALL) ALL
/cat

ln -sv /usr/lib/systemd/system/sddm.service /etc/systemd/system/multi-user.target.wants/