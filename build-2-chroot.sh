#!/bin/bash
sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-8.26_gcc-1-test-bootstrap-host.sh
CONTAINER_ID=$(sudo docker ps --latest --quiet)
sudo docker commit $CONTAINER_ID dlfs-1-host 
