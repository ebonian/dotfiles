#!/usr/bin/env bash

if eww active-windows | grep -q "bar"; then
  wofi --show drun --xoffset=1480 --yoffset=10 --width=258px --height=1101
else
  wofi --show drun --xoffset=1528 --yoffset=10 --width=258px --height=1101
fi