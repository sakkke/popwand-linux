cat >> packages.x86_64 << /cat
open-vm-tools
/cat
sort -uo packages.x86_64 packages.x86_64

ln -sv /usr/lib/systemd/system/vmware-vmblock-fuse.service airootfs/etc/systemd/system/multi-user.target.wants/