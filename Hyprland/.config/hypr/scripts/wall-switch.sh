#!/bin/bash

export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
WALL_DIR="$HOME/Pictures/.HyprPaper"
STATE_FILE="$HOME/.cache/current_wallpaper"

# Function to set and save wallpaper
set_wallpaper() {
  local img="$1"

  [ -f "$img" ] || return 1

  # Apply via modern hyprpaper command
  hyprctl hyprpaper wallpaper "eDP-1,$img"

  # Write the path as a Hyprlock variable inside your cache file
  echo "\$WALLPAPER = $img" >"$HOME/.cache/hyprlock_path"

  # Save the raw path for your other scripts
  echo "$img" >"$HOME/.cache/current_wallpaper"
}

case "$1" in
--wall)
  RANDOM_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
  set_wallpaper "$RANDOM_WALL"
  ;;

--theme)
  RANDOM_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
  wal -i "$RANDOM_WALL" --backend colorthief -n
  ;;

--both)
  RANDOM_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
  set_wallpaper "$RANDOM_WALL"
  wal -i "$RANDOM_WALL" --backend colorthief -n
  ;;

--restore)
  # Restore last used wallpaper on login
  if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
    set_wallpaper "$(cat "$STATE_FILE")"
  else
    # Fallback if state file is missing or empty
    RANDOM_WALL=$(find "$WALL_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
    set_wallpaper "$RANDOM_WALL"
  fi
  ;;
esac

hyprctl reload
killall waybar && waybar &
