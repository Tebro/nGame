#!/bin/bash

TARGET=$1

ALL_STOP=$(bin/find-all-upwards.sh $TARGET stop.sh | tac -)

echo "Lifecycle: Stop"
while read -r line; do
    chmod +x ./$line
    ./$line $STACK_NAME
done <<< "$ALL_STOP"

ALL_DESTROY=$(bin/find-all-upwards.sh $TARGET destroy.sh | tac -)

echo "Lifecycle: Destroy"
while read -r line; do
    chmod +x ./$line
    ./$line $STACK_NAME
done <<< "$ALL_DESTROY"

