#!/bin/bash
sudo docker build -t dlfs-1-host .
sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-7.3-7.4-host.sh
CONTAINER_ID=$(sudo docker ps --latest --quiet)
sudo docker commit $CONTAINER_ID dlfs-1-host 
