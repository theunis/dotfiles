#!/bin/bash

# Path to the directory containing your daily notes
NOTES_DIR="/Users/theunvanvliet/Library/CloudStorage/GoogleDrive-theunis@gmail.com/My Drive/Notes/50-59 Life/51 Journal"
# Function to display help message
show_help() {
  echo "Usage: habit_tracker.sh [option]"
  echo
  echo "Options:"
  echo "  status       Display the current status of all habits"
  echo "  habit-name   Toggle the status of the specified habit"
  echo "  help         Show this help message"
  echo
  echo "Example:"
  echo "  habit_tracker.sh status"
  echo "  habit_tracker.sh habit-wake-up-with-alarm"
}

# Function to read the habit status
read_habit_status() {
  local habit=$1
  grep "^$habit: " "$LATEST_NOTE_PATH" | awk '{print $2}'
}

# Function to toggle the habit status
toggle_habit_status() {
  local habit=$1
  local status=$(read_habit_status "$habit")
  if [ "$status" == "true" ]; then
    sed -i "" "s/$habit: true/$habit: false/" "$LATEST_NOTE_PATH"
  else
    sed -i "" "s/$habit: false/$habit: true/" "$LATEST_NOTE_PATH"
  fi
}

# Get the latest daily note file (assuming YYYY-MM-DD.md format)
LATEST_NOTE=$(ls -t "$NOTES_DIR" | head -n 1)
LATEST_NOTE_PATH="$NOTES_DIR/$LATEST_NOTE"

# Extract habit properties with the prefix "habit-"
HABITS=$(grep "^habit-" "$LATEST_NOTE_PATH" | awk -F: '{print $1}')

# Check the argument passed to the script
case "$1" in
  status)
    # Count total and completed habits
    TOTAL_HABITS=$(echo "$HABITS" | wc -l)
    COMPLETED_HABITS=0
    for habit in $HABITS; do
      if [ "$(read_habit_status "$habit")" == "true" ]; then
        ((COMPLETED_HABITS++))
      fi
    done

    # Display the status of habits
    echo "Habits: $COMPLETED_HABITS/$TOTAL_HABITS"
    printf "%-25s %s\n" "Habit" "Status"
    echo "----------------------------------------"
    for habit in $HABITS; do
      name=${habit#habit-}
      status=$(read_habit_status "$habit")
      if [ "$status" == "true" ]; then
        printf "%-25s %s\n" "$name" "✅"
      elif [ "$status" == "false" ]; then
        printf "%-25s %s\n" "$name" "❌"
      else
        printf "%-25s %s\n" "$name" "⚪"  # Indicate skipped habits with a white circle emoji
      fi
    done
    ;;
  help)
    show_help
    ;;
  *)
    # Toggle habit if a valid habit name is passed
    if [[ " $HABITS " =~ " $1 " ]]; then
      toggle_habit_status "$1"
      echo "Toggled habit: $1"
    else
      echo "Unknown option or habit: $1"
      show_help
    fi
    ;;
esac
