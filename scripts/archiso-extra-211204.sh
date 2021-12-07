cat >> packages.x86_64 << /cat
base-devel
code
firefox
firefox-developer-edition
firefox-developer-edition-i18n-ja
firefox-i18n-ja
gimp
git
krita
inkscape
kitty
libreoffice-fresh
libreoffice-fresh-ja
ttf-fira-code
vim
/cat
sort -uo packages.x86_64 packages.x86_64

mkdir -p airootfs/etc/skel/.config/kitty
cat > airootfs/etc/skel/.config/kitty/kitty.conf << /cat
font_family Fira Code
/cat