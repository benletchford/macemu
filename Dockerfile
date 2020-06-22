FROM ubuntu:xenial

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git libsdl1.2-dev autoconf libgtk2.0-dev libxxf86dga-dev libxxf86vm-dev libesd0-dev xserver-xorg-core xserver-xorg-input-all xserver-xorg-video-fbdev

RUN git clone -b 1.38.48 --depth=1 https://github.com/emscripten-core/emsdk.git emsdk
RUN cd /emsdk && ./emsdk install latest && ./emsdk activate latest

# SHELL ["/bin/bash", "-c"]
# RUN source /emsdk/emsdk_env.sh \
#     && emcc --version \
#     && mkdir -p /tmp/emscripten_test && cd /tmp/emscripten_test \
#     && printf '#include <iostream>\nint main(){std::cout<<"HELLO"<<std::endl;return 0;}' > test.cpp \
#     && em++ -O2 test.cpp -o test.js && node test.js \
#     && em++ test.cpp -o test.js && node test.js \
#     && em++ -s WASM=1 test.cpp -o test.js && node test.js \
#     && cd / \
#     && rm -rf /tmp/emscripten_test \
#     && echo "All done."

COPY . /macemu
SHELL ["/bin/bash", "-c"]
RUN source /emsdk/emsdk_env.sh \
    && export EMSCRIPTEN=/emsdk/fastcomp/emscripten \
    && emcc --version \
    && cd /macemu/BasiliskII/src/Unix \
    && /macemu/BasiliskII/src/Unix/_embuild.sh \
    && make clean \
    && make \
    && /macemu/BasiliskII/src/Unix/_emafterbuild.sh

RUN groupadd -r basiliskii -g 1000
RUN useradd -r -u 1000 -g basiliskii basiliskii

USER basiliskii

ENTRYPOINT ["/usr/local/bin/BasiliskII"]
