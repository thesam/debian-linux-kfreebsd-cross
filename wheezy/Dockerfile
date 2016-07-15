FROM debian:wheezy

RUN echo "deb-src http://httpredir.debian.org/debian wheezy main" >> /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian wheezy-updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org wheezy/updates main" >> /etc/apt/sources.list
RUN apt-get update

WORKDIR /build

RUN apt-get build-dep -y --no-install-recommends binutils
RUN apt-get source binutils
WORKDIR /build/binutils-2.22/
#RUN DEB_TARGET_ARCH=kfreebsd-amd64 TARGET=kfreebsd-amd64 dpkg-buildpackage -d -T control-stamp
#RUN dpkg-checkbuilddeps
RUN WITH_SYSROOT=/ DEB_TARGET_ARCH=kfreebsd-amd64 TARGET=kfreebsd-amd64 dpkg-buildpackage -b -j4

WORKDIR /build
RUN apt-get build-dep -y --no-install-recommends gcc-4.7
RUN apt-get source gcc-4.7
