#!/bin/bash
echo "Space on VM"
df -h
sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-10-bootstrap-host.sh
CONTAINER_ID=$(sudo docker ps --latest --quiet)
sudo docker commit $CONTAINER_ID dlfs-1-host 
