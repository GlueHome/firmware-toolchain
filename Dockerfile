FROM gluehome/nrf52-toolchain:2017q2

# Install Jumper - Virtual nRF52 device support - https://jumper.io/
RUN pip install jumper

# Common Libraries
# LibSodium and nanopb
WORKDIR /src
RUN \
    git clone https://github.com/GlueHome/libsodium && \
    git clone https://github.com/GlueHome/nanopb

WORKDIR /opt/cortexm
RUN cp -r /src/nanopb .

WORKDIR /opt/amd64
RUN cp -r /src/nanopb .

WORKDIR /src/libsodium
# Compile lib sodium for host

RUN ./autogen.sh \
    &&  ./configure --prefix=/opt/amd64/libsodium \
    && make \
    && make check \
    && make install

ENV LDFLAGS="-mthumb -mabi=aapcs -mfloat-abi=soft --specs=nosys.specs" \
    CFLAGS="-mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-strict-aliasing -Os"

# Compile lib sodium for cortex m4
RUN make clean \
    && ./configure --host=arm-none-eabi --prefix=/opt/cortexm/libsodium \
    && make \
    && make install

ENV AMD64_ROOT=/opt/amd64 \
    CORTEXM_ROOT=/opt/cortexm \
    LDFLAGS="" \
    CFLAGS=""

WORKDIR /build
