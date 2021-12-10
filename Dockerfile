FROM debian:11.1

# Update and install build tools
RUN apt-get -y update
RUN apt-get -y install build-essential bison python3 texinfo wget gawk

# Change /bin/sh from dash to bash
RUN rm /bin/sh; ln -s /bin/bash /bin/sh

# *** 2.2. Host System Requirements ***
COPY scripts/version-check.sh /root/
RUN /root/version-check.sh

# *** 2.6. Setting The $LFS Variable ***
# ENV is required because RUN uses `sh` which doesn't read startup files
# (.bashrc, .profile, etc).
ENV LFS=/mnt/lfs

# *** 2.7. Mounting the New Partition ***
# We just create the directory
RUN LFS=/mnt/lfs mkdir -pv $LFS

# *** 3. Packages and Patches ***
RUN mkdir -v $LFS/sources
RUN chmod -v a+wt $LFS/sources
COPY scripts/wget-list $LFS/sources/wget-list
RUN wget --input-file=$LFS/sources/wget-list --no-verbose --directory-prefix=$LFS/sources
COPY scripts/md5sums $LFS/sources/
RUN cd $LFS/sources; md5sum -c md5sums

# *** Extra packages and patches used for BLFS components
COPY scripts/wget-list-extras $LFS/sources/wget-list-extras
RUN wget --input-file=$LFS/sources/wget-list-extras --no-verbose --directory-prefix=$LFS/sources
COPY scripts/md5sums-extras $LFS/sources/
RUN cd $LFS/sources; md5sum -c md5sums-extras

# *** 4.2. Creating a limited directory layout in LFS filesystem ***
RUN mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
RUN for i in bin lib sbin; do ln -sv usr/$i $LFS/$i; done
RUN mkdir -pv $LFS/lib64
RUN mkdir -pv $LFS/tools

# *** 4.3. Adding the LFS User ***
RUN groupadd lfs
RUN useradd -s /bin/bash -g lfs -m -k /dev/null lfs
RUN chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
RUN chown -v lfs $LFS/lib64
RUN chown -v lfs $LFS/sources
USER lfs

# *** 4.4. Setting Up the Environment ***
COPY scripts/lfs.bash_profile  /home/lfs/.bash_profile
COPY scripts/lfs.bashrc        /home/lfs/.bashrc

# *** 5. Compiling a Cross-Toolchain ***
# and
# *** 6. Cross Compiling Temporary Tools ***
COPY scripts/chapter-5-6.sh /home/lfs/chapter-5-6.sh
RUN /bin/bash -l /home/lfs/chapter-5-6.sh

# *** 7.2. Changing Ownership ***
USER root
RUN chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools,lib64}

# Copy scripts used for in chapter 7 onwards
COPY scripts/chapter-*.sh $LFS/root/
