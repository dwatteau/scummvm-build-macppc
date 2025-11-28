#! /bin/sh

FLAC_VERSION=1.5.0

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch flac "http://downloads.xiph.org/releases/flac/flac-${FLAC_VERSION}.tar.xz" \
        'tar --use-compress-program=/opt/local/bin/xz -xf' #"sha256:${FLAC_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# stack protection will cause undefined symbols errors, when ScummVM
# links against this library, when targeting OSX 10.4
CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
ac_cv_prog_cc_c11=no \
do_configure \
--disable-avx \
--disable-stack-smash-protection --disable-rpath \
--disable-thorough-tests --disable-doxygen-docs --disable-cpplibs --disable-ogg

do_make -C src/libFLAC V=1

do_make -C src/libFLAC install
# No need to build includes
do_make -C include install

do_clean_bdir
