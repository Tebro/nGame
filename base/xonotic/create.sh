#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

curl https://dl.xonotic.org/xonotic-0.8.2.zip -o ~/xonotic.zip
cd ~/
unzip xonotic.zip
cp ~/Xonotic/server/server_linux.sh ~/Xonotic/

cp $DIR/server.cfg ~/Xonotic/server/server.cfg

sudo cp $DIR/xonotic.service /etc/systemd/system/xonotic.service
sudo systemctl daemon-reload
