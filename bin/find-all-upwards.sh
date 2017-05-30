#!/bin/bash

TARGET=$1
FILENAME=$2

BASE="."

# Split path by / into $PATHS
IFS='/' read -ra PATHS <<< "$TARGET"
for i in "${PATHS[@]}"; do
    BASE="$BASE/$i"
    if [ -f "$BASE/$FILENAME" ]; then echo "$BASE/$FILENAME"; fi
done

