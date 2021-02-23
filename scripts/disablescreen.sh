#!/bin/sh
xrandr --output HDMI-A-2 --off
xrandr --ouput DisplayPort-0 --mode 1920x1080 --rate 144
if wmrc reload; then
    "$WMRC_MODULES/ui/notify" info "wmrc" "Desktop configuration reloaded successfully.";
else
    $WMRC_MODULES/ui/notify" warn "wmrc" "An error occurred while reloading desktop configuration.\n$ERR";
fi
