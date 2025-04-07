#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
  echo "Partition names are not specified"
  echo "Usage: ./setup-partition.sh <BTRFS Partition> <EFI Partition>"
  exit
fi

umount -R /mnt || echo "/mnt is not mounted"
umount $1 || echo "$1 is not mounted"
umount $2 || echo "$2 is not mounted"

mkfs.btrfs --force $1
mkfs.fat -F32 $2
mount $1 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@vms

umount /mnt

mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@ $1 /mnt
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@home --mkdir $1 /mnt/home
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@cache --mkdir $1 /mnt/var/cache
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@tmp --mkdir $1 /mnt/var/tmp
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@log --mkdir $1 /mnt/var/log
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@snapshots --mkdir $1 /mnt/.snapshots
mount -o rw,noatime,nodatacow,compress=none,subvol=@swap --mkdir $1 /mnt/swap
mount -o rw,noatime,compress=zstd,ssd,space_cache=v2,subvol=@opt --mkdir $1 /mnt/opt
mount -o rw,noatime,nodatacow,ssd,space_cache=v2,subvol=@vms --mkdir $1 /mnt/var/lib/libvirt/images

mkdir /mnt/efi
mount $2 /mnt/efi

rm -f /etc/pacman.d/mirrorlist
echo "Server = https://mirror.morgan.kr/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers git btrfs-progs grub efibootmgr grub-btrfs timeshift vim neovim networkmanager reflector sudo
genfstab -U /mnt >>/mnt/etc/fstab

cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/install-system.sh /mnt
arch-chroot /mnt bash /install-system.sh

reboot
