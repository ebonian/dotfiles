#!/usr/bin/env bash
# Disable middle-click paste by continuously clearing the primary selection
# This makes middle-click behave like Windows (nothing happens)

while true; do
    # Watch for primary selection changes and immediately clear them
    wl-paste --primary --watch wl-copy --primary --clear 2>/dev/null &
    wait $!
    # If the above command fails, wait a bit before retrying
    sleep 1
done
