#!/bin/bash

log() {
	echo ""
	echo "*** $1 ***"
}


log "8.26. GCC-11.2.0 (install)"

cd /sources/gcc-11.2.0/build

make install
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/

chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}

ln -svr /usr/bin/cpp /usr/lib

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

log "some sanity checks"
echo 'int main(){}' > dummy.c
cat dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
cat dummy.log
readelf -l a.out | grep ': /lib'

log "make sure that we're setup to use the correct start files"
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

log "Verify that the compiler is searching for the correct header files"
grep -B4 '^ /usr/include' dummy.log

log "verify that the new linker is being used with the correct search paths"
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

log "make sure that we're using the correct libc"
grep "/lib.*/libc.so.6 " dummy.log

log "Make sure GCC is using the correct dynamic linker"
grep found dummy.log

cd ..

cd ..
rm -rf gcc-11.2.0

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib


log "8.27. Pkg-config-0.29.2"

tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2

make

make check

make install

cd ..
rm -rf pkg-config-0.29.2


log "8.28. Ncurses-6.2"

tar -xf ncurses-6.2.tar.gz
cd ncurses-6.2

./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec

make

make install

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

rm -fv /usr/lib/libncurses++w.a

mkdir -v       /usr/share/doc/ncurses-6.2
cp -v -R doc/* /usr/share/doc/ncurses-6.2

cd ..
rm -rf ncurses-6.2


log "8.29. Sed-4.8"

tar -xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/usr

make
make html

chown -Rv tester .
su tester -c "PATH=$PATH make check"

make install
install -d -m755           /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8

cd ..
rm -rf sed-4.8


log "8.30. Psmisc-23.4"

tar -xf psmisc-23.4.tar.xz
cd psmisc-23.4

./configure --prefix=/usr

make

make install

cd ..
rm -rf psmisc-23.4


log "8.31. Gettext-0.21"

tar -xf gettext-0.21.tar.xz
cd gettext-0.21

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21

make

make check

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ..
rm -rf gettext-0.21


log "8.32. Bison-3.7.6"

tar -xf bison-3.7.6.tar.xz
cd bison-3.7.6

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.6

make

make check

make install

cd ..
rm -rf bison-3.7.6


log "8.33. Grep-3.7"

tar -xf grep-3.7.tar.xz
cd grep-3.7

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf grep-3.7


log "8.34. Bash-5.1.8"

tar -xf bash-5.1.8.tar.gz
cd bash-5.1.8

./configure --prefix=/usr

make

chown -Rv tester .

su -s /usr/bin/expect tester << EOF
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install

cd ..
rm -rf bash-5.1.8

exec /bin/bash --login +h /root/chapter-8.35-9-chroot-newbash.sh
