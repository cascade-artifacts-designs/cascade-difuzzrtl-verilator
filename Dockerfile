# Copyright 2023 Flavien Solt, ETH Zurich.
# Licensed under the General Public License, Version 3.0, see LICENSE for details.
# SPDX-License-Identifier: GPL-3.0-only

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl gnupg apt-utils && \
    apt-get install -y apt-transport-https curl gnupg git perl python3 make autoconf g++ flex bison ccache libgoogle-perftools-dev numactl perl-doc libfl2 libfl-dev zlib1g zlib1g-dev \
    autoconf automake autotools-dev libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
    bison flex texinfo gperf libtool patchutils bc zlib1g-dev git perl python3 python3.10-venv make g++ libfl2 \
    libfl-dev zlib1g zlib1g-dev git autoconf flex bison gtkwave clang \
    tcl-dev libreadline-dev jq libexpat-dev device-tree-compiler vim \
    software-properties-common  default-jdk default-jre gengetopt patch diffstat texi2html subversion chrpath wget libgtk-3-dev gettext python3-pip python3.8-dev rsync libguestfs-tools expat \
    libexpat1-dev libusb-dev libncurses5-dev cmake help2man

# Install Verilator
RUN git clone https://github.com/verilator/verilator && cd verilator && git checkout v4.106 && autoconf && ./configure && make -j 200 && make install

# Install RISC-V toolchain
RUN apt-get install -y autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
ENV RISCV="/opt/riscv"
RUN git clone https://github.com/riscv/riscv-gnu-toolchain
RUN cd riscv-gnu-toolchain && ./configure --prefix=/opt/riscv --enable-multilib && make -j 200

# Install spike
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git
RUN cd riscv-isa-sim && mkdir build && cd build && ../configure --prefix=$RISCV && make -j 200 && make install

# Install elf2hex
RUN git clone https://github.com/sifive/elf2hex.git
RUN cd elf2hex && autoreconf -i && ./configure --target=riscv64-unknown-elf && make -j 200 && make install

# Install cocotb
# TODO Make it 1.5.2
RUN pip3 install cocotb

# Install oh my zsh and some convenience plugins
RUN apt-get install -y zsh && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
RUN sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /root/.zshrc

# Fix the cpp file in Verilator
RUN sed -i 's|#include <utility>|&\n#include <limits>|' /usr/local/share/verilator/include/verilated.cpp
RUN sed -i 's/objcopy=""/objcopy="riscv64-unknown-elf-objcopy"/' /usr/local/bin/riscv64-unknown-elf-elf2hex

# Some DifuzzRTL-specific requirements
ENV PATH="${RISCV}/bin:${PATH}"
RUN pip3 install psutil sysv_ipc 

RUN pip3 install cocotb==1.5.2

# cd /difuzzrtl/Fuzzer && make SIM_BUILD=builddir VFILE=RocketTile_state TOPLEVEL=RocketTile NUM_ITER=100000 OUT=outdir IS_CASCADE=0 SPIKE=/opt/riscv/bin/spike -j 200
# docker run -it -v /scratch/flsolt/shareddir:/difuzzrtl coco bash -c 'cd /difuzzrtl && bash gen_difuzzrtl_elfs.sh'
