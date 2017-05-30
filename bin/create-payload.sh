#!/bin/bash

TARGET=$1

# Generate name?
PAYLOAD_NAME="payload"

mkdir -p /tmp/$PAYLOAD_NAME

cp -r bin /tmp/$PAYLOAD_NAME
cp server-boot.sh server-teardown.sh settings /tmp/$PAYLOAD_NAME/

BASE="."

IFS='/' read -ra PATHS <<< "$TARGET"
for i in "${PATHS[@]}"; do
    BASE="$BASE/$i"
    mkdir /tmp/$PAYLOAD_NAME/$BASE
    cp $(find $BASE -maxdepth 1 -type f) /tmp/$PAYLOAD_NAME/$BASE/
done

tar -pczf /tmp/$PAYLOAD_NAME.tar.gz /tmp/$PAYLOAD_NAME

rm -rf /tmp/$PAYLOAD_NAME

echo /tmp/$PAYLOAD_NAME.tar.gz
