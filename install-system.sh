#!/bin/bash

set -e

echo "### Setting system clock and locale ###"
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc
sudo sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen

cat <<EOF >/etc/locale.conf
LANG=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
EOF

echo "KEYMAP=us" >/etc/vconsole.conf

echo "### Setting network hostname ###"
echo "ohxorud-laptop" >/etc/hostname
cat <<EOF >/etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 Arch
EOF

echo "### Setting up sudoers ###"
echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/wheel
sudo chmod 440 /etc/sudoers.d/wheel

echo "### Setting root password ###"
passwd root

echo "### Adding new user ###"
sudo useradd -mG wheel ohxorud || echo "User already exist, using existing user"
passwd ohxorud

echo "### Deploying GRUB ###"
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

echo "### Installing yay ###"
cd /tmp && pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && chown ohxorud:ohxorud -R yay && cd yay && sudo -u ohxorud makepkg -si && cd .. && rm -rf yay

echo "### Enabling essential services ###"
systemctl enable NetworkManager

echo "### Installing Additional packages ###"
sudo -u ohxorud yay -S --noconfirm --needed hyprland waybar hyprpaper kitty brightnessctl pavucontrol polkit-kde-agent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland wl-clipboard network-manager-applet fcitx5 fcitx5-qt fcitx5-gtk fcitx5-hangul fcitx5-configtool man openssh pipewire pipewire-jack pipewire-alsa pipewire-pulse inotify-tools zen-browser-bin gitkraken timeshift-auto sddm nerd-fonts ttf-fira-code fish rofi starship 

echo "### Setting grub-btrfsd ###"
sudo sed -i 's#^ExecStart=.*#ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto#' /usr/lib/systemd/system/grub-btrfsd.service
sudo systemctl daemon-reload
sudo systemctl enable grub-btrfsd

echo "### Cloning repo into home directory ###"
git clone https://github.com/ohxorud-dev/Arch-Dots /home/ohxorud/.dotfiles

echo "### Symlinking ###"
/home/ohxorud/.dotfiles/symlink.sh

echo "### Installing display graphics for nvidia and intel GPU ###"
yay -S --noconfirm --needed nvidia nvidia-utils mesa vulkan-intel

echo "### Enabling SDDM ###"
sudo systemctl enable sddm

echo "### Changing Shell ###"
chsh --shell /usr/bin/fish

