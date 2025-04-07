#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Partition name not specified"
  exit
fi

mkfs.btrfs --force $1
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
mount /dev/nvme0n1p1 /mnt/efi

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers git btrfs-progs grub efibootmgr grub-btrfs timeshift vim neovim networkmanager reflector sudo
genfstab -U /mnt >>/mnt/etc/fstab

cp "$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"/install-system.sh /mnt/tmp
arch-chroot /mnt bash /tmp/install-system.sh

reboot
