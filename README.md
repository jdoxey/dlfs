# Docker Linux From Scratch
Another [Linux From Scratch](https://www.linuxfromscratch.org/) build in Docker. Using [Version 11.0-systemd](https://www.linuxfromscratch.org/lfs/view/stable-systemd/)

# To do
[] Fail the build on unexpected test failures

# Install Instructions
(This install process is a bit clunky, and will be made much simpler soon)
1. Download latest build artefact
1. Unzip the downloaded file
    ```
    unzip action_image_artifact_dlfs-1-host_latest.zip
    ```
1. Load the image into docker
    ```
    docker load < dlfs-1-host_latest
    ```
1. Format and mount your new root (/) file system. 
   
   Warning! This will delete everything on this partition. Backup any important data first.
    ```
    mkfs.ext4 /dev/nvme0n1p5

    mkdir /mnt/lfs
    mount /dev/nvme0n1p5 /mnt/lfs
    ```
1. Copy file system contents from docker to your new root partition. As `root` run,
    ```
    LFS_CONTAINER_ID=$(docker run dlfs-1-host bash)
    docker cp $LFS_CONTAINER_ID:/ /mnt/lfs
    docker rm -v $LFS_CONTAINER_ID
    ```
1. Complete the [Linux From Scratch Chapter 9 System Configuration](https://linuxfromscratch.org/lfs/view/stable-systemd/chapter09/chapter09.html)
