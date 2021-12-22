#!/bin/bash
echo "Space on VM before;"
df -h
echo "Docker disk usage after;"
sudo docker system df

sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-10-bootstrap-host.sh
CONTAINER_ID=$(sudo docker ps --latest --quiet)

echo "Space on VM after;"
df -h
echo "Docker disk usage after;"
sudo docker system df
echo "Disk usage;"
sudo du -h -d 2 --exclude="boot" --exclude="dev" --exclude="proc" --exclude="run" --exclude="sys" /

sudo docker commit $CONTAINER_ID dlfs-1-host
