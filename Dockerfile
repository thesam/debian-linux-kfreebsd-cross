# Cross-compiler, Debian GNU/Linux to Debian GNU/kFreeBSD
# Based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

FROM debian:sid

RUN echo "deb http://httpredir.debian.org/debian sid main" > /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian sid main" >> /etc/apt/sources.list

RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update

RUN apt-get install -y wget ca-certificates build-essential
RUN apt-get build-dep -y glibc
RUN apt-get install kfreebsd-kernel-headers:kfreebsd-amd64

RUN mkdir -p /opt/cross
ENV PATH /opt/cross/bin:$PATH

WORKDIR /build

RUN wget -nc https://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.gz
RUN wget -nc https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
#RUN wget -nc https://ftp.gnu.org/gnu/glibc/glibc-2.23.tar.xz
RUN for f in *.tar*; do tar xfk $f; done
RUN apt-get source glibc

WORKDIR /build/gcc-5.4.0
RUN ./contrib/download_prerequisites

WORKDIR /build/build-binutils
RUN ../binutils-2.26/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --disable-multilib
RUN make -j4
RUN make install

WORKDIR /build/build-gcc
RUN ../gcc-5.4.0/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --enable-languages=c,c++ --disable-multilib --disable-libcilkrts
RUN make -j4 all-gcc
RUN make install-gcc

RUN cp -a /usr/include/x86_64-kfreebsd-gnu/ /opt/cross/x86_64-kfreebsd-gnu/include

WORKDIR /build/glibc-2.23
RUN patch -p1 -i debian/patches/kfreebsd/local-memusage_no_mremap.diff
#RUN patch -p1 -i debian/patches/kfreebsd/local-sys_queue_h.diff
RUN patch -p1 -i debian/patches/kfreebsd/local-undef-glibc.diff
#RUN patch -p1 -i debian/patches/kfreebsd/local-initgroups-order.diff
#RUN patch -p1 -i debian/patches/kfreebsd/local-tst-auxv.diff
#RUN patch -p1 -i debian/patches/kfreebsd/local-tst-unique.diff


WORKDIR /build/build-glibc
RUN ../glibc-2.23/configure --prefix=/opt/cross/x86_64-kfreebsd-gnu --build=$MACHTYPE --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu --disable-multilib libc_cv_forced_unwind=yes --enable-add-ons=fbtl --with-headers=/usr/include/x86_64-kfreebsd-gnu --enable-stackguard-randomization --disable-werror libc_cv_ssp=no libc_cv_ssp_strong=no
RUN make install-bootstrap-headers=yes install-headers
RUN make -j4 csu/subdir_lib
RUN install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/x86_64-kfreebsd-gnu/lib
RUN x86_64-kfreebsd-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/x86_64-kfreebsd-gnu/lib/libc.so
RUN touch /opt/cross/x86_64-kfreebsd-gnu/include/gnu/stubs.h

WORKDIR /build/build-gcc
RUN make -j4 all-target-libgcc
RUN make install-target-libgcc

WORKDIR /build/build-glibc
RUN make -j4
RUN make install

WORKDIR /build/build-gcc
RUN make -j4 all
RUN make install
