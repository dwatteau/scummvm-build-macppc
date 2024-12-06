#! /bin/sh

LIBVPX_VERSION=1.15.0
#LIBVPX_VERSION=1.14.1
#LIBVPX_SHA256=30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libvpx "https://github.com/webmproject/libvpx/archive/refs/tags/v${LIBVPX_VERSION}.tar.gz" \
        'tar xzf' #"sha256:${LIBVPX_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O3 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--disable-examples \
--disable-tools \
--disable-docs \
--disable-unit-tests \
--disable-install-bins \
--disable-install-srcs \
--size-limit=16384x16384 \
--disable-vp8-encoder \
--disable-vp9-encoder \
--disable-debug \
--disable-debug-libs

#--enable-static \

do_make verbose=yes
do_make install

do_clean_bdir
