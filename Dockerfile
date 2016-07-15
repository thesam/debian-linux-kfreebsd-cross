FROM debian:wheezy

RUN echo "deb-src http://httpredir.debian.org/debian wheezy main" >> /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian wheezy-updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org wheezy/updates main" >> /etc/apt/sources.list
RUN apt-get update

RUN mkdir /opt/cross
RUN mkdir /build

WORKDIR /build
RUN apt-get install -y dpkg-dev
RUN apt-get source binutils
RUN apt-get source gcc-4.7

RUN mkdir /build/build-binutils
WORKDIR /build/build-binutils
RUN ../binutils-2.22/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --disable-multilib
RUN make -j8
RUN make install

RUN mkdir /build/build-gcc
WORKDIR /build/build-gcc
RUN apt-get install -y wget
RUN apt-get build-dep -y gcc-4.7
WORKDIR /build/gcc-4.7-4.7.2
RUN dpkg-buildpackage -us -uc
#RUN tar xf ../gcc-4.7-4.7.2/gcc-4.7.2-dfsg.tar.xz
#WORKDIR /build/build-gcc/gcc-4.7.2
#RUN ./contrib/download_prerequisites
#WORKDIR /build/build-gcc/doit
#RUN ../gcc-4.7.2/configure --prefix=/opt/cross --target=x86_64-kfreebsd-gnu --enable-languages=c --disable-multilib
#RUN make -j8 all-gcc
#RUN make install-gcc
