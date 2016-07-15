FROM debian:sid

RUN echo "deb http://httpredir.debian.org/debian sid main" > /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian sid main" >> /etc/apt/sources.list

RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update

WORKDIR /build
RUN apt-get install -y dpkg-dev
#RUN apt-get source binutils
RUN apt-get source gcc-5
RUN apt-get build-dep -y gcc-5
WORKDIR /build/gcc-5-5.4.0
RUN dpkg-buildpackage -uc -us --target-arch=kfreebsd-amd64
