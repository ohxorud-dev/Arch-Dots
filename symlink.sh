#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Usage: link_config <source_in_dotfiles> <target_path> [use_sudo]
link_config() {
  local source="$DOTFILES_DIR/$1"
  local target="$2"
  local use_sudo=${3:-false}
  local cmd_prefix=""
  local ln_cmd="ln -snf"

  if [ "$use_sudo" = true ]; then
    cmd_prefix="sudo "
  fi

  # 1. Ensure target parent directory exists
  if [ ! -d "$(dirname "$target")" ]; then
    echo "Creating target parent directory: $(dirname "$target")"
    ${cmd_prefix}mkdir -p "$(dirname "$target")"
  fi

  # 2. Check if source exists in dotfiles. If not, copy from target.
  #    Use -e to check if the path exists (file or directory)
  if [ ! -e "$source" ]; then
    if [ ! -d "$(dirname "$source")" ]; then
      echo "Creating source parent directory: $(dirname "$source")"
      mkdir -p "$(dirname "$source")"
    fi

    if [ -e "$target" ]; then
      echo "Source '$source' not found. Copying from target: $target -> $source"
      ${cmd_prefix}cp -rT "$target" "$source"
    else
      echo "Warning: Source '$source' not found and target '$target' does not exist. Cannot copy."
      return 1
    fi
  fi

  if [ -e "$source" ]; then
    echo "Linking $source -> $target"
    ${cmd_prefix}rm -rf "$target"
    ${cmd_prefix}${ln_cmd} "$source" "$target"
  else
    echo "Skipping link for '$target' as source '$source' could not be created/found."
  fi
}

echo "### Linking configuration files ###"

link_config "config/hypr" "$HOME/.config/hypr" || echo "Failed to link hypr config."
link_config "config/kitty" "$HOME/.config/kitty" || echo "Failed to link kitty config."
link_config "config/waybar" "$HOME/.config/waybar" || echo "Failed to link waybar config."
link_config "config/fcitx5/config" "$HOME/.config/fcitx5/config" || echo "Failed to link fcitx5 config."
link_config "config/fcitx5/profile" "$HOME/.config/fcitx5/profile" || echo "Failed to link fcitx5 profile."

link_config "etc/pacman.conf" "/etc/pacman.conf" true || echo "Failed to link pacman.conf."

echo "### Symlinking complete! ###"
