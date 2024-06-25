#!/bin/sh

OUTPUT=$(glab ci list -R https://gitlab.com/dna-platform/deepturnaround/apps/use-case-services/predictions | head -n3 | tail -n1 | awk '{print $1}')
SUCCESS_ICON=""

FAILED_ICON=""
SKIPPED_ICON=""
RUNNING_ICON=""
UNKNOWN_ICON=""

case $OUTPUT in
  "(success)")
    ICON=$SUCCESS_ICON
    ;;

  "(failed)")
    ICON=$FAILED_ICON
    ;;

  "(skipped)")
    ICON=$SKIPPED_ICON
    ;;

  "(running)")
    ICON=$RUNNING_ICON
    ;;

  *)
    ICON=$SUCCESS_ICON
    ;;
esac

sketchybar --set "$NAME" icon="$ICON"
