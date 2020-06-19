FROM ubuntu:xenial

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git libsdl1.2-dev autoconf libgtk2.0-dev libxxf86dga-dev libxxf86vm-dev libesd0-dev xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-fbdev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential gcc

COPY . /macemu
RUN cd /macemu && git clone -b 1.38.48 --depth=1 https://github.com/emscripten-core/emsdk.git
RUN cd /macemu/emsdk && ./emsdk install latest && ./emsdk activate latest
RUN /bin/bash -c "/macemu/emsdk/emsdk_env.sh"
RUN cd /macemu/BasiliskII/src/Unix && /macemu/BasiliskII/src/Unix/_embuild.sh && make clean && make && /macemu/BasiliskII/src/Unix/_emafterbuild.sh

RUN groupadd -r basiliskii -g 1000
RUN useradd -r -u 1000 -g basiliskii basiliskii

USER basiliskii

ENTRYPOINT ["/usr/local/bin/BasiliskII"]
