#!/bin/bash

log() {
	echo ""
	echo "*** $1 ***"
}


log "5.2. Binutils-2.37 - Pass 1"

cd $LFS/sources
tar -xf binutils-2.37.tar.xz
cd binutils-2.37

mkdir -v build
cd       build
../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --disable-werror
make
make install -j1

cd ..
rm -rf build

cd ..
# rm -rf binutils-2.37    # used later


log "5.3. GCC-11.2.0 - Pass 1"

cd $LFS/sources
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd       build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$LFS/tools                            \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

cd ..
rm -rf gcc-11.2.0


log "5.4. Linux-5.13.12 API Headers"

cd $LFS/sources
tar -xf linux-5.13.12.tar.xz
cd linux-5.13.12

make mrproper

make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr

cd ..
rm -rf linux-5.13.12


log "5.5. Glibc-2.34"

cd $LFS/sources
tar -xf glibc-2.34.tar.xz
cd glibc-2.34

case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac

patch -Np1 -i ../glibc-2.34-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib

make

make DESTDIR=$LFS install

sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

$LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

cd ..

cd ..
rm -rf glibc-2.34


log "5.6. Libstdc++ from GCC-11.2.0, Pass 1"

cd $LFS/sources
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

make

make DESTDIR=$LFS install

cd ..

cd ..
rm -rf gcc-11.2.0


log "6.2. M4-1.4.19"

cd $LFS/sources
tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf m4-1.4.19


log "6.3. Ncurses-6.2"

cd $LFS/sources
tar -xf ncurses-6.2.tar.gz
cd ncurses-6.2

sed -i s/mawk// configure

mkdir build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec

make

make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

cd ..
rm -rf ncurses-6.2


log "6.4. Bash-5.1.8"

cd $LFS/sources
tar -xf bash-5.1.8.tar.gz
cd bash-5.1.8

./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc

make

make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh

cd ..
rm -rf bash-5.1.8


log "6.5. Coreutils-8.32"

cd $LFS/sources
tar -xf coreutils-8.32.tar.xz
cd coreutils-8.32

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make

make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8

cd ..
rm -rf coreutils-8.32


log "6.6. Diffutils-3.8"

cd $LFS/sources
tar -xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install

cd ..
rm -rf diffutils-3.8


log "6.7. File-5.40"

cd $LFS/sources
tar -xf file-5.40.tar.gz
cd file-5.40

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file

make DESTDIR=$LFS install

cd ..
rm -rf file-5.40


log "6.8. Findutils-4.8.0"

cd $LFS/sources
tar -xf findutils-4.8.0.tar.xz
cd findutils-4.8.0

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf findutils-4.8.0


log "6.9. Gawk-5.1.0"

cd $LFS/sources
tar -xf gawk-5.1.0.tar.xz
cd gawk-5.1.0

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf gawk-5.1.0


log "6.10. Grep-3.7"

cd $LFS/sources
tar -xf grep-3.7.tar.xz
cd grep-3.7

./configure --prefix=/usr   \
            --host=$LFS_TGT

make

make DESTDIR=$LFS install

cd ..
rm -rf grep-3.7


log "6.11. Gzip-1.10"

cd $LFS/sources
tar -xf gzip-1.10.tar.xz
cd gzip-1.10

./configure --prefix=/usr --host=$LFS_TGT

make

make DESTDIR=$LFS install

cd ..
rm -rf gzip-1.10


log "6.12. Make-4.3"

cd $LFS/sources
tar -xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf make-4.3


log "6.13. Patch-2.7.6"

cd $LFS/sources
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf patch-2.7.6


log "6.14. Sed-4.8"

cd $LFS/sources
tar -xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/usr   \
            --host=$LFS_TGT

make

make DESTDIR=$LFS install

cd ..
rm -rf sed-4.8


log "6.15. Tar-1.34"

cd $LFS/sources
tar -xf tar-1.34.tar.xz
cd tar-1.34

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

make

make DESTDIR=$LFS install

cd ..
rm -rf tar-1.34


log "6.16. Xz-5.2.5"

cd $LFS/sources
tar -xf xz-5.2.5.tar.xz
cd xz-5.2.5

./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5

make

make DESTDIR=$LFS install

cd ..
rm -rf xz-5.2.5


log "6.17. Binutils-2.37 - Pass 2"

cd $LFS/sources/binutils-2.37

mkdir -v build
cd       build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd

make

make DESTDIR=$LFS install -j1
install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib

cd ..

cd ..
rm -rf binutils-2.37


log "6.18. GCC-11.2.0 - Pass 2"

cd $LFS/sources
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

mkdir -pv $LFS_TGT/libgcc
ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h

../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --prefix=/usr                                  \
    CC_FOR_TARGET=$LFS_TGT-gcc                     \
    --with-build-sysroot=$LFS                      \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make

make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

cd ..

cd ..
rm -rf gcc-11.2.0
