#! /bin/sh

JPEGTURBO_VERSION=2.1.4
#JPEGTURBO_SHA256=d625ad6b3375a036bf30cd3b0b40e8dde08f0891bfd3a2960650654bdb50318c

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libjpeg-turbo "https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${JPEGTURBO_VERSION}.tar.gz" 'tar xzf' #"sha256:${JPEGTURBO_SHA256}"

do_cmake -DENABLE_SHARED=0 -DWITH_TURBOJPEG=0 -DREQUIRE_SIMD=1 -DCMAKE_C_FLAGS="-Wa,-force_cpusubtype_ALL" -DCMAKE_C_COMPILER=/opt/macports-tff/bin/gcc-mp-4.8 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 -DCMAKE_OSX_SYSROOT=/Developer/SDKs/MacOSX10.4u.sdk

do_make VERBOSE=1

do_make install

do_clean_bdir
