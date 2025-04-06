#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Partition name not specified"
  exit
fi

# Setup BTRFS partition
mkfs.btrfs -force $1
mount $1 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@boot
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots

umount /mnt

mount -o compress=zstd,subvol=@ $1 /mnt
mount -o compress=zstd,subvol=@home --mkdir $1 /mnt/home
mount -o compress=zstd,subvol=@swap --mkdir $1 /mnt/swap
mount -o compress=zstd,subvol=@boot --mkdir $1 /mnt/boot
mount -o compress=zstd,subvol=@cache --mkdir $1 /mnt/var/cache
mount -o compress=zstd,subvol=@tmp --mkdir $1 /mnt/var/tmp
mount -o compress=zstd,subvol=@log --mkdir $1 /mnt/var/log
mount -o compress=zstd,subvol=@snapshots --mkdir $1 /mnt/.snapshots

mkdir /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers git btrfs-progs grub efibootmgr grub-btrfs timeshift vim neovim networkmanager reflector sudo
genfstab -U /mnt >>/mnt/etc/fstab

arch-chroot /mnt
