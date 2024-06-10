#!/bin/sh

# Call the habit tracker script and get the output
OUTPUT=$(~/dotfiles/habit_tracker.sh status)

# Extract the habit counts from the output
COMPLETED_HABITS=$(echo "$OUTPUT" | awk -F'[ :/]' '{print $3}')
TOTAL_HABITS=$(echo "$OUTPUT" | awk -F'[ :/]' '{print $4}')

# If the counts are empty, set default values
COMPLETED_HABITS=${COMPLETED_HABITS:-0}
TOTAL_HABITS=${TOTAL_HABITS:-0}

# Set the icon (use a generic icon here, you can customize it)
ICON=""  # Example icon (clipboard list icon)

# Update the Sketchybar item with the habit counts
sketchybar --set "$NAME" icon="$ICON" label="$COMPLETED_HABITS/$TOTAL_HABITS"
