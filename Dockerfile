FROM gluehome/nrf52-toolchain

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    ruby-full \
    libtool \
    autoconf \
    && apt-get purge

# Needed for unit testing
RUN gem install ceedling

# Needed for compiling .proto files
RUN wget -qO protoc3.zip https://github.com/google/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip && \
    unzip protoc3.zip -d protoc3 && \
    rm protoc3.zip && \
    mv protoc3/bin/* /usr/local/bin/ && \
    mv protoc3/include/* /usr/local/include/

RUN git clone https://github.com/GlueHome/libsodium && \
    git clone https://github.com/GlueHome/nanopb

# Needed for compiling .proto files for C
WORKDIR /opt/nanopb/generator/proto
RUN make

# Compile libsodium for host
WORKDIR /opt/libsodium
RUN ./autogen.sh \
    && mkdir -p /opt/libsodium/include \
    && mkdir -p /opt/libsodium/lib/amd64 \
    &&  ./configure --libdir=/opt/libsodium/lib/amd64 --includedir=/opt/libsodium/include \
    && make \
    && make check \
    && make install

ENV LDFLAGS="-mthumb -mabi=aapcs -mfloat-abi=soft --specs=nosys.specs" \
    CFLAGS="-mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-strict-aliasing -Os"

# Compile libsodium for firmware
RUN mkdir -p /opt/libsodium/lib/cortexm \
    && mkdir -p /opt/libsodium/include \
    && make clean \
    && ./configure --host=arm-none-eabi --libdir=/opt/libsodium/lib/cortexm --includedir=/opt/libsodium/include \
    && make \
    && make install

ENV LIBSODIUM_CORTEXM_LIB_PATH=/opt/libsodium/lib/cortexm \
    LIBSODIUM_AMD64_LIB_PATH=/opt/libsodium/lib/amd64 \
    LIBSODIUM_INC_PATH==/opt/libsodium/include \
    NANOPB_PATH=/opt/nanopb \
    LD_LIBRARY_PATH=/opt/libsodium/lib/amd64:${LD_LIBRARY_PATH} \
    LDFLAGS="" \
    CFLAGS=""
    
WORKDIR /opt
