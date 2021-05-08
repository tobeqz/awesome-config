#!/bin/bash
setxkbmap -layout us -variant intl &
xrandr --output DP-0 --mode 2560x1440 --rate 144 --primary --output HDMI-0 --mode 1920x1080 --left-of DP-0 &
xinput set-prop 12 299 0.3 &
xinput set-prop 12 304 0, 1 &

sleep 2

eval `ssh-agent` &

picom --fading --fade-delta 5 --corner-radius 5 --vsync --refresh-rate 144 --backend glx -b &

glava &

SPOTIFY_USER=$(cat ./spotify_user)
SPOTIFY_PASSWD=$(cat ./spotify_passwd)

spotifyd --backend pulseaudio --device-name spotifyd --autoplay --zeroconf-port 4999 --use-mpris true -u "$SPOTIFY_PASSWD" -p "$SPOTIFY_PASSWD" --initial-volume 70 --no-daemon &

crd --start &
feh --bg-scale ~/Pictures/wallpapers/purple_sunset_river.jpg &