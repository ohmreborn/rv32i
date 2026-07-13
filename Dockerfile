FROM ubuntu:24.04

ENV ALLOW_ROOT 1

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates wget sudo build-essential clang bison flex cmake git \
    libreadline-dev gawk gfortran tcl-dev libffi-dev pkg-config python3-yaml pypy3 \
    libboost-all-dev zlib1g-dev libeigen3-dev curl gnutls-bin \
    openssl libssl-dev libbz2-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev liblzma-dev --no-install-recommends

RUN curl https://pyenv.run | bash
 
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
 
RUN PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.10 && \
    pyenv global 3.10 && \
    pyenv rehash

RUN PYLIB=$(find $PYENV_ROOT/versions/3.10.*/lib -name "libpython3.10.so.1.0" | head -1) && \
    ln -sf "$PYLIB" /usr/local/lib/libpython3.10.so.1.0 && \
    ldconfig

# Verify
RUN python3 --version && pip3 --version


RUN git clone https://github.com/YosysHQ/yosys.git && \
	cd yosys && \
	git submodule update --init --recursive && \
	cmake -B build . -DCMAKE_BUILD_TYPE=Release && \
	cmake --build build --config Release --parallel $(nproc) && \
	cmake --install build --strip

RUN cd / && \
	git clone --depth=1 -b stable-backports https://github.com/openXC7/nextpnr-xilinx.git && \
	cd nextpnr-xilinx && \
	git submodule update --init --recursive && \
	cmake -DARCH=xilinx -DBUILD_GUI=0 -DCMAKE_INSTALL_PREFIX=/usr/local && \
	make -j8 && \
	make install && \
	(cp bbasm /usr/local/bin/ || true) && \
	mkdir /chipdb

RUN cd / && \
	git clone https://github.com/openXC7/prjxray.git && \
	cd prjxray && \
	git submodule update --init --recursive && \
	make build && \
	make install && \
	make env || true

# prjxray python env installation problem
#RUN cd /prjxray && PATH=/prjxray/env/bin:$PATH pip3 install --upgrade setuptools && PATH=/prjxray/env/bin:$PATH make env
RUN cd /prjxray && \
    PATH=/prjxray/env/bin:$PATH pip3 install "setuptools_scm<8" && \
    PATH=/prjxray/env/bin:$PATH make env
# Use latest nextpnr-xilinx-meta (with zynq 7030, pcie_2_1)
RUN cd /nextpnr-xilinx/xilinx/external/nextpnr-xilinx-meta && git pull origin master && git checkout master
# Patch PCIE_2_1 entry, for PCIe (need better way of handling!)
RUN sed -i 's/\.PCIE\./.PCIE_2_1./' /nextpnr-xilinx/xilinx/external/prjxray-db/artix7/segbits_pcie_bot.db

ENV PATH="/prjxray/env/bin:$PATH"


CMD ["/bin/bash"]
