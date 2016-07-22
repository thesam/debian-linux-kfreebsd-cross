# Cross-compiler, Debian GNU/Linux to Debian GNU/kFreeBSD
# Based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

FROM debian:jessie

ENV GCC_VERSION 4.9.2

RUN echo "deb [arch=amd64] http://httpredir.debian.org/debian jessie main" > /etc/apt/sources.list
RUN echo "deb-src [arch=amd64] http://httpredir.debian.org/debian jessie main" >> /etc/apt/sources.list
RUN echo "deb [arch=kfreebsd-amd64] http://httpredir.debian.org/debian jessie-kfreebsd main" >> /etc/apt/sources.list
RUN echo "deb-src [arch=kfreebsd-amd64] http://httpredir.debian.org/debian jessie-kfreebsd main" >> /etc/apt/sources.list

RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update && apt-get install -y \
  wget \
  ca-certificates \
  build-essential
RUN apt-get build-dep -y glibc

RUN mkdir -p /opt/cross
ENV PATH /opt/cross/bin:$PATH

WORKDIR /build
RUN apt-get download kfreebsd-kernel-headers:kfreebsd-amd64
RUN dpkg -x kfreebsd-kernel-headers*.deb kfreebsd-kernel-headers
RUN mkdir /opt/cross/x86_64-kfreebsd-gnu
RUN mv kfreebsd-kernel-headers/usr/include /opt/cross/x86_64-kfreebsd-gnu/include

RUN wget -nc https://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.gz && tar xf binutils-2.26.tar.gz
RUN wget -nc https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz && tar xf gcc-$GCC_VERSION.tar.gz
RUN apt-get source glibc

WORKDIR /build/gcc-$GCC_VERSION
RUN ./contrib/download_prerequisites

WORKDIR /build/build-binutils
RUN ../binutils-2.26/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --disable-multilib
RUN make -j4
RUN make install

WORKDIR /build/build-gcc
RUN ../gcc-$GCC_VERSION/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --enable-languages=c,c++ --disable-multilib --disable-libcilkrts
RUN make -j4 all-gcc
RUN make install-gcc

RUN cp -a /opt/cross/x86_64-kfreebsd-gnu/include /usr/include/x86_64-kfreebsd-gnu/

#TODO: Make version more dynamic?
WORKDIR /build/glibc-2.19
RUN patch -p1 -i debian/patches/kfreebsd/local-memusage_no_mremap.diff
#kfreebsd/local-sys_queue_h.diff
RUN patch -p1 -i debian/patches/kfreebsd/local-undef-glibc.diff
#kfreebsd/local-initgroups-order.diff
RUN patch -p1 -i debian/patches/kfreebsd/local-no-pldd.diff
RUN patch -p1 -i debian/patches/kfreebsd/local-nscd-no-sockcloexec.diff

WORKDIR /build/build-glibc
RUN ../glibc-*/configure --prefix=/opt/cross/x86_64-kfreebsd-gnu --build=$MACHTYPE --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu --disable-multilib libc_cv_forced_unwind=yes --enable-add-ons=fbtl,ports --with-headers=/usr/include/x86_64-kfreebsd-gnu --enable-stackguard-randomization --disable-werror libc_cv_ssp=no libc_cv_ssp_strong=no
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

WORKDIR /build
RUN printf '#include <stdio.h>\nvoid main() { printf("Hello, world!"); }' > smoketest.c
RUN x86_64-kfreebsd-gnu-gcc smoketest.c
