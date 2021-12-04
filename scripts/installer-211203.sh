timedatectl set-ntp true

parted /dev/sda << /parted
mklabel gpt
mkpart ESP fat32 1MiB 551MiB
set 1 esp on
mkpart primary ext4 551MiB 100%
/parted

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

pacstrap /mnt base dhcpcd efibootmgr grub linux linux-firmware

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt << /arch-chroot
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc

sed -Ei 's/^#(ja_JP.UTF-8 UTF-8)/\1/' /etc/locale.gen
locale-gen
cat >> /etc/vconsole.conf << /cat
KEYMAP=jp106
/cat

echo earth > /etc/hostname
ln -s /usr/lib/systemd/system/dhcpcd.service /etc/systemd/system/multi-user.target.wants/

echo root:toor | chpasswd

grub-install --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
/arch-chroot

umount -R /mnt