#!/bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


cd ~/Steam
./steamcmd.sh +login "$STEAM_USER" "$STEAM_PASS" +force_install_dir ./starbound +app_update 211820 +quit


sudo cp $DIR/starbound.service /etc/systemd/system/starbound.service
sudo systemctl daemon-reload

