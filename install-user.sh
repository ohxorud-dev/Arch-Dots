#!/bin/bash

echo "### Installing yay ###"
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si

echo "### Installing Additional packages ###"
yay -S --noconfirm --needed hyprland waybar hyprpaper kitty brightnessctl pavucontrol polkit-kde-agent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland wl-clipboard network-manager-applet fcitx5 fcitx5-qt fcitx5-gtk fcitx5-hangul fcitx5-configtool man openssh pipewire pipewire-jack pipewire-alsa pipewire-pulse zen-browser-bin gitkraken timeshift-auto sddm nerd-fonts ttf-fira-code fish rofi-wayland starship pamixer swaync 

echo "### Cloning repo into home directory ###"
git clone https://github.com/ohxorud-dev/Arch-Dots /home/ohxorud/.dotfiles

echo "### Symlinking ###"
bash /home/ohxorud/.dotfiles/symlink.sh

echo "### Installing display graphics for nvidia and intel GPU ###"
sudo -u ohxorud sudo -u ohxorud yay -S --noconfirm --needed nvidia nvidia-utils mesa vulkan-intel

echo "### Changing Shell for ohxorud ###"
chsh --shell /usr/bin/fish