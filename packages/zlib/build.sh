#! /bin/sh

ZLIB_VERSION=1.3.2
#ZLIB_SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch zlib "http://www.zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz" 'tar xzf' #"sha256:${ZLIB_SHA256}"

CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
./configure --prefix=$PREFIX --static

# Only build the library and not its samples
do_make libz.a

do_make install

do_clean_bdir
