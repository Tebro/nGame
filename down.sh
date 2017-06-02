#!/bin/bash

source settings

# Strip potential trailing slash
TARGET=${1%/}

if [ -z "$1" ] || [ ! -d "$TARGET" ]; then
    echo "You must specify a target"
    exit
fi

# Load settings from all levels
ALL_SETTINGS=$(bin/find-all-upwards.sh $TARGET settings)

while read -r line; do
    source $line
done <<< "$ALL_SETTINGS"

# Build final stack name based on target settings and global prefix
FULL_STACK_NAME="$STACK_NAME_PREFIX--$STACK_NAME"

INSTANCE_IP=$(./bin/retrieve-instance-ip.sh $FULL_STACK_NAME)

SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

echo "Triggering teardown on server"
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP chmod +x payload/server-teardown.sh
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP "cd payload; ./server-teardown.sh $TARGET $FULL_STACK_NAME"

aws cloudformation delete-stack --stack-name "$FULL_STACK_NAME--dns"
aws cloudformation delete-stack --stack-name $FULL_STACK_NAME
echo "Waiting for stack to be deleted"
aws cloudformation wait stack-delete-complete --stack-name $FULL_STACK_NAME

