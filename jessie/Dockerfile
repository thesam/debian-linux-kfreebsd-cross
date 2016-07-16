FROM debian:sid

RUN echo "deb http://httpredir.debian.org/debian sid main" > /etc/apt/sources.list
RUN echo "deb-src http://httpredir.debian.org/debian sid main" >> /etc/apt/sources.list

#RUN dpkg --add-architecture kfreebsd-amd64
RUN apt-get update

RUN apt-get install -y dpkg-dev

WORKDIR /build

RUN apt-get source binutils
RUN apt-get build-dep -y binutils
WORKDIR /build/binutils-2.26.1
RUN echo kfreebsd-amd64 > debian/target
RUN dpkg-buildpackage -b -j4
WORKDIR /build
RUN dpkg -i *.deb

#RUN apt-get build-dep -y gcc-5
#WORKDIR /build/gcc-5-5.4.0
#RUN dpkg-buildpackage -uc -us --target-arch=kfreebsd-amd64
