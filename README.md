# Docker Linux From Scratch
Another [Linux From Scratch](https://www.linuxfromscratch.org/) build in Docker. Using [Version 11.0-systemd](https://www.linuxfromscratch.org/lfs/view/stable-systemd/)

# To do
[] Fail the build on unexpected test failures

# Install Instructions
(This install process is a bit clunky, and will be made much simpler soon)
1. Download latest build artefact from the latest passing [build](https://github.com/jdoxey/dlfs/actions)
1. Unzip the downloaded file
    ```
    unzip action_image_artifact_dlfs-1-host_latest.zip
    ```
1. Load the image into docker (probably as `root`, depending on your setup)
    ```
    docker load < dlfs-1-host_latest
    ```
1. Format and mount the partition for your new target root (/) file system.
   
   Warning! This will delete everything on this partition. Backup any important data first.
    ```
    mkfs.ext4 /dev/nvme0n1p5

    mkdir /mnt/lfs
    mount /dev/nvme0n1p5 /mnt/lfs
    ```
1. Copy file system contents from docker to your new root partition. As `root` run,
    ```
    LFS_CONTAINER_ID=$(docker run dlfs-1-host bash)
    docker cp $LFS_CONTAINER_ID:/mnt/lfs /mnt
    docker rm -v $LFS_CONTAINER_ID
    ```
1. Enter the chroot environment,
    ```
    LFS=/mnt/lfs

    # Prepare virtual kernel file systems (only if not already mounted)
    mount -v --bind /dev $LFS/dev
    mount -v --bind /dev/pts $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run
    if [ -h $LFS/dev/shm ]; then
        mkdir -pv $LFS/$(readlink $LFS/dev/shm)
    fi

    # Enter chroot environment
    chroot "$LFS" /usr/bin/env -i   \
        HOME=/root                  \
        TERM="$TERM"                \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/usr/bin:/usr/sbin     \
        /bin/bash --login +h
    ```
1. Complete the [Linux From Scratch Chapter 9 System Configuration](https://linuxfromscratch.org/lfs/view/stable-systemd/chapter09/chapter09.html)
