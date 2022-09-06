#!/bin/bash

IGNITION_RAW=ignition.img
IGNITION_MOUNT="mnt"

LICENSE_KEY=''
SCC_EMAIL=''
K3S_VERSION='latest'

print_usage() {
  printf "Usage: ./generate.sh -r <LICENSE_KEY> -e <SCC_EMAIL> -v <K3S_VERSION>"
}

while getopts 'r:e:v:' flag; do
  case "${flag}" in
    r) LICENSE_KEY="${OPTARG}" ;;
    e) SCC_EMAIL="${OPTARG}" ;;
    v) K3S_VERSION="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

sed -i "s|<LICENSE_KEY>|$LICENSE_KEY|g" combustion/script
sed -i "s|<SCC_EMAIL>|$SCC_EMAIL|g" combustion/script
sed -i "s|<K3S_VERSION>|$K3S_VERSION|g" combustion/script

if [ ! -f "$IGNITION_RAW" ]; then
    echo "Creating $IGNITION_RAW"
    dd if=/dev/zero of=$IGNITION_RAW bs=1 count=0 seek=10M
    mkfs.ext4 $IGNITION_RAW
    e2label $IGNITION_RAW ignition
fi

echo "Mounting $IGNITION_RAW"
mkdir $IGNITION_MOUNT
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
# Revert Settings
sed -i "s|$LICENSE_KEY|<LICENSE_KEY>|g" combustion/script
sed -i "s|$SCC_EMAIL|<SCC_EMAIL>|g" combustion/script
sed -i "s|$K3S_VERSION|<K3S_VERSION>|g" combustion/script