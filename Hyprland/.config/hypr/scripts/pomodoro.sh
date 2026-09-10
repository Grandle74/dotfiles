#!/usr/bin/env bash

STATE_FILE="/tmp/pomodoro_state"
PID_FILE="/tmp/pomodoro_pid"
SCRIPT_PATH=$(readlink -f "$0")

# Sound player setup (uses default system sounds)
play_sound() {
  canberra-gtk-play -i "$1" >/dev/null 2>&1 || paplay /usr/share/sounds/freedesktop/stereo/"$1".oga >/dev/null 2>&1 &
}

# --- WAYBAR STATUS OUTPUT ---
if [ "$1" = "status" ]; then
  if [ -f "$STATE_FILE" ]; then
    source "$STATE_FILE"
    NOW=$(date +%s)
    REMAIN=$((END_TIME - NOW))

    if [ "$REMAIN" -gt 0 ]; then
      MINS=$((REMAIN / 60))
      SECS=$((REMAIN % 60))
      TIME_STR=$(printf "%02d:%02d" "$MINS" "$SECS")

      if [ "$MODE" = "focus" ]; then
        echo "{\"text\": \"🍅 $TIME_STR\", \"class\": \"focus\", \"tooltip\": \"Focus Time (#$CYCLE)\"}"
      else
        echo "{\"text\": \"☕ $TIME_STR\", \"class\": \"break\", \"tooltip\": \"Break Time\"}"
      fi
      exit 0
    fi
  fi
  echo '{"text": "", "class": "inactive"}'
  exit 0
fi

# --- DAEMON LOOP ---
if [ "$1" = "daemon" ]; then
  CYCLE=1
  while true; do
    # 1. Focus Phase (25m)
    DURATION=1500
    END_TIME=$(($(date +%s) + DURATION))
    echo "END_TIME=$END_TIME; MODE='focus'; CYCLE=$CYCLE" >"$STATE_FILE"
    pkill -RTMIN+2 waybar
    play_sound "bell"
    notify-send -u normal "Pomodoro Started" "Focus session #$CYCLE (25 min)"

    sleep $DURATION

    # 2. Break Phase Choice (4th cycle = 15m Long Break, else 5m Short Break)
    if [ $((CYCLE % 4)) -eq 0 ]; then
      DURATION=900
      MODE_NAME="Long Break"
      NOTIF_MSG="Great job! Take a well-deserved 15 minute break!"
    else
      DURATION=300
      MODE_NAME="Short Break"
      NOTIF_MSG="Good job... Now take a quick 5 minute break!"
    fi

    END_TIME=$(($(date +%s) + DURATION))
    echo "END_TIME=$END_TIME; MODE='break'; CYCLE=$CYCLE" >"$STATE_FILE"
    pkill -RTMIN+2 waybar
    play_sound "complete"
    notify-send -u critical "⏰ Focus Ended!" "$NOTIF_MSG"

    sleep $DURATION

    CYCLE=$((CYCLE + 1))
  done
fi

# --- STOP LOGIC ---
stop_pomodoro() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" >/dev/null 2>&1
    rm -f "$PID_FILE"
  fi
  rm -f "$STATE_FILE"
  pkill -RTMIN+2 waybar
}

# --- FUZZEL INTERACTIVE MENU ---
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  # TIMER IS RUNNING
  CHOICE=$(echo -e "1. ☕ Short Break (5m)\n2. 🛋️ Long Break (15m)\n3. ⏹️ Stop Pomodoro" | fuzzel -d --hide-prompt -w 25 -l 3)

  case "$CHOICE" in
  *"Short Break"*)
    stop_pomodoro
    END_TIME=$(($(date +%s) + 300))
    echo "END_TIME=$END_TIME; MODE='break'; CYCLE=0" >"$STATE_FILE"
    pkill -RTMIN+2 waybar
    play_sound "message"
    notify-send "Pomodoro" "Switched to 5 minute break."
    (
      sleep 300
      "$SCRIPT_PATH" daemon &
      echo $! >"$PID_FILE"
    ) &
    echo $! >"$PID_FILE"
    ;;
  *"Long Break"*)
    stop_pomodoro
    END_TIME=$(($(date +%s) + 900))
    echo "END_TIME=$END_TIME; MODE='break'; CYCLE=0" >"$STATE_FILE"
    pkill -RTMIN+2 waybar
    play_sound "message"
    notify-send "Pomodoro" "Switched to 15 minute break."
    (
      sleep 900
      "$SCRIPT_PATH" daemon &
      echo $! >"$PID_FILE"
    ) &
    echo $! >"$PID_FILE"
    ;;
  *"Stop Pomodoro"*)
    stop_pomodoro
    notify-send "Pomodoro" "Timer stopped."
    ;;
  esac
else
  # TIMER IS NOT RUNNING
  CHOICE=$(echo -e "1. 🍅 Start Pomodoro" | fuzzel -d --hide-prompt -w 25 -l 1)

  if [[ "$CHOICE" == *"Start Pomodoro"* ]]; then
    "$SCRIPT_PATH" daemon &
    echo $! >"$PID_FILE"
  fi
fi
