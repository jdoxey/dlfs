#!/bin/bash

log() {
	echo ""
	echo "*** $1 ***"
}

cd /sources


log "8.35. Libtool-2.4.6"

tar -xf libtool-2.4.6.tar.xz
cd libtool-2.4.6

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/libltdl.a

cd ..
rm -rf libtool-2.4.6


log "8.36. GDBM-1.20"

tar -xf gdbm-1.20.tar.gz
cd gdbm-1.20

./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

make -k check

make install

cd ..
rm -rf gdbm-1.20


log "8.37. Gperf-3.1"

tar -xf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make

make -j1 check

make install

cd ..
rm -rf gperf-3.1


log "8.38. Expat-2.4.1"

tar -xf expat-2.4.1.tar.xz
cd expat-2.4.1

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.4.1

make

make check

make install

install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.4.1

cd ..
rm -rf expat-2.4.1


log "8.39. Inetutils-2.1"

tar -xf inetutils-2.1.tar.xz
cd inetutils-2.1

./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

make check

make install

mv -v /usr/{,s}bin/ifconfig

cd ..
rm -rf inetutils-2.1


log "8.40. Less-590"

tar -xf less-590.tar.gz
cd less-590

./configure --prefix=/usr --sysconfdir=/etc

make

make install

cd ..
rm -rf less-590


log "8.41. Perl-5.34.0"

tar -xf perl-5.34.0.tar.xz
cd perl-5.34.0

patch -Np1 -i ../perl-5.34.0-upstream_fixes-1.patch

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.34/core_perl      \
             -Darchlib=/usr/lib/perl5/5.34/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.34/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.34/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads

make

make test

make install
unset BUILD_ZLIB BUILD_BZIP2

cd ..
rm -rf perl-5.34.0


log "8.42. XML::Parser-2.46"

tar -xf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46

perl Makefile.PL

make

make test

make install

cd ..
rm -rf XML-Parser-2.46


log "8.43. Intltool-0.51.0"

tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

make check

make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ..
rm -rf intltool-0.51.0


log "8.44. Autoconf-2.71"

tar -xf autoconf-2.71.tar.xz
cd autoconf-2.71

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf autoconf-2.71


log "8.45. Automake-1.16.4"

tar -xf automake-1.16.4.tar.xz
cd automake-1.16.4

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.4

make

make -j4 check

make install

cd ..
rm -rf automake-1.16.4


log "8.46. Kmod-29"

tar -xf kmod-29.tar.xz
cd kmod-29

./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --with-xz              \
            --with-zstd            \
            --with-zlib

make

make install

for target in depmod insmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /usr/sbin/$target
done

ln -sfv kmod /usr/bin/lsmod

cd ..
rm -rf kmod-29


log "8.47. Libelf from Elfutils-0.185"

tar -xf elfutils-0.185.tar.bz2
cd elfutils-0.185

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

make

make check

make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd ..
rm -rf elfutils-0.185


log "8.48. Libffi-3.4.2"

tar -xf libffi-3.4.2.tar.gz
cd libffi-3.4.2

./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native \
            --disable-exec-static-tramp

make

make check

make install

cd ..
rm -rf libffi-3.4.2


log "8.49. OpenSSL-1.1.1l"

tar -xf openssl-1.1.1l.tar.gz
cd openssl-1.1.1l

./configure --prefix=/usr      \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

make test

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1l

cp -vfr doc/* /usr/share/doc/openssl-1.1.1l

cd ..
rm -rf openssl-1.1.1l


log "8.50. Python-3.9.6"

tar -xf Python-3.9.6.tar.xz
cd Python-3.9.6

./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --with-system-ffi    \
            --with-ensurepip=yes \
            --enable-optimizations

make

make install

install -v -dm755 /usr/share/doc/python-3.9.6/html 

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.9.6/html \
    -xvf ../python-3.9.6-docs-html.tar.bz2

cd ..
rm -rf Python-3.9.6


log "8.51. Ninja-1.10.2"

tar -xf ninja-1.10.2.tar.gz
cd ninja-1.10.2

sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap

./configure --prefix=/usr

./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd ..
rm -rf ninja-1.10.2


log "8.52. Meson-0.59.1"

tar -xf meson-0.59.1.tar.gz
cd meson-0.59.1

python3 setup.py build

python3 setup.py install --root=dest
cp -rv dest/* /
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd ..
rm -rf meson-0.59.1


log "8.53. Coreutils-8.32"

tar -xf coreutils-8.32.tar.xz
cd coreutils-8.32

patch -Np1 -i ../coreutils-8.32-i18n-1.patch

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime

make

make NON_ROOT_USERNAME=tester check-root

echo "dummy:x:102:tester" >> /etc/group

chown -Rv tester .

su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"

sed -i '/dummy/d' /etc/group

make install

mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd ..
rm -rf coreutils-8.32


log "8.54. Check-0.15.2"

tar -xf check-0.15.2.tar.gz
cd check-0.15.2

./configure --prefix=/usr --disable-static

make

make check

make docdir=/usr/share/doc/check-0.15.2 install

cd ..
rm -rf check-0.15.2


log "8.55. Diffutils-3.8"

tar -xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf diffutils-3.8


log "8.56. Gawk-5.1.0"

tar -xf gawk-5.1.0.tar.xz
cd gawk-5.1.0

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr

make

make check

make install

mkdir -v /usr/share/doc/gawk-5.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0

cd ..
rm -rf gawk-5.1.0


log "8.57. Findutils-4.8.0"

tar -xf findutils-4.8.0.tar.xz
cd findutils-4.8.0

./configure --prefix=/usr --localstatedir=/var/lib/locate

make

chown -Rv tester .
su tester -c "PATH=$PATH make check"

make install

cd ..
rm -rf findutils-4.8.0


log "8.58. Groff-1.22.4"

tar -xf groff-1.22.4.tar.gz
cd groff-1.22.4

PAGE=letter ./configure --prefix=/usr

make -j1

make install

cd ..
rm -rf groff-1.22.4


log "(8.59. GRUB-2.06 will be installed with UEFI support later"


log "8.60. Gzip-1.10"

tar -xf gzip-1.10.tar.xz
cd gzip-1.10

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf gzip-1.10


log "8.61. IPRoute2-5.13.0"

tar -xf iproute2-5.13.0.tar.xz
cd iproute2-5.13.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

sed -i 's/.m_ipt.o//' tc/Makefile

make

make SBINDIR=/usr/sbin install

mkdir -v              /usr/share/doc/iproute2-5.13.0
cp -v COPYING README* /usr/share/doc/iproute2-5.13.0

cd ..
rm -rf iproute2-5.13.0


log "8.62. Kbd-2.4.0"

tar -xf kbd-2.4.0.tar.xz
cd kbd-2.4.0

patch -Np1 -i ../kbd-2.4.0-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock

make

make check

make install

mkdir -v            /usr/share/doc/kbd-2.4.0
cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0

cd ..
rm -rf kbd-2.4.0


log "8.63. Libpipeline-1.5.3"

tar -xf libpipeline-1.5.3.tar.gz
cd libpipeline-1.5.3

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf libpipeline-1.5.3


log "8.64. Make-4.3"

tar -xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf make-4.3


log "8.65. Patch-2.7.6"

tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr

make

make check

make install

cd ..
rm -rf patch-2.7.6


log "8.66. Tar-1.34"

tar -xf tar-1.34.tar.xz
cd tar-1.34

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr

make

make check

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34

cd ..
rm -rf tar-1.34


log "8.67. Texinfo-6.8"

tar -xf texinfo-6.8.tar.xz
cd texinfo-6.8

./configure --prefix=/usr

sed -e 's/__attribute_nonnull__/__nonnull/' \
    -i gnulib/lib/malloc/dynarray-skeleton.c

make

make check

make install

make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd

cd ..
rm -rf texinfo-6.8


log "8.68. Vim-8.2.3337"

tar -xf vim-8.2.3337.tar.gz
cd vim-8.2.3337

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -Rv tester .

su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log

make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.3337

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

cd ..
rm -rf vim-8.2.3337


log "8.69. MarkupSafe-2.0.1"

tar -xf MarkupSafe-2.0.1.tar.gz
cd MarkupSafe-2.0.1

python3 setup.py build

python3 setup.py install --optimize=1

cd ..
rm -rf MarkupSafe-2.0.1


log "8.70. Jinja2-3.0.1"

tar -xf Jinja2-3.0.1.tar.gz
cd Jinja2-3.0.1

python3 setup.py install --optimize=1

cd ..
rm -rf Jinja2-3.0.1


log "8.71. Systemd-249"

tar -xf systemd-249.tar.gz
cd systemd-249

patch -Np1 -i ../systemd-249-upstream_fixes-1.patch

sed -i -e 's/GROUP="render"/GROUP="video"/' \
        -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in

mkdir -p build
cd       build

LANG=en_US.UTF-8                    \
meson --prefix=/usr                 \
      --sysconfdir=/etc             \
      --localstatedir=/var          \
      --buildtype=release           \
      -Dblkid=true                  \
      -Ddefault-dnssec=no           \
      -Dfirstboot=false             \
      -Dinstall-tests=false         \
      -Dldconfig=false              \
      -Dsysusers=false              \
      -Db_lto=false                 \
      -Drpmmacrosdir=no             \
      -Dhomed=false                 \
      -Duserdb=false                \
      -Dman=false                   \
      -Dmode=release                \
      -Ddocdir=/usr/share/doc/systemd-249 \
      ..

LANG=en_US.UTF-8 ninja

LANG=en_US.UTF-8 ninja install

tar -xf ../../systemd-man-pages-249.tar.xz --strip-components=1 -C /usr/share/man

rm -rf /usr/lib/pam.d

systemd-machine-id-setup

systemctl preset-all

systemctl disable systemd-time-wait-sync.service

cd ..

cd ..
rm -rf systemd-249


log "8.72. D-Bus-1.12.20"

tar -xf dbus-1.12.20.tar.gz
cd dbus-1.12.20

./configure --prefix=/usr                        \
            --sysconfdir=/etc                    \
            --localstatedir=/var                 \
            --disable-static                     \
            --disable-doxygen-docs               \
            --disable-xml-docs                   \
            --docdir=/usr/share/doc/dbus-1.12.20 \
            --with-console-auth-dir=/run/console \
            --with-system-pid-file=/run/dbus/pid \
            --with-system-socket=/run/dbus/system_bus_socket

make

make install

ln -sfv /etc/machine-id /var/lib/dbus

cd ..
rm -rf dbus-1.12.20


log "8.73. Man-DB-2.9.4"

tar -xf man-db-2.9.4.tar.xz
cd man-db-2.9.4

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.9.4 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap

make

make check

make install

cd ..
rm -rf man-db-2.9.4


log "8.74. Procps-ng-3.3.17"

tar -xf procps-ng-3.3.17.tar.xz
cd procps-3.3.17

./configure --prefix=/usr                            \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill                           \
            --with-systemd

make

make check

make install

cd ..
rm -rf procps-3.3.17


log "8.75. Util-linux-2.37.2"

tar -xf util-linux-2.37.2.tar.xz
cd util-linux-2.37.2

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
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

rm tests/ts/lsns/ioctl_ns

chown -Rv tester .
su tester -c "make -k check"

make install

cd ..
rm -rf util-linux-2.37.2


log "8.76. E2fsprogs-1.46.4"

tar -xf e2fsprogs-1.46.4.tar.gz
cd e2fsprogs-1.46.4

./configure --prefix=/usr

make

make check

make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd ..
rm -rf e2fsprogs-1.46.4


log "8.79. Cleaning Up"

rm -rf /tmp/*

find /usr/lib /usr/libexec -name \*.la -delete

find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf

userdel -r tester


log "After chapter 8, BLFS: efivar-37 (required for efibootmgr)"

cd /sources

tar -xf efivar-37.tar.bz2

cd efivar-37

patch -Np1 -i ../efivar-37-gcc_9-1.patch

make CFLAGS="-O2 -Wno-stringop-truncation"

make install LIBDIR=/usr/lib

cd ..

rm -rf efivar-37


log "After chapter 8, BLFS: Popt-1.18 (required for efibootmgr)"

cd /sources

tar -xf popt-1.18.tar.gz

cd popt-1.18

./configure --prefix=/usr --disable-static &&
make

make check

make install

cd ..

rm -rf popt-1.18


log "After chapter 8, BLFS: efibootmgr-17 (required for GRUB-EFI)"

cd /sources

tar -xf efibootmgr-17.tar.gz

cd efibootmgr-17

sed -e '/extern int efi_set_verbose/d' -i src/efibootmgr.c

make EFIDIR=LFS EFI_LOADER=grubx64.efi

make install EFIDIR=LFS

cd ..

rm -rf efibootmgr-17



log "After chapter 8, BLFS: GRUB-2.06 for EFI"

cd /sources

tar -xf grub-2.06.tar.xz
cd grub-2.06

unset {C,CPP,CXX,LD}FLAGS

./configure --prefix=/usr        \
            --sysconfdir=/etc    \
            --disable-efiemu     \
            --enable-grub-mkfont \
            --with-platform=efi  \
            --disable-werror     &&
make

make install &&
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd ..
rm -rf grub-2.06
