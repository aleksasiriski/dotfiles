#!/bin/sh
xrandr --output DisplayPort-0 --mode 1920x1080 --rate 144
xrandr --output HDMI-A-2 --auto --above DisplayPort-0 --mode 1920x1080 --rate 75
if wmrc reload; then
    "$WMRC_MODULES/ui/notify" info "wmrc" "Desktop configuration reloaded successfully.";
else
    $WMRC_MODULES/ui/notify" warn "wmrc" "An error occurred while reloading desktop configuration.\n$ERR";
fi
