#!/bin/bash

set_user_password() {
  local username=$1
  if [ -z "$username" ]; then
    echo "Error: No username provided to set_user_password function."
    return 1
  fi

  echo "### Setting password for user '$username' ###"
  until passwd "$username"; do
    echo "Password setting failed for '$username'."
    echo "Please try again."
  done
  echo "Password for user '$username' set successfully."
  return 0
}

echo "### Setting system clock and locale ###"
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen

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
chmod 440 /etc/sudoers.d/wheel

echo "### Setting root password ###"
set_user_password root

echo "Root password set successfully."

echo "### Adding new user ###"
useradd -mG wheel ohxorud || echo "User already exist, using existing user"
set_user_password ohxorud

echo "### Deploying GRUB ###"
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

echo "### Installing yay ###"
cd /tmp
pacman -S --needed git base-devel
sudo -u ohxorud git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u ohxorud makepkg -si

echo "### Installing Additional packages ###"
sudo -u ohxorud yay -S --noconfirm --needed hyprland waybar hyprpaper kitty brightnessctl pavucontrol polkit-kde-agent qt5-wayland qt6-wayland xdg-desktop-portal-hyprland wl-clipboard network-manager-applet fcitx5 fcitx5-qt fcitx5-gtk fcitx5-hangul fcitx5-configtool man openssh pipewire pipewire-jack pipewire-alsa pipewire-pulse inotify-tools zen-browser-bin gitkraken timeshift-auto sddm nerd-fonts ttf-fira-code fish rofi starship 

echo "### Setting grub-btrfsd ###"
sudo sed -i 's#^ExecStart=.*#ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto#' /usr/lib/systemd/system/grub-btrfsd.service
sudo systemctl daemon-reload
sudo systemctl enable grub-btrfsd

echo "### Cloning repo into home directory ###"
sudo -u ohxorud git clone https://github.com/ohxorud-dev/Arch-Dots /home/ohxorud/.dotfiles

echo "### Symlinking ###"
sudo -u ohxorud /home/ohxorud/.dotfiles/symlink.sh

echo "### Installing display graphics for nvidia and intel GPU ###"
sudo -u ohxorud yay -S --noconfirm --needed nvidia nvidia-utils mesa vulkan-intel

echo "### Enabling essential services ###"
systemctl enable NetworkManager
sudo systemctl enable sddm

echo "### Changing Shell ###"
chsh --shell /usr/bin/fish

echo "### Cleaning Up ###"
rm -rf /install-system.sh
rm -rf /tmp/yay