pacman -Spy - > packages.list < packages.x86_64

mkdir live
grep '^file://' packages.list | sed 's,^file://,,' | xargs -I{} -P0 -n1 cp -v {} live/
if type aria2c > /dev/null; then
  grep '^https://' packages.list | xargs -P0 -n1 aria2c \
    --show-console-readout false \
    --summary-interval 0 \
    -dlive \
    -s4 \
    -x4
else
  grep '^https://' packages.list | xargs -P0 -n1 wget -P live -nv -q
fi
cd live
repo-add live.db.tar.gz *.pkg.tar.*
ls *.pkg.tar.* \
  | xargs -I{} -P0 -n1 cp -fv {} /var/cache/pacman/pkg/{}
cd -
mv live airootfs/

cat > airootfs/etc/pacman.conf << /cat
[options]
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

# Additional misc options
Color
ILoveCandy

[live]
Server = file:///live
SigLevel = Never

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist
/cat