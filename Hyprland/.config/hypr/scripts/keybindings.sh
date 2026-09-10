#!/usr/bin/env bash

# Fetch keybindings from Hyprland, parse them using jq, format as a table, and show in fuzzel
hyprctl binds -j | jq -r '
  .[] | 
  select(.key != "") |
  .modmask as $m |
  (if ($m % 128 >= 64) then "SUPER " else "" end) +
  (if ($m % 16 >= 8) then "ALT " else "" end) +
  (if ($m % 8 >= 4) then "CTRL " else "" end) +
  (if ($m % 2 >= 1) then "SHIFT " else "" end) as $mods |
  ($mods | sub(" $"; "") | gsub(" "; " + ")) as $mods_clean |
  (if $mods_clean != "" then $mods_clean + " + " + .key else .key end) as $keystr |
  (if (.description != null and .description != "") then 
    .description 
  else 
    (if .dispatcher == "exec" then .arg else .dispatcher + " " + .arg end) 
  end) as $action |
  "\($keystr) |   \($action)"
' | sed -E \
  -e 's/^(SUPER \+ )[0-9] \|   Switch to Workspace [0-9]+$/\1[1-9] |   Switch to Workspace [1-9]/' \
  -e 's/^(SUPER \+ SHIFT \+ )[0-9] \|   Move to Workspace [0-9]+$/\1[1-9] |   Move to Workspace [1-9]/' \
  -e 's/^XF86AudioRaiseVolume(.*)\|.*/Volume Up\1|   Increase Volume/' \
  -e 's/^XF86AudioLowerVolume(.*)\|.*/Volume Down\1|   Decrease Volume/' \
  -e 's/^XF86AudioMute(.*)\|.*/Mute\1|   Toggle Audio Mute/' \
  -e 's/^XF86MonBrightnessUp(.*)\|.*/Brightness Up\1|   Increase Brightness/' \
  -e 's/^XF86MonBrightnessDown(.*)\|.*/Brightness Down\1|   Decrease Brightness/' \
  -e 's/^(SUPER \+ )mouse_down(.*)\|.*/\1Scroll Down\2|   Next Workspace/' \
  -e 's/^(SUPER \+ )mouse_up(.*)\|.*/\1Scroll Up\2|   Previous Workspace/' \
  -e 's/^(SUPER \+ )mouse:272(.*)\|.*/\1Left Click\2|   Move Window/' \
  -e 's/^(SUPER \+ )mouse:273(.*)\|.*/\1Right Click\2|   Resize Window/' \
  -e 's/^Print \|(.*)/PrtScn |\1/' \
  -e 's/^SHIFT \+ Print \|(.*)/SHIFT + PrtScn |\1/' \
  | sort -u | column -t -s '|' | fuzzel -d -p "   Bindings 󰄾 " -w 80
