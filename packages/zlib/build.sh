#! /bin/sh

ZLIB_VERSION=1.4

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch zlib "https://www.zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz" 'tar xzf' #"sha256:${ZLIB_SHA256}"

# Don't use do_configure as it's not autotools compliant
# XXX: then, keeping 'CC' here for now!
CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
./configure --prefix="$PREFIX" --static

# Only build the library and not its samples
do_make libz.a

do_make install

do_clean_bdir
