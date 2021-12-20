#!/bin/bash
echo "Space on VM before;"
df -h
echo "Docker disk usage after;"
sudo docker df

sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-10-bootstrap-host.sh
CONTAINER_ID=$(sudo docker ps --latest --quiet)

echo "Space on VM after;"
df -h
echo "Docker disk usage after;"
sudo docker df

sudo docker commit $CONTAINER_ID dlfs-1-host
