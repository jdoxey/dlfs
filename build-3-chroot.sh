#!/bin/bash

# clear some space, from: https://github.com/actions/virtual-environments/issues/2606
sudo rm -rf /usr/local/lib/android # will release about 10 GB if you don't need Android
sudo rm -rf /usr/share/dotnet # will release about 20GB if you don't need .NET

sudo docker run --privileged=true dlfs-1-host /mnt/lfs/root/chapter-8.26_bootstrap-host.sh
CONTAINER_ID=$(sudo docker ps -a | awk '$2 == "dlfs-1-host" { print $1; exit }')
sudo docker commit $CONTAINER_ID dlfs-1-host 
