#!/bin/bash

TARGET=$1

while true; do
    if [ -f "$TARGET/template.yaml" ]; then
        echo "$TARGET/template.yaml"
        break
    else
        TARGET="$TARGET/.."
    fi
done

