#!/bin/bash

STACK_NAME=$1

ASG_ID=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq '.StackResources | map(select(.ResourceType | contains("AutoScalingGroup")))[0].PhysicalResourceId' | tr -d '"')

while true; do
    NUM_INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_ID | jq '.AutoScalingGroups[0].Instances | length')
    if [ "$NUM_INSTANCES" -gt "0" ]; then break; fi
    sleep 1
done

INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG_ID | jq '.AutoScalingGroups[0].Instances[0].InstanceId' | tr -d '"')
INSTANCE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID |jq '.Reservations[0].Instances[0].PublicIpAddress' | tr -d '"')

echo $INSTANCE_IP
