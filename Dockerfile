FROM gluehome/nrf52-toolchain

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    ruby-full \
    libtool \
    autoconf \
    && apt-get purge

RUN gem install ceedling

RUN wget -qO protoc3.zip https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip && \
    unzip protoc3.zip -d protoc3 && \
    rm protoc3.zip && \
    mv protoc3/bin/* /usr/local/bin/ && \
    mv protoc3/include/* /usr/local/include/

RUN git clone https://github.com/GlueHome/libsodium && \
    git clone https://github.com/GlueHome/nanopb

WORKDIR /opt/nanopb/generator/proto
RUN make

WORKDIR /opt/libsodium

# Compile lib sodium for host
RUN ./autogen.sh \
    && mkdir -p /opt/libsodium/amd64 \
    &&  ./configure --prefix=/opt/libsodium/amd64 \
    && make \
    && make check \
    && make install

ENV LDFLAGS="-mthumb -mabi=aapcs -mfloat-abi=soft --specs=nosys.specs" \
    CFLAGS="-mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-strict-aliasing -Os"

# Compile lib sodium for firmware
RUN mkdir -p /opt/libsodium/cortexm \
    && make clean \
    && ./configure --host=arm-none-eabi --prefix=/opt/libsodium/cortexm \
    && make \
    && make install

ENV LIBSODIUM_CORTEXM_LIB_PATH=/opt/libsodium/cortexm/lib \
    LIBSODIUM_CORTEXM_INC_PATH==/opt/libsodium/cortexm/include \
    LIBSODIUM_AMD64_LIB_PATH=/opt/libsodium/amd64/lib \
    LIBSODIUM_AMD64_INC_PATH==/opt/libsodium/amd64/include \
    NANOPB_PATH=/opt/nanopb \
    LD_LIBRARY_PATH=/opt/libsodium/amd64/lib:${LD_LIBRARY_PATH}\
    LDFLAGS="" \
    CFLAGS=""
    
WORKDIR /opt
