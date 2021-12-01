#!/bin/bash

log() {
	echo ""
	echo "*** $1 ***"
}


# last few commands from chapter 7.6
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp


log "7.7. Libstdc++ from GCC-11.2.0, Pass 2"

cd /sources
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

ln -s gthr-posix.h libgcc/gthr-default.h

mkdir -v build
cd       build

../libstdc++-v3/configure            \
    CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
    --prefix=/usr                    \
    --disable-multilib               \
    --disable-nls                    \
    --host=$(uname -m)-lfs-linux-gnu \
    --disable-libstdcxx-pch

make

make install

cd ..

cd ..
rm -rf gcc-11.2.0


log "7.8. Gettext-0.21"

cd /sources
tar -xf gettext-0.21.tar.xz
cd gettext-0.21

./configure --disable-shared

make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd ..
rm -rf gettext-0.21


log "7.9. Bison-3.7.6"

cd /sources
tar -xf bison-3.7.6.tar.xz
cd bison-3.7.6

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.7.6

make

make install

cd ..
rm -rf bison-3.7.6


log "7.10. Perl-5.34.0"

cd /sources
tar -xf perl-5.34.0.tar.xz
cd perl-5.34.0

sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl     \
             -Darchlib=/usr/lib/perl5/5.34/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl

make

make install

cd ..
rm -rf perl-5.34.0


log "7.11. Python-3.9.6"

cd /sources
tar -xf Python-3.9.6.tar.xz
cd Python-3.9.6

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

make

make install

cd ..
rm -rf Python-3.9.6


log "7.12. Texinfo-6.8"

cd /sources
tar -xf texinfo-6.8.tar.xz
cd texinfo-6.8

sed -e 's/__attribute_nonnull__/__nonnull/' \
    -i gnulib/lib/malloc/dynarray-skeleton.c

./configure --prefix=/usr

make

make install

cd ..
rm -rf texinfo-6.8


log "7.13. Util-linux-2.37.2"

cd /sources
tar -xf util-linux-2.37.2.tar.xz
cd util-linux-2.37.2

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --libdir=/usr/lib    \
            --docdir=/usr/share/doc/util-linux-2.37.2 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            runstatedir=/run

make

make install

cd ..
rm -rf util-linux-2.37.2


log "7.14. Cleaning up and Saving the Temporary System"

rm -rf /usr/share/{info,man,doc}/*

find /usr/{lib,libexec} -name \*.la -delete

rm -rf /tools


log "8.3. Man-pages-5.13"

cd /sources
tar -xf man-pages-5.13.tar.xz
cd man-pages-5.13

make prefix=/usr install

cd ..
rm -rf man-pages-5.13


log "8.4. Iana-Etc-20210611"

cd /sources
tar -xf iana-etc-20210611.tar.gz
cd iana-etc-20210611

cp services protocols /etc

cd ..
rm -rf iana-etc-20210611


log "8.5. Glibc-2.34"

cd /sources
tar -xf glibc-2.34.tar.xz
cd glibc-2.34

sed -e '/NOTIFY_REMOVED)/s/)/ \&\& data.attr != NULL)/' \
    -i sysdeps/unix/sysv/linux/mq_notify.c

patch -Np1 -i ../glibc-2.34-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=3.2                      \
             --enable-stack-protector=strong          \
             --with-headers=/usr/include              \
             libc_cv_slibdir=/usr/lib

make

make check

touch /etc/ld.so.conf

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /usr/lib/systemd/system/nscd.service

mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_AU -f ISO-8859-1 en_AU
localedef -i en_AU -f UTF-8 en_AU.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

log "8.5.2.1. Adding nsswitch.conf"

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

log "8.5.2.2. Adding time zone data"

cd /sources
tar -xf ../../tzdata2021a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

# Set to NY for now, user will set it after copying
ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime

log "8.5.2.3. Configuring the Dynamic Loader"

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

cd ..

cd ..
rm -rf glibc-2.34


log "8.6. Zlib-1.2.11"

cd /sources
tar -xf zlib-1.2.11.tar.xz
cd zlib-1.2.11

./configure  --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libz.a

cd ..
rm -rf zlib-1.2.11


log "8.7. Bzip2-1.0.8"

cd /sources
tar -xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean

make

make PREFIX=/usr install

cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

rm -fv /usr/lib/libbz2.a

cd ..
rm -rf bzip2-1.0.8


log "8.8. Xz-5.2.5"

cd /sources
tar -xf xz-5.2.5.tar.xz
cd xz-5.2.5

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.5

make

make check

make install

cd ..
rm -rf xz-5.2.5


log "8.9. Zstd-1.5.0"

cd /sources
tar -xf zstd-1.5.0.tar.gz
cd zstd-1.5.0

make

# Tests seem to hang the build
# make check

make prefix=/usr install

rm -v /usr/lib/libzstd.a

cd ..
rm -rf zstd-1.5.0


log "8.10. File-5.40"

cd /sources
tar -xf file-5.40.tar.gz
cd file-5.40

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf file-5.40


log "8.11. Readline-8.1"

cd /sources
tar -xf readline-8.1.tar.gz
cd readline-8.1

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.1

make SHLIB_LIBS="-lncursesw"

make SHLIB_LIBS="-lncursesw" install

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1

cd ..
rm -rf readline-8.1


log "8.12. M4-1.4.19"

cd /sources
tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf m4-1.4.19


log "8.13. Bc-5.0.0"

cd /sources
tar -xf bc-5.0.0.tar.xz
cd bc-5.0.0

CC=gcc ./configure --prefix=/usr -G -O3

make

make test

make install

cd ..
rm -rf bc-5.0.0


log "8.14. Flex-2.6.4"

cd /sources
tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr                      \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

make

make check

make install

ln -sv flex /usr/bin/lex

cd ..
rm -rf flex-2.6.4


log "8.15. Tcl-8.6.11"

cd /sources
tar -xf tcl8.6.11-src.tar.gz
cd tcl8.6.11

tar -xf ../tcl8.6.11-html.tar.gz --strip-components=1

SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)

make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|"            \
    -i pkgs/tdbc1.1.2/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|"            \
    -i pkgs/itcl4.2.1/itclConfig.sh

unset SRCDIR

make test

make install

chmod -v u+w /usr/lib/libtcl8.6.so

make install-private-headers

ln -sfv tclsh8.6 /usr/bin/tclsh

mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

cd ..
rm -rf tcl8.6.11


log "8.16 Expect-5.45.4"

cd /sources
tar -xf expect5.45.4.tar.gz
cd expect5.45.4

./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

make

make test

make install

ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd ..
rm -rf expect5.45.4


log "8.17. DejaGNU-1.6.3"

cd /sources
tar -xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

mkdir -v build
cd       build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

make check

cd ..

cd ..
rm -rf dejagnu-1.6.3


log "8.18. Binutils-2.37"

cd /sources
tar -xf binutils-2.37.tar.xz
cd binutils-2.37

expect -c "spawn ls"

patch -Np1 -i ../binutils-2.37-upstream_fix-1.patch

sed -i '63d' etc/texi2pod.pl
find -name \*.1 -delete

mkdir -v build
cd       build

../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib

make tooldir=/usr

make -k check

tooldir=/usr install -j1

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a

cd ..

cd ..
rm -rf binutils-2.37


log "8.19. GMP-6.2.1"

cd /sources
tar -xf gmp-6.2.1.tar.xz
cd gmp-6.2.1

cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1

make
make html

make check 2>&1 | tee gmp-check-log

awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

cd ..
rm -rf gmp-6.2.1


log "8.20. MPFR-4.1.0"

cd /sources
tar -xf mpfr-4.1.0.tar.xz
cd mpfr-4.1.0

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0

make
make html

make check

make install
make install-html

cd ..
rm -rf mpfr-4.1.0


log "8.21. MPC-1.2.1"

cd /sources
tar -xf mpc-1.2.1.tar.gz
cd mpc-1.2.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1

make
make html

make check

make install
make install-html

cd ..
rm -rf mpc-1.2.1


log "8.22. Attr-2.5.1"

cd /sources
tar -xf attr-2.5.1.tar.gz
cd attr-2.5.1

./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.1

make

make check

make install

cd ..
rm -rf attr-2.5.1


log "8.23. Acl-2.3.1"

cd /sources
tar -xf acl-2.3.1.tar.xz
cd acl-2.3.1

./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.1

make

make install

cd ..
rm -rf acl-2.3.1


log "8.24. Libcap-2.53"

cd /sources
tar -xf libcap-2.53.tar.xz
cd libcap-2.53

sed -i '/install -m.*STA/d' libcap/Makefile

make prefix=/usr lib=lib

make test

make prefix=/usr lib=lib install

chmod -v 755 /usr/lib/lib{cap,psx}.so.2.53

cd ..
rm -rf libcap-2.53


log "8.25. Shadow-4.9"

cd /sources
tar -xf shadow-4.9.tar.xz
cd shadow-4.9

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
    -i etc/login.defs

sed -e "224s/rounds/min_rounds/" -i libmisc/salt.c

touch /usr/bin/passwd
./configure --sysconfdir=/etc \
            --with-group-name-max-length=32

make exec_prefix=/usr install
make -C man install-man
mkdir -p /etc/default
useradd -D --gid 999

pwconv

grpconv

sed -i 's/yes/no/' /etc/default/useradd

cd ..
rm -rf shadow-4.9


log "8.26. GCC-11.2.0 (build)"

cd /sources
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0

sed -e '/static.*SIGSTKSZ/d' \
    -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
    -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

make

# gcc tests are executed in next script
