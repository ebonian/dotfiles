#!/usr/bin/env bash
# Toggle the discrete NVIDIA RTX 4060 between:
#   Integrated -> dGPU fully powered off (best battery, mobile use)
#   Hybrid     -> dGPU available on demand (needed for external monitors / CUDA / NVENC)
#
# Switching modes requires LOGGING OUT of the Hyprland session to take effect
# (supergfxd needs the GPU to be free). Always switch back to Hybrid BEFORE
# plugging in an external monitor — the HDMI/USB-C outputs are muxed to the dGPU.

current="$(supergfxctl -g)"

case "$current" in
    Integrated) target="Hybrid" ;;
    *)          target="Integrated" ;;
esac

if ! out="$(supergfxctl -m "$target" 2>&1)"; then
    notify-send "GPU Mode" "Failed to switch to $target:\n$out" -u critical
    echo "Error: $out"
    exit 1
fi

if [ "$target" = "Integrated" ]; then
    hint="dGPU will power OFF. Log out to apply.\n⚠ Switch back to Hybrid before external monitors."
else
    hint="dGPU available again. Log out to apply."
fi

notify-send "GPU Mode → $target" "$hint" -u normal -t 6000
echo "Switched $current → $target ($out)"
