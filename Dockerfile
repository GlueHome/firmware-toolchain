FROM gluehome/nrf52-toolchain

WORKDIR /src

# Install Jumper - Virtual nRF52 device support - https://jumper.io/
RUN pip install jumper

ENV \
   CFLAGS='-mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-strict-aliasing -Os' \
   LDFLAGS='-mthumb -mabi=aapcs -mfloat-abi=soft --specs=nosys.specs'

# Common Libraries
# LibSodium and nanopb
WORKDIR /src
RUN \
    git clone https://github.com/GlueHome/libsodium && \
    git clone https://github.com/GlueHome/nanopb

WORKDIR /src/libsodium
RUN ./autogen.sh \
    &&  ./configure --host=arm-none-eabi --prefix /usr/local/libsodium \
    && make \
    && make install

ENV \
   CFLAGS="$CFLAGS -I/usr/local/libsodium/include -I/src/nanopb" \
   LDFLAGS="$LDFLAGS -L/usr/local/libsodium/lib"

WORKDIR /build
