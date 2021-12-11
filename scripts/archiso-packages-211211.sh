pacman -Sp - > packages.list < packages.x86_64
mkdir packages
grep '^file://' packages.list | sed 's,^file://,,' | xargs -I{} cp -v {} packages/
wget -P packages -i <(grep '^https://' packages.list)
cd packages
repo-add packages.db.tar.gz *.pkg.tar.zst
mv packages airootfs/

ln -sf "$PWD/airootfs/packages" /tmp/popwand-linux--packages

cat > airootfs/etc/pacman.conf << /cat
[options]
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
SigLevel = Required DarabaseOptional
LocalFileSigLevel = Optional

# Additional misc options
Color
ILoveCandy

[local]
Server = file:///packages
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
SigLevel = Required DarabaseOptional
LocalFileSigLevel = Optional

# Additional misc options
Color
ILoveCandy

[local]
Server = file:///tmp/popwand-linux--packages
SigLevel = Never
/cat