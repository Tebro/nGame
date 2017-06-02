#!/bin/bash

set -e

# Import global settings
source settings

# Strip potential trailing slash
TARGET=${1%/}

if [ -z "$1" ] || [ ! -d "$TARGET" ]; then
    echo "You must specify a target"
    exit
fi

if [ ! -f "$TARGET/settings" ]; then
    echo "The specified target does not have a settings file"
    exit
fi

if [ "$(grep "STACK_NAME=" $TARGET/settings | wc -l)" -eq 0 ]; then
    echo "No STACK_NAME specified in target settings"
    exit
fi

# Load settings from all levels
ALL_SETTINGS=$(bin/find-all-upwards.sh $TARGET settings)

while read -r line; do
    source $line
done <<< "$ALL_SETTINGS"

# Build final stack name based on target settings and global prefix
FULL_STACK_NAME="$STACK_NAME_PREFIX--$STACK_NAME"

# Find the most specific template
TEMPLATE=$(bin/find-template.sh $TARGET)

aws cloudformation create-stack \
    --stack-name $FULL_STACK_NAME \
    --template-body file://$TEMPLATE \
    --parameters ParameterKey=paramSshKeyName,ParameterValue=$SSH_KEY \
                 ParameterKey=paramVPCId,ParameterValue=$VPC_ID \
                 ParameterKey=paramSubnet,ParameterValue=$SUBNET \
                 ParameterKey=paramEFSSG,ParameterValue=$EFS_SG \
    | jq .StackId | tr -d '"' > /dev/null

echo "Waiting for stack to be created"
aws cloudformation wait stack-create-complete --stack-name $FULL_STACK_NAME

echo "Waiting for instance IP"
INSTANCE_IP=$(./bin/retrieve-instance-ip.sh $FULL_STACK_NAME)

if [ ! -z "$STACK_DNS" ] && [ ! -z "$R53_HOSTED_ZONE" ]; then
    echo "Creating DNS stack"
    aws cloudformation create-stack \
        --stack-name "$FULL_STACK_NAME--dns" \
        --template-body file://stack-dns.yaml \
        --parameters ParameterKey=paramHostedZoneId,ParameterValue=$R53_HOSTED_ZONE \
                     ParameterKey=paramDnsName,ParameterValue=$STACK_DNS \
                     ParameterKey=paramInstanceIp,ParameterValue=$INSTANCE_IP
fi

SSH_OPTS="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

set +e
echo "Waiting for SSH"
while true; do
    ssh -q $SSH_OPTS $SSH_USER@$INSTANCE_IP exit
    if [ "$?" -eq "0" ]; then break; fi
    sleep 1
done
set -e

# Start provisioning
echo "Transfering payload"
scp $SSH_OPTS $(bin/create-payload.sh $TARGET) $SSH_USER@$INSTANCE_IP:payload.tar.gz
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP tar zxvf payload.tar.gz
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP "mv tmp/payload payload; rm -r tmp"
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP chmod +x payload/server-boot.sh
echo "Provisioning server"
ssh -tt $SSH_OPTS $SSH_USER@$INSTANCE_IP "cd payload; ./server-boot.sh $TARGET $FULL_STACK_NAME"


