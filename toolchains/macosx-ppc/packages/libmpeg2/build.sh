#! /bin/sh

LIBMPEG2_VERSION=0.5.1
LIBMPEG2_SHA256=dee22e893cb5fc2b2b6ebd60b88478ab8556cb3b93f9a0d7ce8f3b61851871d4

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libmpeg2 "http://libmpeg2.sourceforge.net/files/libmpeg2-${LIBMPEG2_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBMPEG2_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --disable-sdl --without-x

do_make -C libmpeg2
do_make -C libmpeg2 install
# No need to build includes
do_make -C include install

do_clean_bdir
