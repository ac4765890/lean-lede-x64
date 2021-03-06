FROM ubuntu:18.04

MAINTAINER Rabenda <rabenda.cn@gmail.com>

LABEL version="1.0"

ENV DEBIAN_FRONTEND noninteractive
RUN apt update -qq && \
	apt upgrade -y -qq && \
	apt install -y -qq locales

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install dependencies
RUN apt install -y -qq ca-certificates
RUN update-ca-certificates
RUN apt install -y -qq --no-install-recommends uuid-runtime wget sudo build-essential \
    asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev \
    patch python3.5 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion \
    flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev \
    texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake \
    libtool autopoint device-tree-compiler g++-multilib

# Set user info
RUN useradd --create-home --no-log-init --shell /bin/bash builder && \
	adduser builder sudo && \
	echo 'builder:builder' | chpasswd

USER builder
WORKDIR /home/builder

# clone code
RUN git clone https://github.com/coolsnowwolf/lede.git
WORKDIR /home/builder/lede

RUN ./scripts/feeds update -a && ./scripts/feeds install -a
ADD config/.config .config

# Download dependencies

RUN make download

# compile
RUN make -j $(expr $(nproc) + 1)

# ARG TOKEN
# ADD upload/upload-github-release-asset.sh upload-github-release-asset.sh
# RUN bash upload-github-release-asset.sh \
# 	github_api_token=${TOKEN} \
# 	owner=rabenda \
# 	repo=openwrt-phicomm-k1 \
# 	tag=v$(date +%Y.%m.%d.%H.%M) \
# 	filename=bin/targets/ramips/mt7620/openwrt-ramips-mt7620-phicomm_psg1208-squashfs-sysupgrade.bin

CMD ["bash"]
