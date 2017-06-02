#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


if [ ! -f $DIR/factorio.tar.gz ]; then
    echo "ERROR: No factorio server found in payload, please download the server from: https://www.factorio.com/download-headless and store it as base/factorio/factorio.tar.gz"
    exit 1
fi

cp $DIR/factorio.tar.gz ~/

cd ~
tar zxvf factorio.tar.gz

cd ~/factorio
# Load from backup if it exists
if [ -f "/data/savegame.zip" ]; then
    echo "Found savegame"
else
    echo "Creating savegame"
    ./bin/x64/factorio --create /data/savegame.zip
fi

cp $DIR/server-settings.json ~/factorio/server-settings.json

sudo cp $DIR/factorio.service /etc/systemd/system/factorio.service
sudo systemctl daemon-reload
