#!/bin/bash
setxkbmap -layout us -variant intl &
xrandr --output DP-0 --mode 2560x1440 --rate 144 --primary --output HDMI-0 --mode 1920x1080 --left-of DP-0 &
xinput set-prop 12 299 0.3 &
xinput set-prop 12 304 0, 1 &

sleep 2

eval `ssh-agent` &

picom --corner-radius 7 --refresh-rate 144 --no-vsync -c --backend glx -l 0 -t 0 -r 8 -o 0.3

glava &

spotifyd --backend pulseaudio \
    --device-name spotifyd \
    --autoplay \
    --zeroconf-port 4999 \
    --use-mpris true \
    -U "cat ~/.config/awesome/spotify_user" \
    -P "cat ~/.config/awesome/spotify_passwd" \
    --initial-volume 70 \
    --no-daemon &

crd --start &
feh --bg-scale ~/.config/awesome/images/solid_lighter.png &

sleep 2
