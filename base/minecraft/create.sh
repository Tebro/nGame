#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mkdir ~/mc

curl https://s3.amazonaws.com/Minecraft.Download/versions/1.11.2/minecraft_server.1.11.2.jar -o ~/mc/minecraft.jar

# Load from backup if it exists
if [ -d "/data/world" ]; then
    cp -r /data/* ~/mc/
else
    # We need to have the EULA even for new servers
    cp $DIR/eula.txt ~/mc/eula.txt
fi

cp $DIR/server.properties ~/mc/server.properties

# Build backup script
# Backup everything except the server jar
# TODO: Should the jar file be backed up?
cat <<EOF > ~/backup.sh
cd ~/mc
cp -r \$(ls |grep -v minecraft.jar) /data/
EOF
chmod +x ~/backup.sh
# Setup crontab
(crontab -l 2>/dev/null; echo "*/2 * * * * ~/backup.sh") | crontab -

sudo cp $DIR/minecraft.service /etc/systemd/system/minecraft.service
sudo systemctl daemon-reload
