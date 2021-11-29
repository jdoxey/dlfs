#!/bin/bash
sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-7.3-7.4-host.sh
CONTAINER_ID=$(sudo docker ps -a | awk '$2 == "dlfs-1-host" { print $1; exit }')
sudo docker commit $CONTAINER_ID dlfs-1-host 
sudo docker system prune --force
