#!/bin/bash

FULL_STACK_NAME=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sudo mkdir -p /mnt/nfs

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $EFS_DOMAIN:/ /mnt/nfs
sudo chmod 777 /mnt/nfs

# this is not run as root on purpose, let the user own it.
mkdir -p /mnt/nfs/$FULL_STACK_NAME

sudo ln -s /mnt/nfs/$FULL_STACK_NAME /data

