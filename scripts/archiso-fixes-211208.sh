mkdir -p airootfs/etc/pacman.d/hooks
cat > airootfs/etc/pacman.d/hooks/sddm-changes.conf << /cat
[Trigger]
Operation = Install
Type = Package
Target = sddm

[Action]
Description = Add changes to /usr/lib/systemd/system/sddm.conf ...
When = PostTransaction
Depends = sddm
Depends = sed
Depends = sh
Exec = /bin/sh -c "sed -i 's,\(ExecStart=/usr/bin/sddm\),\1''\'$'\n''ExecStartPre=/usr/bin/sleep 5,' /usr/lib/systemd/system/sddm.conf"
/cat