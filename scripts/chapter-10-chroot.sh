#!/bin/bash

cd /sources
tar -xf v5.13.12-1.tar.gz
tar -xf linux-5.13.12.tar.xz

cd linux-5.13.12

for patchFile in ../mbp-16.1-linux-wifi-5.13.12-1/*.patch
do
    echo "Applying patch: $patchFile"
    patch -Np1 < $patchFile
done

cp ../mbp-16.1-linux-wifi-5.13.12-1/config .config
make olddefconfig

make all
make htmldocs
