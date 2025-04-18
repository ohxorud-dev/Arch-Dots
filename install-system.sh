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

echo "### Setting up sudoers with NOPASSWD ###"
echo "%wheel ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

echo "### Deploying GRUB ###"
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg

echo "### Setting grub-btrfsd ###"
sudo sed -i 's#^ExecStart=.*#ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto#' /usr/lib/systemd/system/grub-btrfsd.service
sudo systemctl daemon-reload
sudo systemctl enable grub-btrfsd

echo "### Setting root password ###"
set_user_password root

echo "### Adding new user ###"
useradd -mG wheel ohxorud || echo "User already exist, using existing user"
set_user_password ohxorud

sudo -u bash /install-user.sh

echo "### Enabling essential services ###"
systemctl enable NetworkManager
sudo systemctl enable sddm

echo "### Changing Shell for root ###"
chsh --shell /usr/bin/fish

echo "### Add Zen Browser Policy ####"
mkdir -p /etc/zen/policies/
cp ~/.dotfiles/config/zen/policies.json /etc/zen/policies/policies.json

echo "### Enforcing password in sudoers ###"
rm -f /etc/sudoers.d/wheel
echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

echo "### Cleaning Up ###"
rm -rf /install-system.sh
rm -rf /tmp/yay