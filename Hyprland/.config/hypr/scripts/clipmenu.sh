#!/usr/bin/env bash

PIN_DIR="$HOME/.local/share/clipboard_pins"
mkdir -p "$PIN_DIR"

# 1. Build list of Pinned items
PINS_MENU=""
for file in "$PIN_DIR"/*; do
  [ -f "$file" ] || continue
  filename=$(basename "$file")
  if [[ "$filename" == *.png ]]; then
    PINS_MENU="${PINS_MENU}📌 [IMAGE] ${filename}\n"
  elif [[ "$filename" == *.txt ]]; then
    content=$(head -n 1 "$file" | cut -c1-40)
    PINS_MENU="${PINS_MENU}📌 ${filename}: ${content}\n"
  fi
done

MENU_HEADER="➕ Pin Current Clipboard\n🗑️ Clear History\n─── Pinned ───"
CLIP_RAW=$(cliphist list)
CLIP_MENU=$(echo "$CLIP_RAW" | awk -F'\t' '{
  content = $2
  if (content ~ /^[[:space:]]*$/) next
  if (length(content) == 0) next
  if (content ~ /^\[\[ binary data/) {
    match(content, /([0-9]+x[0-9]+)/, dim)
    print "󰋩  [Image " dim[1] " #" $1 "]"
  } else {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", content)
    gsub(/\n/, " ↵ ", content)
    if (length(content) > 55) content = substr(content, 1, 55) "…"
    print "󰅍  " content
  }
}')

# 2. Combine Pinned and Regular History into Fuzzel
FULL_MENU=$(echo -e "${MENU_HEADER}\n${PINS_MENU}─── History ───\n${CLIP_MENU}" | grep -v '^$')
SELECTION=$(echo -e "$FULL_MENU" | fuzzel -d --hide-prompt -w 55 -l 15 --font="Hurmit Nerd Font:size=11")

[ -z "$SELECTION" ] && exit 0
[[ "$SELECTION" == "─── History ───" ]] && exit 0
[[ "$SELECTION" == "─── Pinned ───" ]] && exit 0

[ -z "$SELECTION" ] && exit 0

# 3. Handle "Pin Current Clipboard"
if [ "$SELECTION" = "➕ Pin Current Clipboard" ]; then
  TIME=$(date +'%Y-%m-%d_%H-%M-%S')
  if wl-paste --list-types | grep -q "image/"; then
    wl-paste --type image/png >"$PIN_DIR/pin_${TIME}.png"
    notify-send "Clipboard" "Pinned current image!"
  else
    wl-paste -n >"$PIN_DIR/pin_${TIME}.txt"
    notify-send "Clipboard" "Pinned current text!"
  fi
  exit 0
fi
if [ "$SELECTION" = "🗑️ Clear History" ]; then
  cliphist wipe
  notify-send "Clipboard" "History cleared"
  exit 0
fi

# 4. Handle Selection of a Pinned Item
if [[ "$SELECTION" == 📌* ]]; then
  FILE_NAME=$(echo "$SELECTION" | sed -E 's/📌 (\[IMAGE\] )?([^:]+).*/\2/')
  TARGET="$PIN_DIR/$FILE_NAME"

  ACTION=$(echo -e "1. Copy to Clipboard\n2. Delete Pin" | fuzzel -d --hide-prompt -w 25 -l 2 --font="Hurmit Nerd Font:size=11")

  case "$ACTION" in
  *"Copy to Clipboard"*)
    if [[ "$TARGET" == *.png ]]; then
      wl-copy --type image/png <"$TARGET"
      notify-send -t 3000 -i "$TARGET" "Clipboard" "Pinned image copied"
    else
      wl-copy <"$TARGET"
      PREVIEW=$(head -c 60 "$TARGET")
      notify-send -t 2000 "Clipboard" "Copied: $PREVIEW"
    fi
    ;;
  *"Delete Pin"*)
    rm -f "$TARGET"
    notify-send "Clipboard" "Unpinned item!"
    ;;
  esac
  exit 0
fi

# 5. Handle Selection of Regular Cliphist Item
if [[ "$SELECTION" == 󰅍* ]] || [[ "$SELECTION" == 󰋩* ]]; then
  LINE_NUM=$(echo "$CLIP_MENU" | grep -nF "$SELECTION" | head -1 | cut -d: -f1)
  ORIGINAL=$(echo "$CLIP_RAW" | sed -n "${LINE_NUM}p")
  TMPFILE=$(mktemp /tmp/clip_XXXX)
  echo "$ORIGINAL" | cliphist decode >"$TMPFILE"
  MIME=$(file --mime-type -b "$TMPFILE")
  if echo "$MIME" | grep -q "image/"; then
    wl-copy --type "$MIME" <"$TMPFILE"
    notify-send -t 3000 -i "$TMPFILE" "Clipboard" "Image copied"
  else
    wl-copy <"$TMPFILE"
    PREVIEW=$(cat "$TMPFILE" | head -c 60)
    notify-send -t 2000 "Clipboard" "Copied: $PREVIEW"
  fi
  rm -f "$TMPFILE"
fi
