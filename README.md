# Using Combustion and Ignition during a SLE Micro bootstrapping

## Introduction

SLE Micro can be installed on a system in a variety of ways. One interesting way is by using the [RAW image](https://www.suse.com/download/sle-micro/).
The RAW image is a disk image that can be "flashed" into a boot disk. It has a standard functioning SLE Micro installation that boot up a bare metal server or a VM.
Since, by default, the RAW image does not setup users or even a root user, it needs to be configured.

This is done using configuration files available on a secondary disk (USB stick, secondary VM volume, etc.).

There are two possibilities to configure a RAW SLE Micro installation:
- Ignition
- Combustion

## Ignition

Ignition is basically a JSON file that is similar in function to "Cloudinit", it has a limited set of capabilites but can be used to bootstrap single things like users and storage configuration. However, it is not possible to install Packages during bootstrapping using Ignition. Additional Combustion configuration is needed for that.

Since JSON is not easily "human-writable", it is recommended to create an ignition file first in YAML and then use a specific conversion tool called `butane` to transform YAML into JSON.
More on the procedure [here](https://documentation.suse.com/sle-micro/5.0/single-html/SLE-Micro-installation/index.html#sec-slem-image-deployment).

For an example ignition configuration in YAML, checkout [config.fcc](./ignition/config.fcc).
For the resulting JSON file, checkout [config.ign](./ignition/config.ign)

## Combustion

Combustion is an additional way of bootstrapping SLE Micro, it can be used instead or in conjunction with ignition.
Combustion works exactly like a bash script, with some markers as comments like `#combustion: network` which means all instructions coming after the comment will be executed after the network has been bootstrapped.

Combustion can be used to install packages, configure the system, etc.
Things to know:
- Combustion is executed after ignition, which means they will override settings if these were set in ignition
- Combustion works in a stage where `transactional-update` is not needed. For example, if a package needs to be installed, don't use `transactional-update pkg install -y XYZ` but `zypper install -y XYZ`

# Configure a disk with ignition and combustion
When bootstrapping a SLE Micro RAW image on a machine (physical or virtual), ignition and/or combustion files need to be present on a secondary disk. This disk can be a USB Stick for physical machines, and probably a volume for virtual machines.

I find the easiest way to achieve both is to create an IMG file which can be either mounted to a virtualization tool as a volume or flashed into a USB key.

An IMG file can be easily created using the `dd` command:
```bash
sudo dd if=/dev/zero of=$HOME/ignition.img bs=1 count=0 seek=1G
```

Now, a Filesystem can be create on the IMG "disk":
```bash
sudo mkfs.ext4 $HOME/ignition.img
```

Now, **IMPORTANT** , we need to label the IMG file so that it is recognized by SLE Micro:

```bash
sudo e2label $HOME/ignition.img ignition
```

Now, we need to mount the IMG file somewhere to copy the configuration files to it:
```bash
sudo mkdir /mnt/ignition
sudo mount $HOME/ignition.img /mnt/ignition
sudo cp -r ./combustion /mnt/ignition/
sudo cp -r ./ignition /mnt/ignition/
sudo umount $HOME/ignition.img
````

Now, our IMG file contains the ignition and combustion configuration files and can be mounted/flashed to the target disk.

Keep in mind that the IMG content should look like the following:
- combustion
    - script
- ignition
    - config.fcc (not necessary, only for your reference)
    - config.ign

# Booting SLE Micro
Now that you have the RAW image and the IMG image at your disposal, you either flash those into physical disks or mount them as volume in your virtualization environment for SLE Micro to bootstrap automatically.