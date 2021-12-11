pacman -Sp - > packages.list < packages.x86_64
mkdir live
grep '^file://' packages.list | sed 's,^file://,,' | xargs -I{} cp -v {} live/
wget -P live -i <(grep '^https://' packages.list)
cd live
repo-add live.db.tar.gz *.pkg.tar.*
cd ..
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

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist
/cat