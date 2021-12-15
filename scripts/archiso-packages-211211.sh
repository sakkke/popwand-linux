cat > pacman.conf << /cat
[options]
HoldPkg = pacman glibc
Architecture = auto
ParallelDownloads = 5
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

# Additional misc options
Color
ILoveCandy

[live]
Server = file:///tmp/popwand-linux--live
SigLevel = Never
/cat

pacman -Sp - > packages.list < packages.x86_64

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
: > packages.x86_64
ls *.pkg.tar.* \
  | xargs -I{} -P0 -n1 bash -c 'tar -Oxf ./{} .PKGINFO | grep "^pkgname = " | while read _ _ pkgname; do tee -a '"$OLDPWD"'/packages.x86_64 <<< $pkgname; done'
sort -o "$OLDPWD/packages.x86_64" "$OLDPWD/packages.x86_64"
cd -
mv live airootfs/

ln -sf "$PWD/airootfs/live" /tmp/popwand-linux--live

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