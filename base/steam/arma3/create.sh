#!/bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir -p ~/.local/share
cp -r /data/* ~/.local/share/

(crontab -l 2>/dev/null; echo "*/2 * * * * cp -r ~/.local/share/* /data/") | crontab -

mkdir -p ~/".local/share/Arma 3" && mkdir -p ~/".local/share/Arma 3 - Other Profiles"

cd ~/Steam
./steamcmd.sh +login "$STEAM_USER" "$STEAM_PASS" +force_install_dir ./arma +app_update 233780 +quit

cd arma
ln -s ./mpmissions MPMissions

sudo cp $DIR/armaserver.service /etc/systemd/system/armaserver.service
sudo systemctl daemon-reload

