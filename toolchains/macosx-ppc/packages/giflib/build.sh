#! /bin/sh

GIFLIB_VERSION=5.2.1
#GIFLIB_SHA256=34a7377ba834397db019e8eb122e551a49c98f49df75ec3fcc92b9a794a4f6d1

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch giflib "https://download.sourceforge.net/project/giflib/giflib-${GIFLIB_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${GIFLIB_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-7 \
make libgif.a CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32 -std=gnu99 -Wall'

install -d -m 0755 "$PREFIX/lib"
install -m 0644 libgif.a "$PREFIX/lib/"
install -d -m 0755 "$PREFIX/include"
install -m 0644 gif_lib.h "$PREFIX/include/"

do_clean_bdir
