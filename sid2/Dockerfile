FROM debian:sid

RUN echo "deb http://httpredir.debian.org/debian sid main" > /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian sid main" >> /etc/apt/sources.list

#RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update

RUN mkdir -p /opt/cross
RUN export PATH=/opt/cross/bin:$PATH

RUN apt-get install -y wget ca-certificates build-essential

WORKDIR /build

RUN wget -nc https://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.gz
RUN wget -nc https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
#wget -nc https://www.kernel.org/pub/linux/kernel/v3.x/$LINUX_KERNEL_VERSION.tar.xz
#RUN wget -nc https://ftp.gnu.org/gnu/glibc/glibc-2.23.tar.xz
#wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
#wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
#wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz
#wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
#wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz

RUN for f in *.tar*; do tar xfk $f; done

ENV PATH /opt/cross/bin:$PATH

WORKDIR /build/build-binutils
RUN ../binutils-2.26/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --disable-multilib
RUN make -j4
RUN make install

# TODO: Step 2. Linux Kernel Headers

WORKDIR /build/gcc-5.4.0
RUN ./contrib/download_prerequisites
WORKDIR /build/build-gcc
RUN ../gcc-5.4.0/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --enable-languages=c,c++ --disable-multilib
RUN make -j4 all-gcc
RUN make install-gcc

WORKDIR /build
RUN apt-get source glibc
RUN apt-get build-dep -y glibc
WORKDIR /build/build-glibc
RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update
RUN apt-get install kfreebsd-kernel-headers:kfreebsd-amd64
RUN cp -a /usr/include/x86_64-kfreebsd-gnu/ /opt/cross/x86_64-kfreebsd-gnu/include
RUN ../glibc-2.23/configure --prefix=/opt/cross/x86_64-kfreebsd-gnu --build=$MACHTYPE --host=x86_64-kfreebsd-gnu --target=x86_64-kfreebsd-gnu --disable-multilib libc_cv_forced_unwind=yes --enable-add-ons=fbtl --with-headers=/opt/cross/x86_64-kfreebsd-gnu/include --disable-werror --enable-stackguard-randomization
RUN make install-bootstrap-headers=yes install-headers
RUN make -j4 csu/subdir_lib
RUN install csu/crt1.o csu/crti.o csu/crtn.o /opt/cross/x86_64-kfreebsd-gnu/lib
RUN x86_64-kfreebsd-gnu-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o /opt/cross/x86_64-kfreebsd-gnu/lib/libc.so
RUN touch /opt/cross/x86_64-kfreebsd-gnu/include/gnu/stubs.h

#WORKDIR /build/build-gcc
#RUN make -j4 all-target-libgcc
#RUN make install-target-libgcc

#WORKDIR /build/build-glibc
#RUN make -j4
#RUN make install

#WORKDIR /build/build-gcc
#RUN make -j4 all
#RUN make install
