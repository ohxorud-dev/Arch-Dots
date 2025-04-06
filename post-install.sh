timedatectl set-ntp true

sudo sed -i 's#^ExecStart=.*#ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto#' /usr/lib/systemd/system/grub-btrfsd.service
sudo systemctl daemon-reload
sudo systemctl enable grub-btrfsd

yay -S --noconfirm --needed timeshift-auto

echo "### Installing display graphics for nvidia and intel ###"
yay -S --noconfirm --needed nvidia nvidia-utils mesa vulkan-intel

reboot
