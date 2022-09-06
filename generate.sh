#!/bin/sh

IGNITION_RAW=ignition.img
if [ ! -f "$IGNITION_RAW" ]; then
    echo "Creating $IGNITION_RAW"
    dd if=/dev/zero of=$IGNITION_RAW bs=1 count=0 seek=10M
    mkfs.ext4 $IGNITION_RAW
    e2label $IGNITION_RAW ignition
fi

IGNITION_MOUNT="/run/media/$(whoami)/ignition"

echo "Creating Ignition + Combustion Image"
udisksctl loop-setup -f $IGNITION_RAW
sleep 1

echo "Creating Ignition"
butane -p ignition/config.fcc -o ignition/config.ign

sudo rm -rf $IGNITION_MOUNT/combustion/*  $IGNITION_MOUNT/ignition/*
sudo cp -r ./combustion $IGNITION_MOUNT
sudo cp -r ./ignition  $IGNITION_MOUNT
umount $IGNITION_MOUNT