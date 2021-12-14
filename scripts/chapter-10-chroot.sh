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

# Disable DEBUG_INFO_BTF to get past following error,
#
#     BTF: .tmp_vmlinux.btf: pahole (pahole) is not available
#     Failed to generate BTF for vmlinux
#     Try to disable CONFIG_DEBUG_INFO_BTF
# TODO: find out the benefit of DEBUG_INFO_BTF and install pahole/dwarves if it looks necessary
sed -i 's/CONFIG_DEBUG_INFO_BTF=y/# CONFIG_DEBUG_INFO_BTF is not set/' .config

make all
make htmldocs
