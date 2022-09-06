#!/bin/sh

IGNITION_RAW=ignition.img
IGNITION_MOUNT="mnt"

if [ ! -f "$IGNITION_RAW" ]; then
    echo "Creating $IGNITION_RAW"
    dd if=/dev/zero of=$IGNITION_RAW bs=1 count=0 seek=10M
    mkfs.ext4 $IGNITION_RAW
    e2label $IGNITION_RAW ignition
fi

echo "Mounting $IGNITION_RAW"
[ -d $IGNITION_MOUNT ] mkdir $IGNITION_MOUNT
sudo mount $IGNITION_RAW $IGNITION_MOUNT

echo "Creating Ignition"
butane -p ignition/config.fcc -o ignition/config.ign

echo "Copying combustion + ignition"
sudo rm -rf $IGNITION_MOUNT/combustion/*  $IGNITION_MOUNT/ignition/*
sudo cp -r ./combustion $IGNITION_MOUNT
sudo cp -r ./ignition  $IGNITION_MOUNT

echo "Cleaning up"
sudo umount $IGNITION_MOUNT
sudo rm -r $IGNITION_MOUNT