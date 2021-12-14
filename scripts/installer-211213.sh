function error_message {
  local message="$*"
  echo -e "\e[31m$message\e[m"
}

function input_prompt {
  local message="$*"
  echo "$message"
  read -p"$(echo -en '\e[33m->\e[m ')" p
}

function install_process {
  timedatectl set-ntp true

  parted $device << /parted
mklabel gpt
mkpart ESP fat32 1MiB 551MiB
set 1 esp on
mkpart primary ext4 551MiB 100%
/parted

  mkfs.fat -F32 ${device}1
  mkfs.ext4 ${device}2

  mount ${device}2 /mnt
  mkdir /mnt/boot
  mount ${device}1 /mnt/boot

  reflector --save /etc/pacman.d/mirrorlist --sort rate -ckr,jp -phttps
  pacstrap /mnt base dhcpcd efibootmgr grub linux linux-firmware
  cat /etc/pacman.d/mirrorlist > /mnt/etc/pacman.d/mirrorlist

  genfstab -U /mnt >> /mnt/etc/fstab

  arch-chroot /mnt bash << /arch-chroot
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc

sed -Ei 's/^#(en_US.UTF-8 UTF-8|ja_JP.UTF-8 UTF-8)/\1/' /etc/locale.gen
locale-gen
cat >> /etc/locale.conf << /cat
LANG=en_US.UTF-8
/cat
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
}

function is_number {
  local number="$1"
  grep '^[0-9]\+$' <<< "$number" > /dev/null
}

function list_devices {
  local items=($@)
  echo ${items[@]} \
    | xargs -n1 \
    | nl -s' => ' -v0 \
    | while read a b c; do
        echo -e "\e[34m$a\e[m $b \e[3;32m$c\e[m \e[2;3m/dev/$c\e[m"
      done \
        | column -t \
        | column
}

function select_prompt {
  local preexec=$1
  shift
  local items=($@)
  while :; do
    $preexec ${items[@]}
    input_prompt Select a device number to install
    if is_number "$p" && [ -v "items[$p]" ]; then
      break
    else
      error_message Invalid value
      echo
    fi
  done
}

devices=($(ls /tmp/dev \
  | grep '^\(mmcblk[0-9]\+\|nvme[0-9]\+n[0-9]\+\|sd[a-z]\+\)$' \
  | xargs))

echo Hint: press C-c to cancel the installation process
select_prompt list_devices ${devices[@]}
device=${devices[p]}$(grep '^[mn]' <<< ${devices[p]} > /dev/null && echo -n p)
echo
while :; do
  input_prompt Enter name of the new user
  if grep '^[0-9A-Za-z]\{1,8\}$' <<< "$p" > /dev/null; then
    user_name="$p"
    break
  else
    error_message Invalid user name
    echo
  fi
done
echo
echo Default password: p@ssw0rd
echo
while :; do
  input_prompt Continue installation? [y/N]
  if grep '^[Yy]$' <<< "$p" > /dev/null; then
    break
  else
    error_message Installation canceled
    exit 1
  fi
done
install_process
echo Installation is complete!