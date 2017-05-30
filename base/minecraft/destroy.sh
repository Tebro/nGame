#!/bin/bash

# Backup everything except the server jar
# TODO: Should the jar file be backed up?
cd ~/mc
cp -r $(ls | grep -v minecraft.jar) /data/

