#! /bin/sh

FLAC_VERSION=1.5.0

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch flac "http://downloads.xiph.org/releases/flac/flac-${FLAC_VERSION}.tar.xz" \
        'tar --use-compress-program=/opt/local/bin/xz -xf' #"sha256:${FLAC_SHA256}"

# note: for this port, use --disable-stack-smash-protection, as otherwise
# "undefined symbol" errors will happen at link time, when linking against
# this library and targeting OSX 10.4
CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--disable-avx \
--disable-stack-smash-protection --disable-rpath \
--disable-thorough-tests --disable-doxygen-docs --disable-cpplibs --disable-ogg

do_make -C src/libFLAC V=1

do_make -C src/libFLAC install
# No need to build includes
do_make -C include install

do_clean_bdir
