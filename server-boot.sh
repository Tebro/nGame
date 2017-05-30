#!/bin/bash

set -e

# This file is to run on the instance
TARGET=$1
FULL_STACK_NAME=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load and export all settings

while read -r line; do
    # Allow comments in the files
    if echo $line | grep -q "#"; then
        continue
    fi
    export $line
done <<< "$(cat $DIR/settings $($DIR/bin/find-all-upwards.sh $TARGET settings))"

echo "Installing packages"
ALL_PACKAGE_LISTS=$(cat $($DIR/bin/find-all-upwards.sh $TARGET packages.txt))

sudo apt-get update && sudo apt-get install -y $ALL_PACKAGE_LISTS

ALL_CREATE=$($DIR/bin/find-all-upwards.sh $TARGET create.sh)
echo "Lifecycle: Create"
while read -r line; do
    chmod +x ./$line
    ./$line $STACK_NAME
done <<< "$ALL_CREATE"

ALL_START=$($DIR/bin/find-all-upwards.sh $TARGET start.sh)
echo "Lifecycle: Start"
while read -r line; do
    chmod +x ./$line
    ./$line $STACK_NAME
done <<< "$ALL_START"

